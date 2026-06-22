#ifndef RESURRECTION_LIGHTING_INCLUDED
#define RESURRECTION_LIGHTING_INCLUDED

// =====================================================================
//  Res_Lighting.cginc : custom PBR-ish lighting (VRChat friendly)
//  Supports directional + point lights, light probes, reflection probes,
//  realistic & toon modes, brightness clamping.
// =====================================================================

struct ResSurface
{
    float3 albedo;
    float3 normal;     // world space
    float  metallic;
    float  smoothness;
    float  occlusion;
    float3 emission;
    float  alpha;
};

// GGX normal distribution
float res_D_GGX(float NoH, float roughness)
{
    float a = NoH * roughness;
    float k = roughness / (1.0 - NoH * NoH + a * a);
    return k * k * (1.0 / RES_PI);
}

float3 res_fresnelSchlick(float cosT, float3 F0)
{
    float f = pow(1.0 - cosT, 5.0);
    return F0 + (1.0 - F0) * f;
}

// Indirect specular from reflection probes
float3 res_sampleReflection(float3 reflDir, float roughness)
{
    float mip = roughness * UNITY_SPECCUBE_LOD_STEPS;
    float4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, mip);
    return DecodeHDR(rgbm, unity_SpecCube0_HDR);
}

// Toon quantization of NdotL
float res_toonRamp(float ndl, float steps)
{
    if (steps < 1.5) return smoothstep(0.0, 0.04, ndl); // hard 2-tone
    float q = floor(saturate(ndl) * steps) / steps;
    return q;
}

// Main lighting evaluation. `lightColor`/`lightDir` for the current light,
// `atten` shadow+distance attenuation, `ambient` indirect diffuse.
float3 res_evaluateLight(ResSurface s, float3 viewDir, float3 lightDir,
                         float3 lightColor, float atten, float3 ambient,
                         bool isBaseLight)
{
    float roughness = max(1.0 - s.smoothness, 0.02);
    roughness *= roughness;

    float3 N = s.normal;
    float3 V = viewDir;
    float3 L = lightDir;
    float3 H = normalize(L + V);

    float NoL = saturate(dot(N, L));
    float NoV = saturate(dot(N, V)) + 1e-4;
    float NoH = saturate(dot(N, H));
    float LoH = saturate(dot(L, H));

    // Shadow / diffuse term, optionally toon-ramped
    float diffTerm = NoL * atten;
    if (_LightingMode > 0.5)
        diffTerm = res_toonRamp(NoL * atten, _ToonRamp);
    diffTerm = lerp(diffTerm, 1.0, 1.0 - _ShadowStrength);

    // F0: dielectric 0.04 lerped to albedo by metallic
    float3 F0 = lerp(0.04 * _Reflectance.xxx * 4.0, s.albedo, s.metallic);

    // Direct specular (GGX)
    float D = res_D_GGX(NoH, roughness);
    float3 F = res_fresnelSchlick(LoH, F0);
    float vis = 0.5 / max(NoL + NoV, 1e-3);
    float3 spec = D * vis * F * _SpecularStrength;

    float3 diffuseColor = s.albedo * (1.0 - s.metallic);
    float3 direct = (diffuseColor + spec) * lightColor * diffTerm * NoL;

    float3 result = direct;

    // Indirect (only on the base pass to avoid double counting)
    if (isBaseLight)
    {
        float3 indirectDiffuse = ambient * diffuseColor * s.occlusion;

        float3 R = reflect(-V, N);
        float3 indirectSpecular = 0;
        if (_GICubeReflection > 0.5)
        {
            float3 refl = res_sampleReflection(R, 1.0 - s.smoothness);
            float3 envF = res_fresnelSchlick(NoV, F0);
            indirectSpecular = refl * envF * s.occlusion * s.smoothness;
        }
        result += indirectDiffuse + indirectSpecular;
    }

    return result;
}

// Clamp final lighting brightness into the artist-defined window.
float3 res_clampBrightness(float3 col)
{
    float lum = max(res_luminance(col), 1e-4);
    float clamped = clamp(lum, _MinBrightness, _MaxBrightness);
    return col * (clamped / lum);
}

#endif // RESURRECTION_LIGHTING_INCLUDED
