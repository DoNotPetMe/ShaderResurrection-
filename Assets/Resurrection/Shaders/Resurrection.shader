// =====================================================================
//   RESURRECTION  -  Master Shader for VRChat
//   A modular avatar shader: PBR base, emission, rim, animated Fire,
//   and a gravity / tilt reactive Liquid (ferrofluid) coating.
//   Built-in Render Pipeline (Unity 2022 LTS) - uses a custom inspector.
// =====================================================================
Shader "Resurrection/Master"
{
    Properties
    {
        [HideInInspector] _ResurrectionVersion ("Version", Float) = 1.0

        // ---- Base ----
        [MainTexture] _MainTex   ("Albedo", 2D) = "white" {}
        [MainColor]   _Color     ("Color", Color) = (1,1,1,1)
        _Cutoff      ("Alpha Cutoff", Range(0,1)) = 0.5
        [Toggle(_ALPHATEST_ON)] _AlphaToCoverage ("Alpha To Coverage", Float) = 0

        // ---- Normals ----
        [Normal] _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Strength", Range(0,4)) = 1

        // ---- PBR ----
        _MetallicGlossMap ("Metallic (R) Smoothness (A)", 2D) = "white" {}
        _Metallic    ("Metallic", Range(0,1)) = 0
        _Glossiness  ("Smoothness", Range(0,1)) = 0.5
        _OcclusionMap ("Occlusion", 2D) = "white" {}
        _OcclusionStrength ("Occlusion Strength", Range(0,1)) = 1
        _Reflectance ("Reflectance", Range(0,1)) = 0.5
        _SpecularStrength ("Specular Strength", Range(0,4)) = 1
        [Toggle] _GICubeReflection ("Reflection Probes", Float) = 1

        // ---- Lighting ----
        [Enum(Realistic,0,Flat/Toon,1)] _LightingMode ("Lighting Mode", Float) = 0
        _MinBrightness ("Min Brightness", Range(0,1)) = 0.05
        _MaxBrightness ("Max Brightness", Range(0,4)) = 1.5
        _ShadowStrength ("Shadow Strength", Range(0,1)) = 1
        _ToonRamp ("Toon Steps", Range(1,8)) = 2
        [Toggle] _MonochromeLighting ("Monochrome Light", Float) = 0

        // ---- Emission ----
        _EmissionMap ("Emission Map", 2D) = "white" {}
        [HDR] _EmissionColor ("Emission Color", Color) = (0,0,0,1)
        _EmissionStrength ("Emission Strength", Range(0,16)) = 1
        _EmissionPulse ("Pulse Speed", Range(0,16)) = 0
        _EmissionPulseMin ("Pulse Min", Range(0,1)) = 0.2

        // ---- Rim ----
        [Toggle] _RimEnabled ("Enable Rim", Float) = 0
        [HDR] _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimWidth ("Rim Width", Range(0,1)) = 0.5
        _RimSharpness ("Rim Sharpness", Range(0.01,8)) = 1
        _RimStrength ("Rim Strength", Range(0,8)) = 1

        // ---- Outline ----
        _OutlineWidth ("Outline Width", Range(0,5)) = 0
        [HDR] _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineTex ("Outline Texture", 2D) = "white" {}
        _OutlineEmission ("Outline Emission", Range(0,8)) = 0
        _OutlineNoise ("Outline Noise", Range(0,1)) = 0
        [Enum(Uniform,0,VertexColor,1)] _OutlineWidthMode ("Width Mode", Float) = 0

        // ---- Fire ----
        [Toggle] _FireEnabled ("Enable Fire", Float) = 0
        [HDR] _FireColorInner ("Fire Core", Color) = (1,1,0.6,1)
        [HDR] _FireColorOuter ("Fire Mid", Color) = (1,0.4,0,1)
        [HDR] _FireColorTip ("Fire Tip", Color) = (0.6,0,0,1)
        _FireSpeed ("Fire Speed", Range(0,8)) = 1
        _FireScale ("Fire Scale", Range(0.1,8)) = 1
        _FireHeight ("Fire Height", Range(0.1,2)) = 1
        _FireSharpness ("Fire Sharpness", Range(0.1,8)) = 2
        _FireStrength ("Fire Strength", Range(0,8)) = 2
        _FireDistortion ("Fire Distortion", Range(0,2)) = 0.5
        [Enum(UV Up,0,World Up,1)] _FireDirectionMode ("Fire Direction", Float) = 1
        _FireFlicker ("Fire Flicker", Range(0,1)) = 0.5
        _FireMask ("Fire Mask", 2D) = "white" {}

        // ---- Liquid ----
        [Toggle] _LiquidEnabled ("Enable Liquid", Float) = 0
        [Enum(Ferrofluid,0,Water,1,Lava,2,Mercury,3,Slime,4)] _LiquidType ("Liquid Type", Float) = 0
        [Enum(Static,0,Flowing,1,Dripping,2,Pooling,3)] _FlowState ("Flow State", Float) = 2
        [HDR] _LiquidColor ("Liquid Color", Color) = (0.02,0.02,0.02,1)
        [HDR] _LiquidColorDeep ("Liquid Deep Color", Color) = (0,0,0,1)
        [HDR] _LiquidSpecColor ("Liquid Highlight", Color) = (0.6,0.6,0.7,1)
        _LiquidCoverage ("Coverage", Range(0,1)) = 0.5
        _LiquidEdgeWidth ("Edge Softness", Range(0.001,0.5)) = 0.08
        _LiquidScale ("Liquid Scale", Range(0.1,16)) = 4
        _LiquidFlowSpeed ("Flow Speed", Range(0,4)) = 0.5
        _LiquidDripLength ("Drip Length", Range(0,4)) = 1
        _LiquidViscosity ("Viscosity", Range(0,1)) = 0.3
        _LiquidSurfaceTension ("Surface Tension", Range(0,4)) = 1
        _LiquidMetallic ("Liquid Metallic", Range(0,1)) = 0.9
        _LiquidSmoothness ("Liquid Smoothness", Range(0,1)) = 0.9
        _LiquidFresnel ("Liquid Fresnel", Range(0,4)) = 1
        _LiquidGravityStrength ("Gravity Reaction", Range(0,1)) = 1
        _GravityDirection ("Gravity Direction (World)", Vector) = (0,-1,0,0)
        _LiquidNormalStrength ("Liquid Wobble", Range(0,2)) = 0.5
        _LiquidParticles ("Particles / Bubbles", Range(0,1)) = 0.2
        _LiquidMask ("Liquid Mask", 2D) = "white" {}
        _LiquidRefraction ("Refraction", Range(0,1)) = 0

        // ---- Grading ----
        _Saturation ("Saturation", Range(0,2)) = 1
        _Contrast ("Contrast", Range(0,2)) = 1
        _HueShift ("Hue Shift", Range(0,1)) = 0

        // ---- Render state (set via inspector) ----
        [HideInInspector] _Mode ("Rendering Mode", Float) = 0
        [HideInInspector] _SrcBlend ("Src Blend", Float) = 1
        [HideInInspector] _DstBlend ("Dst Blend", Float) = 0
        [HideInInspector] _ZWrite ("ZWrite", Float) = 1
        [HideInInspector] _Cull ("Cull", Float) = 2
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        // =============================================================
        //  FORWARD BASE
        // =============================================================
        Pass
        {
            Name "FORWARD_BASE"
            Tags { "LightMode"="ForwardBase" }
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            CGPROGRAM
            #pragma vertex res_vert
            #pragma fragment res_fragBase
            #pragma target 4.0
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma shader_feature_local _ALPHATEST_ON

            #include "Includes/Res_Properties.cginc"
            #include "Includes/Res_Common.cginc"
            #include "Includes/Res_Vertex.cginc"
            #include "Includes/Res_ForwardFrag.cginc"
            ENDCG
        }

        // =============================================================
        //  FORWARD ADD (extra realtime lights)
        // =============================================================
        Pass
        {
            Name "FORWARD_ADD"
            Tags { "LightMode"="ForwardAdd" }
            Blend [_SrcBlend] One
            ZWrite Off
            Cull [_Cull]

            CGPROGRAM
            #pragma vertex res_vert
            #pragma fragment res_fragAdd
            #pragma target 4.0
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma shader_feature_local _ALPHATEST_ON

            #include "Includes/Res_Properties.cginc"
            #include "Includes/Res_Common.cginc"
            #include "Includes/Res_Vertex.cginc"
            #include "Includes/Res_ForwardFrag.cginc"
            ENDCG
        }

        // =============================================================
        //  OUTLINE (inverted hull)
        // =============================================================
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode"="ForwardBase" }
            Cull Front
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex res_outlineVert
            #pragma fragment res_outlineFrag
            #pragma target 4.0
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "Includes/Res_Properties.cginc"
            #include "Includes/Res_Common.cginc"
            #include "Includes/Res_Outline.cginc"
            ENDCG
        }

        // =============================================================
        //  SHADOW CASTER
        // =============================================================
        Pass
        {
            Name "SHADOW_CASTER"
            Tags { "LightMode"="ShadowCaster" }
            ZWrite On
            Cull [_Cull]

            CGPROGRAM
            #pragma vertex res_shadowVert
            #pragma fragment res_shadowFrag
            #pragma target 4.0
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #pragma shader_feature_local _ALPHATEST_ON

            #include "Includes/Res_Properties.cginc"
            #include "Includes/Res_Common.cginc"

            struct v2fShadow
            {
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2fShadow res_shadowVert(appdata v)
            {
                v2fShadow o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 res_shadowFrag(v2fShadow i) : SV_Target
            {
                #if defined(_ALPHATEST_ON)
                    float a = tex2D(_MainTex, i.uv).a * _Color.a;
                    clip(a - _Cutoff);
                #endif
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }

    CustomEditor "Resurrection.ResurrectionInspector"
    Fallback "VRChat/Mobile/Standard Lite"
}
