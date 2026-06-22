#ifndef RESURRECTION_COMMON_INCLUDED
#define RESURRECTION_COMMON_INCLUDED

// =====================================================================
//  Res_Common.cginc : structs, noise, color & math helpers
// =====================================================================

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define RES_PI 3.14159265359
#define RES_TAU 6.28318530718

// ---------------------------------------------------------------------
//  Vertex -> Fragment interpolators
// ---------------------------------------------------------------------
struct appdata
{
    float4 vertex   : POSITION;
    float3 normal   : NORMAL;
    float4 tangent  : TANGENT;
    float2 uv       : TEXCOORD0;
    float2 uv1      : TEXCOORD1;
    float4 color    : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 pos        : SV_POSITION;
    float2 uv         : TEXCOORD0;
    float3 worldPos   : TEXCOORD1;
    float3 worldNormal: TEXCOORD2;
    float4 worldTangent : TEXCOORD3; // xyz = tangent, w = sign
    float3 objPos     : TEXCOORD4;
    float4 color      : TEXCOORD5;
    float3 viewDir    : TEXCOORD6;
    UNITY_FOG_COORDS(7)
    UNITY_SHADOW_COORDS(8)
    UNITY_VERTEX_OUTPUT_STEREO
};

// ---------------------------------------------------------------------
//  Hash / Noise
// ---------------------------------------------------------------------
float res_hash11(float p)
{
    p = frac(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}

float res_hash21(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

// Smooth value noise
float res_valueNoise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = res_hash21(i + float2(0,0));
    float b = res_hash21(i + float2(1,0));
    float c = res_hash21(i + float2(0,1));
    float d = res_hash21(i + float2(1,1));
    return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

// Fractal brownian motion
float res_fbm(float2 p, int octaves)
{
    float v = 0.0;
    float amp = 0.5;
    float2 shift = float2(100.0, 100.0);
    [loop]
    for (int i = 0; i < octaves; i++)
    {
        v += amp * res_valueNoise(p);
        p = p * 2.0 + shift;
        amp *= 0.5;
    }
    return v;
}

// Cheap 3D-ish noise by combining 2D planes (good enough for fire/liquid)
float res_noise3(float3 p)
{
    float xy = res_valueNoise(p.xy);
    float yz = res_valueNoise(p.yz + 19.19);
    float zx = res_valueNoise(p.zx + 47.47);
    return (xy + yz + zx) / 3.0;
}

// ---------------------------------------------------------------------
//  Color helpers
// ---------------------------------------------------------------------
float3 res_hueShift(float3 col, float shift)
{
    const float3 k = float3(0.57735, 0.57735, 0.57735);
    float cosA = cos(shift * RES_TAU);
    return col * cosA + cross(k, col) * sin(shift * RES_TAU) + k * dot(k, col) * (1.0 - cosA);
}

float3 res_saturation(float3 col, float sat)
{
    float l = dot(col, float3(0.2126, 0.7152, 0.0722));
    return lerp(l.xxx, col, sat);
}

float3 res_contrast(float3 col, float c)
{
    return saturate((col - 0.5) * c + 0.5);
}

float res_luminance(float3 c)
{
    return dot(c, float3(0.299, 0.587, 0.114));
}

// Maps a 0..1 gradient ramp across three colors
float3 res_gradient3(float3 a, float3 b, float3 c, float t)
{
    t = saturate(t);
    float3 lo = lerp(a, b, smoothstep(0.0, 0.5, t));
    float3 hi = lerp(b, c, smoothstep(0.5, 1.0, t));
    return lerp(lo, hi, step(0.5, t));
}

#endif // RESURRECTION_COMMON_INCLUDED
