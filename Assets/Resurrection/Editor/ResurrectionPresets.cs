using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Resurrection
{
    /// <summary>
    /// Built-in starter presets. Each preset is a set of property writes
    /// applied on top of the current material, so artists get an instant
    /// "look" they can then tweak. Mirrored by the JSON files in /Presets
    /// for users who want to hand-edit or share them.
    /// </summary>
    public static class ResurrectionPresets
    {
        public class Preset
        {
            public string Name;
            public string Description;
            public Dictionary<string, float> Floats = new Dictionary<string, float>();
            public Dictionary<string, Color> Colors = new Dictionary<string, Color>();
            public Dictionary<string, Vector4> Vectors = new Dictionary<string, Vector4>();
        }

        public static readonly List<Preset> All = new List<Preset>
        {
            new Preset
            {
                Name = "Default",
                Description = "Clean PBR base, all effects off.",
                Floats = { {"_FireEnabled",0}, {"_LiquidEnabled",0}, {"_RimEnabled",0},
                           {"_OutlineWidth",0}, {"_Metallic",0}, {"_Glossiness",0.5f},
                           {"_EmissionStrength",1}, {"_LightingMode",0} },
                Colors = { {"_EmissionColor", Color.black} }
            },
            new Preset
            {
                Name = "🔥 Inferno",
                Description = "Animated rising fire with emissive ember outline.",
                Floats = { {"_FireEnabled",1}, {"_FireSpeed",1.6f}, {"_FireScale",1.2f},
                           {"_FireHeight",1f}, {"_FireSharpness",2.4f}, {"_FireStrength",3f},
                           {"_FireDistortion",0.7f}, {"_FireDirectionMode",1}, {"_FireFlicker",0.6f},
                           {"_OutlineWidth",0.6f}, {"_OutlineEmission",3f}, {"_OutlineNoise",0.4f},
                           {"_RimEnabled",1}, {"_RimWidth",0.6f}, {"_RimSharpness",2f}, {"_RimStrength",2f} },
                Colors = { {"_FireColorInner", new Color(1f,0.95f,0.5f)},
                           {"_FireColorOuter", new Color(1f,0.4f,0.05f)},
                           {"_FireColorTip",   new Color(0.7f,0.04f,0f)},
                           {"_OutlineColor",   new Color(1f,0.3f,0.05f)},
                           {"_RimColor",       new Color(1f,0.45f,0.1f)} }
            },
            new Preset
            {
                Name = "🖤 Ferrofluid",
                Description = "Black glossy liquid that drips toward the floor as you tilt.",
                Floats = { {"_LiquidEnabled",1}, {"_LiquidType",0}, {"_FlowState",2},
                           {"_LiquidCoverage",0.55f}, {"_LiquidEdgeWidth",0.06f}, {"_LiquidScale",4f},
                           {"_LiquidFlowSpeed",0.5f}, {"_LiquidDripLength",1.4f}, {"_LiquidViscosity",0.35f},
                           {"_LiquidSurfaceTension",1.4f}, {"_LiquidMetallic",0.95f}, {"_LiquidSmoothness",0.92f},
                           {"_LiquidFresnel",1.5f}, {"_LiquidGravityStrength",1f}, {"_LiquidNormalStrength",0.7f},
                           {"_LiquidParticles",0.15f}, {"_Metallic",0.2f}, {"_Glossiness",0.6f} },
                Colors = { {"_LiquidColor", new Color(0.02f,0.02f,0.03f)},
                           {"_LiquidColorDeep", Color.black},
                           {"_LiquidSpecColor", new Color(0.55f,0.55f,0.7f)} },
                Vectors = { {"_GravityDirection", new Vector4(0,-1,0,0)} }
            },
            new Preset
            {
                Name = "💧 Water Flow",
                Description = "Clear, smooth water sheeting down the surface.",
                Floats = { {"_LiquidEnabled",1}, {"_LiquidType",1}, {"_FlowState",1},
                           {"_LiquidCoverage",0.7f}, {"_LiquidEdgeWidth",0.12f}, {"_LiquidScale",6f},
                           {"_LiquidFlowSpeed",0.9f}, {"_LiquidDripLength",0.6f}, {"_LiquidViscosity",0.1f},
                           {"_LiquidSurfaceTension",0.6f}, {"_LiquidMetallic",0f}, {"_LiquidSmoothness",0.97f},
                           {"_LiquidFresnel",2f}, {"_LiquidGravityStrength",1f}, {"_LiquidNormalStrength",0.4f},
                           {"_LiquidParticles",0.3f}, {"_LiquidRefraction",0.4f} },
                Colors = { {"_LiquidColor", new Color(0.5f,0.75f,0.9f,1f)},
                           {"_LiquidColorDeep", new Color(0.05f,0.25f,0.4f)},
                           {"_LiquidSpecColor", new Color(0.9f,0.97f,1f)} },
                Vectors = { {"_GravityDirection", new Vector4(0,-1,0,0)} }
            },
            new Preset
            {
                Name = "🌋 Lava",
                Description = "Molten flow with glowing cracks (pair with emission).",
                Floats = { {"_LiquidEnabled",1}, {"_LiquidType",2}, {"_FlowState",3},
                           {"_LiquidCoverage",0.6f}, {"_LiquidScale",3f}, {"_LiquidFlowSpeed",0.2f},
                           {"_LiquidViscosity",0.7f}, {"_LiquidSmoothness",0.35f}, {"_LiquidGravityStrength",0.8f},
                           {"_EmissionStrength",4f}, {"_FireEnabled",1}, {"_FireStrength",1.5f}, {"_FireScale",2f} },
                Colors = { {"_LiquidColor", new Color(0.25f,0.05f,0f)},
                           {"_LiquidColorDeep", new Color(0.02f,0.01f,0.01f)},
                           {"_LiquidSpecColor", new Color(1f,0.5f,0.1f)},
                           {"_EmissionColor", new Color(1.5f,0.4f,0.05f)},
                           {"_FireColorInner", new Color(1f,0.8f,0.2f)} },
                Vectors = { {"_GravityDirection", new Vector4(0,-1,0,0)} }
            },
            new Preset
            {
                Name = "✏️ Toon Outline",
                Description = "Flat cel shading with a bold ink outline.",
                Floats = { {"_LightingMode",1}, {"_ToonRamp",3}, {"_ShadowStrength",0.9f},
                           {"_OutlineWidth",1.2f}, {"_OutlineEmission",0f}, {"_OutlineNoise",0f},
                           {"_Glossiness",0.2f}, {"_SpecularStrength",0.3f} },
                Colors = { {"_OutlineColor", new Color(0.04f,0.02f,0.06f)} }
            },
            new Preset
            {
                Name = "✨ Holo Rim",
                Description = "Iridescent rim glow for a sci-fi avatar.",
                Floats = { {"_RimEnabled",1}, {"_RimWidth",0.7f}, {"_RimSharpness",1.5f}, {"_RimStrength",3f},
                           {"_EmissionStrength",2f}, {"_EmissionPulse",2f}, {"_EmissionPulseMin",0.3f},
                           {"_Metallic",0.6f}, {"_Glossiness",0.85f} },
                Colors = { {"_RimColor", new Color(0.3f,0.9f,1f) * 2f},
                           {"_EmissionColor", new Color(0.6f,0.2f,1f)} }
            }
        };

        public static void Apply(Preset p, Material mat)
        {
            Undo.RecordObject(mat, "Apply Resurrection Preset");
            foreach (var kv in p.Floats)
                if (mat.HasProperty(kv.Key)) mat.SetFloat(kv.Key, kv.Value);
            foreach (var kv in p.Colors)
                if (mat.HasProperty(kv.Key)) mat.SetColor(kv.Key, kv.Value);
            foreach (var kv in p.Vectors)
                if (mat.HasProperty(kv.Key)) mat.SetVector(kv.Key, kv.Value);

            // keep keyword state in sync
            if (mat.HasProperty("_AlphaToCoverage"))
            {
                if (mat.GetFloat("_AlphaToCoverage") > 0.5f) mat.EnableKeyword("_ALPHATEST_ON");
                else mat.DisableKeyword("_ALPHATEST_ON");
            }
            EditorUtility.SetDirty(mat);
        }

        public static string[] Names()
        {
            var n = new string[All.Count];
            for (int i = 0; i < All.Count; i++) n[i] = All[i].Name;
            return n;
        }
    }
}
