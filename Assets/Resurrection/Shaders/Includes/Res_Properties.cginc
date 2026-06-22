#ifndef RESURRECTION_PROPERTIES_INCLUDED
#define RESURRECTION_PROPERTIES_INCLUDED

// =====================================================================
//  RESURRECTION - Master Shader for VRChat
//  Res_Properties.cginc : all uniform declarations (shared by every pass)
// =====================================================================

// ---- Base / Albedo ----
sampler2D _MainTex;          float4 _MainTex_ST;
float4    _Color;
float     _Cutoff;
float     _AlphaToCoverage;

// ---- Normals ----
sampler2D _BumpMap;          float4 _BumpMap_ST;
float     _BumpScale;

// ---- PBR Lighting ----
sampler2D _MetallicGlossMap;
float     _Metallic;
float     _Glossiness;       // smoothness
float     _OcclusionStrength;
sampler2D _OcclusionMap;
float     _Reflectance;
float     _SpecularStrength;
float     _GICubeReflection; // sample reflection probes

// ---- Lighting control (VRChat friendly) ----
float     _LightingMode;     // 0 = realistic, 1 = flat/toon shading
float     _MinBrightness;
float     _MaxBrightness;
float     _ShadowStrength;
float     _ToonRamp;         // number of toon steps
float     _MonochromeLighting;

// ---- Emission ----
sampler2D _EmissionMap;      float4 _EmissionMap_ST;
float4    _EmissionColor;
float     _EmissionStrength;
float     _EmissionPulse;    // pulse speed
float     _EmissionPulseMin;

// ---- Rim / Fresnel ----
float     _RimEnabled;
float4    _RimColor;
float     _RimWidth;
float     _RimSharpness;
float     _RimStrength;

// ---- Outline ----
float     _OutlineWidth;
float4    _OutlineColor;
sampler2D _OutlineTex;
float     _OutlineEmission;
float     _OutlineNoise;
float     _OutlineWidthMode; // 0 = uniform, 1 = vertex-color masked

// ---- FIRE module ----
float     _FireEnabled;
float4    _FireColorInner;
float4    _FireColorOuter;
float4    _FireColorTip;
float     _FireSpeed;
float     _FireScale;
float     _FireHeight;
float     _FireSharpness;
float     _FireStrength;
float     _FireDistortion;
float     _FireDirectionMode; // 0 = UV up, 1 = world up (always rises)
float     _FireFlicker;
sampler2D _FireMask;         float4 _FireMask_ST;

// ---- LIQUID / FERROFLUID module ----
float     _LiquidEnabled;
float     _LiquidType;       // 0 Ferrofluid, 1 Water, 2 Lava, 3 Mercury, 4 Slime
float     _FlowState;        // 0 Static, 1 Flowing, 2 Dripping, 3 Pooling
float4    _LiquidColor;
float4    _LiquidColorDeep;
float4    _LiquidSpecColor;
float     _LiquidCoverage;   // 0..1 how much surface is wet
float     _LiquidEdgeWidth;  // softness of the liquid edge
float     _LiquidScale;
float     _LiquidFlowSpeed;
float     _LiquidDripLength;
float     _LiquidViscosity;  // resistance to flow
float     _LiquidSurfaceTension;
float     _LiquidMetallic;
float     _LiquidSmoothness;
float     _LiquidFresnel;
float     _LiquidGravityStrength; // how strongly tilt affects flow
float4    _GravityDirection;      // world-space gravity (default 0,-1,0)
float     _LiquidNormalStrength;  // wobble on liquid surface
sampler2D _LiquidMask;            float4 _LiquidMask_ST;
float     _LiquidRefraction;
float     _LiquidParticles;       // bubble / droplet density

// ---- Global ----
float     _Saturation;
float     _Contrast;
float     _HueShift;

#endif // RESURRECTION_PROPERTIES_INCLUDED
