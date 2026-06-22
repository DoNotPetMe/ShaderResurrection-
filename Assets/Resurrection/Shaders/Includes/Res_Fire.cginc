#ifndef RESURRECTION_FIRE_INCLUDED
#define RESURRECTION_FIRE_INCLUDED

// =====================================================================
//  Res_Fire.cginc : procedural animated fire emission
//  Flames rise either along UV-up or world-up (so they always lick
//  upward no matter how the avatar is oriented).
// =====================================================================

// Returns fire emission color, and outputs the raw fire mask in `outMask`.
float3 res_computeFire(float2 uv, float3 worldPos, float3 worldNormal,
                       out float outMask)
{
    outMask = 0;
    if (_FireEnabled < 0.5) return 0;

    float t = _Time.y * _FireSpeed;

    // Choose the coordinate the flame "rises" along.
    float2 fcoord;
    float rise;
    if (_FireDirectionMode > 0.5)
    {
        // World-space: project position, flames rise along world +Y.
        fcoord = float2(worldPos.x + worldPos.z, worldPos.y) * _FireScale;
        rise   = frac(worldPos.y * _FireScale * 0.15);
    }
    else
    {
        fcoord = uv * _FireScale * 8.0;
        rise   = uv.y;
    }

    // Domain warp for the turbulent licking motion.
    float2 warp;
    warp.x = res_fbm(fcoord * 0.5 + float2(0.0, -t * 1.3), 4);
    warp.y = res_fbm(fcoord * 0.5 + float2(5.2, -t * 1.7), 4);
    fcoord += (warp - 0.5) * _FireDistortion * 4.0;

    // Upward-scrolling turbulence.
    float n = res_fbm(fcoord + float2(0.0, -t * 3.0), 5);

    // Flames are stronger near the base and fade with height.
    float heightFalloff = saturate(1.0 - rise / max(_FireHeight, 0.01));
    float flame = saturate(n * heightFalloff * 1.6);
    flame = pow(flame, max(_FireSharpness, 0.1));

    // Flicker over time.
    float flicker = lerp(1.0, 0.6 + 0.4 * res_valueNoise(float2(t * 4.0, 0.0)), _FireFlicker);
    flame *= flicker;

    // Optional mask texture confines the fire to painted regions.
    float mask = tex2D(_FireMask, TRANSFORM_TEX(uv, _FireMask)).r;
    flame *= mask;

    // Color ramp: tip -> outer -> inner core (hot center).
    float3 col = res_gradient3(_FireColorTip.rgb, _FireColorOuter.rgb, _FireColorInner.rgb, flame);

    outMask = flame;
    return col * flame * _FireStrength;
}

#endif // RESURRECTION_FIRE_INCLUDED
