#ifndef RESURRECTION_VERTEX_INCLUDED
#define RESURRECTION_VERTEX_INCLUDED

// =====================================================================
//  Res_Vertex.cginc : shared vertex stage for the forward passes
// =====================================================================

v2f res_vert(appdata v)
{
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(v2f, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.pos      = UnityObjectToClipPos(v.vertex);
    o.uv       = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.objPos   = v.vertex.xyz;
    o.color    = v.color;

    o.worldNormal     = UnityObjectToWorldNormal(v.normal);
    o.worldTangent.xyz= UnityObjectToWorldDir(v.tangent.xyz);
    o.worldTangent.w  = v.tangent.w * unity_WorldTransformParams.w;

    o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));

    UNITY_TRANSFER_FOG(o, o.pos);
    UNITY_TRANSFER_SHADOW(o, v.uv1);
    return o;
}

#endif // RESURRECTION_VERTEX_INCLUDED
