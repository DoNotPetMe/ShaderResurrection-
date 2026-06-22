#ifndef RESURRECTION_OUTLINE_INCLUDED
#define RESURRECTION_OUTLINE_INCLUDED

// =====================================================================
//  Res_Outline.cginc : inverted-hull outline pass
//  Extrudes back faces along the normal; supports vertex-color width
//  masking, a texture, noise jitter and emissive glow.
// =====================================================================

struct v2fOutline
{
    float4 pos   : SV_POSITION;
    float2 uv    : TEXCOORD0;
    float3 wpos  : TEXCOORD1;
    UNITY_FOG_COORDS(2)
    UNITY_VERTEX_OUTPUT_STEREO
};

v2fOutline res_outlineVert(appdata v)
{
    v2fOutline o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(v2fOutline, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    // Width mask from vertex colors (paintable per-vertex outlines).
    float widthMask = (_OutlineWidthMode > 0.5) ? v.color.r : 1.0;

    float3 norm = normalize(v.normal);
    float width = _OutlineWidth * 0.01 * widthMask;

    // Optional noise jitter for a hand-drawn / flame-licked edge.
    if (_OutlineNoise > 0.0)
    {
        float n = res_valueNoise(v.uv * 30.0 + _Time.y * 2.0);
        width *= lerp(1.0, n * 1.4, _OutlineNoise);
    }

    float4 vert = v.vertex;
    vert.xyz += norm * width;

    o.pos  = UnityObjectToClipPos(vert);
    o.uv   = TRANSFORM_TEX(v.uv, _MainTex);
    o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}

float4 res_outlineFrag(v2fOutline i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);
    float3 tex = tex2D(_OutlineTex, i.uv).rgb;
    float3 col = _OutlineColor.rgb * tex;
    col *= (1.0 + _OutlineEmission); // emission boosts brightness for bloom
    UNITY_APPLY_FOG(i.fogCoord, col);
    return float4(col, _OutlineColor.a);
}

#endif // RESURRECTION_OUTLINE_INCLUDED
