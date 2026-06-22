using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Resurrection
{
    /// <summary>
    /// Custom ShaderGUI for the Resurrection master shader.
    /// Organised into collapsible modules (like Poiyomi) with a neon banner,
    /// a one-click preset bar, and per-module enable toggles.
    /// </summary>
    public class ResurrectionInspector : ShaderGUI
    {
        MaterialEditor _editor;
        MaterialProperty[] _props;
        Material _mat;

        int _presetIndex = 0;

        // foldout state persisted per session
        static readonly Dictionary<string, bool> _fold = new Dictionary<string, bool>();

        static bool Fold(string key, bool def = false)
        {
            if (!_fold.ContainsKey(key)) _fold[key] = def;
            return _fold[key];
        }
        static void SetFold(string key, bool v) { _fold[key] = v; }

        MaterialProperty P(string name) => FindProperty(name, _props, false);

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            _editor = materialEditor;
            _props  = properties;
            _mat    = materialEditor.target as Material;

            float version = P("_ResurrectionVersion") != null ? P("_ResurrectionVersion").floatValue : 1.0f;
            ResurrectionGUI.Banner(version.ToString("0.0"));

            DrawPresetBar();
            EditorGUILayout.Space();

            DrawRenderingSection();
            DrawBaseSection();
            DrawLightingSection();
            DrawEmissionSection();
            DrawRimSection();
            DrawOutlineSection();
            DrawFireSection();
            DrawLiquidSection();
            DrawGradingSection();
            DrawAdvancedSection();

            ResurrectionGUI.Footer();
        }

        // -----------------------------------------------------------------
        void DrawPresetBar()
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Presets", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal();
            _presetIndex = EditorGUILayout.Popup(_presetIndex, ResurrectionPresets.Names());
            if (GUILayout.Button("Apply", GUILayout.Width(70)))
            {
                foreach (var t in _editor.targets)
                    ResurrectionPresets.Apply(ResurrectionPresets.All[_presetIndex], (Material)t);
            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.LabelField(ResurrectionPresets.All[_presetIndex].Description, EditorStyles.miniLabel);
            EditorGUILayout.EndVertical();
        }

        // -----------------------------------------------------------------
        void DrawRenderingSection()
        {
            const string k = "rendering";
            if (SetFoldRet(k, ResurrectionGUI.Section("Rendering Mode", Fold(k), ResurrectionGUI.AccentAlt)))
            {
                ResurrectionGUI.BeginBody();
                EditorGUI.BeginChangeCheck();
                var mode = (RenderMode)EditorGUILayout.EnumPopup("Mode", CurrentMode());
                if (EditorGUI.EndChangeCheck())
                    foreach (var t in _editor.targets) ApplyRenderMode((Material)t, mode);

                Prop("_Cull", "Cull Mode");
                if (CurrentMode() == RenderMode.Cutout)
                    Prop("_Cutoff", "Alpha Cutoff");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawBaseSection()
        {
            const string k = "base";
            if (SetFoldRet(k, ResurrectionGUI.Section("Base / PBR", Fold(k, true), ResurrectionGUI.AccentAlt)))
            {
                ResurrectionGUI.BeginBody();
                TexProp("_MainTex", "_Color", "Albedo");
                TexProp("_BumpMap", null, "Normal Map");
                Prop("_BumpScale", "Normal Strength");
                EditorGUILayout.Space();
                TexProp("_MetallicGlossMap", null, "Metallic / Smoothness");
                Prop("_Metallic", "Metallic");
                Prop("_Glossiness", "Smoothness");
                Prop("_Reflectance", "Reflectance");
                Prop("_SpecularStrength", "Specular Strength");
                TexProp("_OcclusionMap", null, "Occlusion");
                Prop("_OcclusionStrength", "Occlusion Strength");
                Prop("_GICubeReflection", "Reflection Probes");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawLightingSection()
        {
            const string k = "lighting";
            if (SetFoldRet(k, ResurrectionGUI.Section("Lighting", Fold(k), ResurrectionGUI.AccentAlt)))
            {
                ResurrectionGUI.BeginBody();
                Prop("_LightingMode", "Mode");
                if (P("_LightingMode").floatValue > 0.5f)
                    Prop("_ToonRamp", "Toon Steps");
                Prop("_ShadowStrength", "Shadow Strength");
                Prop("_MinBrightness", "Min Brightness");
                Prop("_MaxBrightness", "Max Brightness");
                Prop("_MonochromeLighting", "Monochrome Light");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawEmissionSection()
        {
            const string k = "emission";
            if (SetFoldRet(k, ResurrectionGUI.Section("Emission", Fold(k), ResurrectionGUI.Ember)))
            {
                ResurrectionGUI.BeginBody();
                TexProp("_EmissionMap", "_EmissionColor", "Emission");
                Prop("_EmissionStrength", "Strength");
                Prop("_EmissionPulse", "Pulse Speed");
                Prop("_EmissionPulseMin", "Pulse Min");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawRimSection()
        {
            const string k = "rim";
            bool exp = ResurrectionGUI.Module("Rim / Fresnel", Fold(k), P("_RimEnabled"), _editor, ResurrectionGUI.AccentAlt);
            SetFold(k, exp);
            if (exp)
            {
                ResurrectionGUI.BeginBody();
                Prop("_RimColor", "Color");
                Prop("_RimWidth", "Width");
                Prop("_RimSharpness", "Sharpness");
                Prop("_RimStrength", "Strength");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawOutlineSection()
        {
            const string k = "outline";
            if (SetFoldRet(k, ResurrectionGUI.Section("Outline", Fold(k), ResurrectionGUI.Accent)))
            {
                ResurrectionGUI.BeginBody();
                EditorGUILayout.HelpBox("Set Width above 0 to enable the inverted-hull outline pass.", MessageType.None);
                Prop("_OutlineWidth", "Width");
                Prop("_OutlineColor", "Color");
                TexProp("_OutlineTex", null, "Texture");
                Prop("_OutlineEmission", "Emission");
                Prop("_OutlineNoise", "Noise / Jitter");
                Prop("_OutlineWidthMode", "Width Mode");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawFireSection()
        {
            const string k = "fire";
            bool exp = ResurrectionGUI.Module("Fire", Fold(k), P("_FireEnabled"), _editor, ResurrectionGUI.Ember);
            SetFold(k, exp);
            if (exp)
            {
                ResurrectionGUI.BeginBody();
                Prop("_FireColorInner", "Core Color");
                Prop("_FireColorOuter", "Mid Color");
                Prop("_FireColorTip", "Tip Color");
                EditorGUILayout.Space();
                Prop("_FireSpeed", "Speed");
                Prop("_FireScale", "Scale");
                Prop("_FireHeight", "Height");
                Prop("_FireSharpness", "Sharpness");
                Prop("_FireStrength", "Strength");
                Prop("_FireDistortion", "Distortion");
                Prop("_FireFlicker", "Flicker");
                Prop("_FireDirectionMode", "Direction");
                TexProp("_FireMask", null, "Mask");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawLiquidSection()
        {
            const string k = "liquid";
            bool exp = ResurrectionGUI.Module("Liquid / Ferrofluid", Fold(k), P("_LiquidEnabled"), _editor, ResurrectionGUI.Accent);
            SetFold(k, exp);
            if (exp)
            {
                ResurrectionGUI.BeginBody();
                EditorGUILayout.HelpBox(
                    "Gravity-reactive coating. The liquid flows along world-down projected onto " +
                    "the surface — tilt the avatar and it pools / drips toward the floor.",
                    MessageType.Info);
                Prop("_LiquidType", "Liquid Type");
                Prop("_FlowState", "Flow State");
                EditorGUILayout.Space();
                Prop("_LiquidColor", "Surface Color");
                Prop("_LiquidColorDeep", "Deep Color");
                Prop("_LiquidSpecColor", "Highlight");
                EditorGUILayout.Space();
                Prop("_LiquidCoverage", "Coverage");
                Prop("_LiquidEdgeWidth", "Edge Softness");
                Prop("_LiquidScale", "Scale");
                Prop("_LiquidFlowSpeed", "Flow Speed");
                Prop("_LiquidDripLength", "Drip Length");
                Prop("_LiquidViscosity", "Viscosity");
                Prop("_LiquidSurfaceTension", "Surface Tension");
                Prop("_LiquidParticles", "Particles / Bubbles");
                EditorGUILayout.Space();
                Prop("_LiquidMetallic", "Metallic");
                Prop("_LiquidSmoothness", "Smoothness");
                Prop("_LiquidFresnel", "Fresnel");
                Prop("_LiquidNormalStrength", "Wobble");
                Prop("_LiquidRefraction", "Refraction");
                EditorGUILayout.Space();
                Prop("_LiquidGravityStrength", "Gravity Reaction");
                Prop("_GravityDirection", "Gravity Direction (World)");
                TexProp("_LiquidMask", null, "Mask");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawGradingSection()
        {
            const string k = "grading";
            if (SetFoldRet(k, ResurrectionGUI.Section("Color Grading", Fold(k), ResurrectionGUI.AccentAlt)))
            {
                ResurrectionGUI.BeginBody();
                Prop("_Saturation", "Saturation");
                Prop("_Contrast", "Contrast");
                Prop("_HueShift", "Hue Shift");
                ResurrectionGUI.EndBody();
            }
        }

        void DrawAdvancedSection()
        {
            const string k = "advanced";
            if (SetFoldRet(k, ResurrectionGUI.Section("Advanced", Fold(k), ResurrectionGUI.Disabled)))
            {
                ResurrectionGUI.BeginBody();
                _editor.RenderQueueField();
                _editor.EnableInstancingField();
                _editor.DoubleSidedGIField();
                ResurrectionGUI.EndBody();
            }
        }

        // -----------------------------------------------------------------
        //  Helpers
        // -----------------------------------------------------------------
        bool SetFoldRet(string key, bool v) { SetFold(key, v); return v; }

        void Prop(string name, string label)
        {
            var p = P(name);
            if (p == null) return;
            _editor.ShaderProperty(p, label);
        }

        void TexProp(string tex, string col, string label)
        {
            var tp = P(tex);
            if (tp == null) return;
            var cp = col != null ? P(col) : null;
            if (cp != null) _editor.TexturePropertySingleLine(new GUIContent(label), tp, cp);
            else _editor.TexturePropertySingleLine(new GUIContent(label), tp);
            _editor.TextureScaleOffsetProperty(tp);
        }

        // -----------------------------------------------------------------
        //  Rendering mode (transparency) management
        // -----------------------------------------------------------------
        enum RenderMode { Opaque, Cutout, Fade, Transparent }

        RenderMode CurrentMode()
        {
            var m = P("_Mode");
            return m != null ? (RenderMode)(int)m.floatValue : RenderMode.Opaque;
        }

        void ApplyRenderMode(Material m, RenderMode mode)
        {
            m.SetFloat("_Mode", (float)mode);
            switch (mode)
            {
                case RenderMode.Opaque:
                    m.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    m.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    m.SetFloat("_ZWrite", 1);
                    m.DisableKeyword("_ALPHATEST_ON");
                    m.SetFloat("_AlphaToCoverage", 0);
                    m.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                    break;
                case RenderMode.Cutout:
                    m.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    m.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    m.SetFloat("_ZWrite", 1);
                    m.EnableKeyword("_ALPHATEST_ON");
                    m.SetFloat("_AlphaToCoverage", 1);
                    m.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case RenderMode.Fade:
                    m.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    m.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    m.SetFloat("_ZWrite", 0);
                    m.DisableKeyword("_ALPHATEST_ON");
                    m.SetFloat("_AlphaToCoverage", 0);
                    m.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                case RenderMode.Transparent:
                    m.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    m.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    m.SetFloat("_ZWrite", 0);
                    m.DisableKeyword("_ALPHATEST_ON");
                    m.SetFloat("_AlphaToCoverage", 0);
                    m.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
            }
            EditorUtility.SetDirty(m);
        }
    }
}
