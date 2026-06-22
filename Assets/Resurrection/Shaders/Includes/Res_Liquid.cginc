#ifndef RESURRECTION_LIQUID_INCLUDED
#define RESURRECTION_LIQUID_INCLUDED

// =====================================================================
//  Res_Liquid.cginc : gravity / tilt reactive liquid coating
//
//  Inspired by ferrofluid dripping over a surface. The key idea:
//  we take a world-space gravity vector and project it onto the
//  surface tangent plane. That projection is the direction liquid
//  WOULD flow along the surface. As the avatar tilts, the object's
//  orientation in world space changes, so the flow direction changes
//  with it -> the coating pools toward the floor and drips downward.
// =====================================================================

struct ResLiquid
{
    float3 color;
    float3 specColor;
    float  coverage;     // 0..1 mask of where liquid is
    float  metallic;
    float  smoothness;
    float3 normalOffset;  // tangent-space wobble to perturb the surface
    float  fresnel;
};

// Per-liquid-type tuning applied on top of the user values.
void res_applyLiquidType(inout float metallic, inout float smoothness)
{
    int type = (int)round(_LiquidType);
    if (type == 0)        // Ferrofluid : black, glossy, very metallic
    {
        metallic   = max(metallic, 0.9);
        smoothness = max(smoothness, 0.85);
    }
    else if (type == 1)   // Water : clear, dielectric, very smooth
    {
        metallic   = 0.0;
        smoothness = max(smoothness, 0.95);
    }
    else if (type == 2)   // Lava : emissive-ish, rough, dark crust
    {
        metallic   = 0.1;
        smoothness = min(smoothness, 0.4);
    }
    else if (type == 3)   // Mercury : mirror metal
    {
        metallic   = 1.0;
        smoothness = 0.98;
    }
    else if (type == 4)   // Slime : translucent, medium gloss
    {
        metallic   = 0.0;
        smoothness = lerp(smoothness, 0.7, 0.5);
    }
}

ResLiquid res_computeLiquid(float2 uv, float3 worldPos, float3 worldNormal,
                            float3 worldTangent, float3 worldBitangent)
{
    ResLiquid lq = (ResLiquid)0;
    if (_LiquidEnabled < 0.5) return lq;

    float t = _Time.y * _LiquidFlowSpeed;

    // --- Gravity projected onto the surface (the flow direction) ---
    float3 G = normalize(_GravityDirection.xyz + 1e-5);
    float3 N = normalize(worldNormal);
    float3 flowWS = G - dot(G, N) * N;          // remove normal component
    float flowMag = length(flowWS);             // 0 on faces pointing up/down
    flowWS = flowWS / max(flowMag, 1e-4);

    // Express the flow direction in tangent (UV-ish) space so we can
    // scroll our noise along it.
    float2 flowUV = float2(dot(flowWS, worldTangent), dot(flowWS, worldBitangent));
    flowUV = normalize(flowUV + 1e-5);

    // How strongly this fragment feels gravity (down-facing surfaces drip).
    float gravityFacing = saturate(dot(-N, G));        // 1 when facing the floor
    float tilt = lerp(1.0, flowMag * 0.5 + gravityFacing, _LiquidGravityStrength);

    // --- Flow state controls the scroll behaviour ---
    int state = (int)round(_FlowState);
    float2 scroll = 0;
    if (state == 0)        scroll = 0;                                   // Static
    else if (state == 1)   scroll = flowUV * t;                         // Flowing
    else if (state == 2)   scroll = flowUV * t * (1.0 + _LiquidDripLength); // Dripping
    else if (state == 3)   scroll = flowUV * t * 0.25;                   // Pooling (slow)

    // Viscosity slows the apparent motion.
    scroll *= (1.0 - saturate(_LiquidViscosity) * 0.85);

    float2 luv = uv * _LiquidScale;

    // --- Drip pattern : stretched noise along the flow direction ---
    float2 stretch = luv + scroll;
    // stretch the sampling along flow to make elongated rivulets
    float along = dot(luv, flowUV);
    stretch += flowUV * sin(along * 6.0 + t) * _LiquidSurfaceTension * 0.1;

    float drips = res_fbm(stretch * float2(1.0, 0.35) , 5);
    float blobs = res_fbm(luv * 1.7 + 13.0, 4);

    // Coverage grows toward gravity-facing / lower regions and pools.
    float poolBias = (state == 3) ? gravityFacing : tilt;
    float field = drips * 0.6 + blobs * 0.4;
    field = lerp(field, field * poolBias + (1.0 - poolBias) * 0.2, _LiquidGravityStrength);

    // Painted mask multiplies coverage.
    float paint = tex2D(_LiquidMask, TRANSFORM_TEX(uv, _LiquidMask)).r;

    float threshold = 1.0 - saturate(_LiquidCoverage);
    float edge = max(_LiquidEdgeWidth, 1e-3);
    float coverage = smoothstep(threshold - edge, threshold + edge, field) * paint;

    // Dripping tendrils: thin downward fingers below blobs.
    if (state == 2)
    {
        float finger = res_fbm(float2(along * 3.0, dot(luv, flowUV.yx) * 0.5 - t), 3);
        coverage = saturate(coverage + smoothstep(0.55, 0.75, finger) * gravityFacing * 0.5);
    }

    // Particles / bubbles inside the liquid body.
    float particles = 0;
    if (_LiquidParticles > 0.001)
    {
        float p = res_valueNoise(luv * 9.0 + scroll * 2.0);
        particles = smoothstep(1.0 - _LiquidParticles * 0.3, 1.0, p) * coverage;
    }

    // --- Surface wobble normal (tangent space) ---
    float2 e = float2(0.004, 0.0);
    float h0 = field;
    float hx = res_fbm((stretch + e.xy) * float2(1.0, 0.35), 4);
    float hy = res_fbm((stretch + e.yx) * float2(1.0, 0.35), 4);
    float3 wobble = float3((h0 - hx), (h0 - hy), 1.0);
    wobble.xy *= _LiquidNormalStrength * coverage * 10.0;
    lq.normalOffset = normalize(wobble);

    // --- Color : deep where thick, surface tint where thin ---
    float depth = saturate(field * coverage * 1.5);
    float3 col = lerp(_LiquidColor.rgb, _LiquidColorDeep.rgb, depth);
    float metallic = _LiquidMetallic;
    float smoothness = _LiquidSmoothness;
    res_applyLiquidType(metallic, smoothness);

    // Particles read as bright surface tension highlights.
    col = lerp(col, _LiquidSpecColor.rgb, particles);

    lq.color     = col;
    lq.specColor = _LiquidSpecColor.rgb;
    lq.coverage  = saturate(coverage);
    lq.metallic  = metallic;
    lq.smoothness= smoothness;
    lq.fresnel   = _LiquidFresnel;
    return lq;
}

#endif // RESURRECTION_LIQUID_INCLUDED
