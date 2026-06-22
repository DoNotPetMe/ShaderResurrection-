#ifndef RESURRECTION_FORWARDFRAG_INCLUDED
#define RESURRECTION_FORWARDFRAG_INCLUDED

// =====================================================================
//  Res_ForwardFrag.cginc : the master fragment shader for the forward
//  passes. Composites base PBR + emission + rim + fire + liquid.
// =====================================================================

#include "Res_Lighting.cginc"
#include "Res_Fire.cginc"
#include "Res_Liquid.cginc"

float4 res_frag(v2f i, bool isBase)
{
    UNITY_SETUP_INSTANCE_ID(i);

    // ---- Base albedo / alpha ----
    float4 baseTex = tex2D(_MainTex, i.uv) * _Color;
    float3 albedo  = baseTex.rgb;
    float  alpha   = baseTex.a;

    #if defined(_ALPHATEST_ON)
        clip(alpha - _Cutoff);
    #endif

    // ---- Tangent basis ----
    float3 N = normalize(i.worldNormal);
    float3 T = normalize(i.worldTangent.xyz);
    float3 B = cross(N, T) * i.worldTangent.w;

    // ---- Normal map ----
    float3 nTS = UnpackScaleNormal(tex2D(_BumpMap, TRANSFORM_TEX(i.uv, _BumpMap)), _BumpScale);
    N = normalize(T * nTS.x + B * nTS.y + N * nTS.z);

    float3 V = normalize(i.viewDir);

    // ---- Metallic / smoothness / occlusion ----
    float4 mg = tex2D(_MetallicGlossMap, i.uv);
    float metallic   = mg.r * _Metallic;
    float smoothness = mg.a * _Glossiness;
    float occlusion  = lerp(1.0, tex2D(_OcclusionMap, i.uv).g, _OcclusionStrength);

    // ===================================================================
    //  LIQUID coating (overrides surface where covered)
    // ===================================================================
    float3 baseAlbedo    = albedo;   // saved so clear-fluid areas can show through
    float  baseMetallic  = metallic;

    ResLiquid lq = res_computeLiquid(i.uv, i.worldPos, N, T, B);
    if (lq.coverage > 0.0)
    {
        // Perturb the world normal by the liquid wobble.
        float3 wobbleWS = normalize(T * lq.normalOffset.x + B * lq.normalOffset.y + N * lq.normalOffset.z);
        N = normalize(lerp(N, wobbleWS, lq.coverage));

        albedo     = lerp(albedo, lq.color, lq.coverage);
        metallic   = lerp(metallic, lq.metallic, lq.coverage);
        smoothness = lerp(smoothness, lq.smoothness, lq.coverage);

        // Clear-fluid windows: punch back through to the base surface.
        // The fluid is still there (keeps high smoothness for the glassy
        // surface sheen) but its color/metallic disappear, so the object
        // underneath shows through — just like the white spheres in the
        // ferrofluid reference.
        if (lq.clearMask > 0.0)
        {
            albedo   = lerp(albedo, baseAlbedo, lq.clearMask);
            metallic = lerp(metallic, baseMetallic, lq.clearMask);
            // smoothness stays high: clear fluid still has a glassy surface
        }
    }

    // ---- Build surface ----
    ResSurface s;
    s.albedo     = albedo;
    s.normal     = N;
    s.metallic   = saturate(metallic);
    s.smoothness = saturate(smoothness);
    s.occlusion  = occlusion;
    s.emission   = 0;
    s.alpha      = alpha;

    // ===================================================================
    //  Lighting
    // ===================================================================
    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

    float3 lightColor = _LightColor0.rgb;
    float3 lightDir;
    if (isBase)
        lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos)); // directional
    else
        lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos * _WorldSpaceLightPos0.w);

    // Ambient / light probe diffuse.
    float3 ambient = ShadeSH9(float4(N, 1.0));
    if (_LightingMode > 0.5)
        ambient = max(ambient, _MinBrightness.xxx); // flat mode keeps things readable

    if (_MonochromeLighting > 0.5)
        lightColor = res_luminance(lightColor).xxx;

    float3 lit = res_evaluateLight(s, V, lightDir, lightColor, atten, ambient, isBase);

    if (isBase)
        lit = res_clampBrightness(lit);

    // ===================================================================
    //  Emission (base pass only)
    // ===================================================================
    float3 emission = 0;
    if (isBase)
    {
        float pulse = lerp(1.0,
            lerp(_EmissionPulseMin, 1.0, 0.5 + 0.5 * sin(_Time.y * _EmissionPulse)),
            step(0.001, _EmissionPulse));
        emission = tex2D(_EmissionMap, TRANSFORM_TEX(i.uv, _EmissionMap)).rgb
                   * _EmissionColor.rgb * _EmissionStrength * pulse;
    }

    // ---- Rim / Fresnel ----
    float3 rim = 0;
    if (_RimEnabled > 0.5)
    {
        float f = 1.0 - saturate(dot(N, V));
        f = pow(f, max(_RimSharpness, 0.01));
        f = smoothstep(1.0 - _RimWidth, 1.0, f);
        rim = _RimColor.rgb * f * _RimStrength;
    }

    // ---- Liquid fresnel sheen ----
    if (isBase && lq.coverage > 0.0 && lq.fresnel > 0.0)
    {
        float lf = pow(1.0 - saturate(dot(N, V)), 4.0);
        lit += lq.specColor * lf * lq.fresnel * lq.coverage;
    }

    // ---- Fire (additive emission) ----
    float fireMask;
    float3 fire = isBase ? res_computeFire(i.uv, i.worldPos, N, fireMask) : 0;

    // ===================================================================
    //  Composite
    // ===================================================================
    float3 col = lit;
    if (isBase) col += emission + rim;
    col += fire;

    // Grading (base pass only so additive lights aren't double-graded).
    if (isBase)
    {
        col = res_hueShift(col, _HueShift);
        col = res_saturation(col, _Saturation);
        col = res_contrast(col, _Contrast);
    }

    UNITY_APPLY_FOG(i.fogCoord, col);

    return float4(col, alpha);
}

float4 res_fragBase(v2f i) : SV_Target { return res_frag(i, true); }
float4 res_fragAdd (v2f i) : SV_Target { return res_frag(i, false); }

#endif // RESURRECTION_FORWARDFRAG_INCLUDED
