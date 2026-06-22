using UnityEngine;
using UnityEditor;

namespace Resurrection
{
    /// <summary>
    /// Drawing + styling helpers for the Resurrection inspector.
    /// Gives the menu its dark, neon "cooler than Poiyomi" look:
    /// gradient banners, glowing section headers and module toggles.
    /// </summary>
    public static class ResurrectionGUI
    {
        // --- Theme palette ---
        public static readonly Color Accent      = new Color(0.78f, 0.25f, 1.00f); // neon violet
        public static readonly Color AccentAlt   = new Color(0.20f, 0.85f, 1.00f); // cyan
        public static readonly Color Ember       = new Color(1.00f, 0.45f, 0.10f); // fire orange
        public static readonly Color HeaderBG    = new Color(0.12f, 0.12f, 0.16f);
        public static readonly Color SectionBG   = new Color(0.16f, 0.16f, 0.20f);
        public static readonly Color Disabled    = new Color(0.45f, 0.45f, 0.50f);

        static Texture2D _gradientTex;
        static GUIStyle _bannerTitle, _bannerSub, _sectionHeader, _moduleHeader, _footer;

        static Texture2D GradientTex()
        {
            if (_gradientTex != null) return _gradientTex;
            int w = 256;
            _gradientTex = new Texture2D(w, 1, TextureFormat.RGBA32, false)
            {
                wrapMode = TextureWrapMode.Clamp,
                hideFlags = HideFlags.HideAndDontSave
            };
            for (int x = 0; x < w; x++)
            {
                float t = x / (float)(w - 1);
                // violet -> magenta -> ember sweep
                Color c = t < 0.5f
                    ? Color.Lerp(Accent, new Color(1f, 0.2f, 0.6f), t * 2f)
                    : Color.Lerp(new Color(1f, 0.2f, 0.6f), Ember, (t - 0.5f) * 2f);
                _gradientTex.SetPixel(x, 0, c);
            }
            _gradientTex.Apply();
            return _gradientTex;
        }

        public static void Banner(string version)
        {
            EnsureStyles();
            Rect r = GUILayoutUtility.GetRect(0, 56, GUILayout.ExpandWidth(true));
            GUI.DrawTexture(r, GradientTex(), ScaleMode.StretchToFill);

            // dark overlay for text legibility
            EditorGUI.DrawRect(new Rect(r.x, r.y, r.width, r.height), new Color(0, 0, 0, 0.35f));

            Rect title = new Rect(r.x + 14, r.y + 8, r.width - 20, 26);
            Rect sub   = new Rect(r.x + 16, r.y + 32, r.width - 20, 18);
            GUI.Label(title, "RESURRECTION", _bannerTitle);
            GUI.Label(sub, "Master Shader  •  v" + version + "  •  reborn for VRChat", _bannerSub);
            GUILayout.Space(4);
        }

        /// <summary>Foldout section header. Returns the new expanded state.</summary>
        public static bool Section(string title, bool expanded, Color tint)
        {
            EnsureStyles();
            Rect r = GUILayoutUtility.GetRect(0, 24, GUILayout.ExpandWidth(true));
            EditorGUI.DrawRect(r, SectionBG);
            // accent bar on the left edge
            EditorGUI.DrawRect(new Rect(r.x, r.y, 4, r.height), tint);

            string arrow = expanded ? "▼" : "▶";
            Color prev = GUI.contentColor;
            GUI.contentColor = Color.white;
            if (GUI.Button(r, $"   {arrow}  {title}", _sectionHeader))
                expanded = !expanded;
            GUI.contentColor = prev;
            return expanded;
        }

        /// <summary>
        /// Module header with an enable toggle baked into the bar.
        /// Returns the (possibly changed) expanded state; toggle is by ref.
        /// </summary>
        public static bool Module(string title, bool expanded, MaterialProperty toggle,
                                  MaterialEditor editor, Color tint)
        {
            EnsureStyles();
            Rect r = GUILayoutUtility.GetRect(0, 26, GUILayout.ExpandWidth(true));
            bool on = toggle != null && toggle.floatValue > 0.5f;

            Color barCol = on ? tint : Disabled;
            EditorGUI.DrawRect(r, new Color(barCol.r, barCol.g, barCol.b, 0.18f));
            EditorGUI.DrawRect(new Rect(r.x, r.y, 4, r.height), barCol);

            // enable checkbox
            Rect tog = new Rect(r.x + 10, r.y + 5, 16, 16);
            EditorGUI.BeginChangeCheck();
            bool newOn = EditorGUI.Toggle(tog, on);
            if (EditorGUI.EndChangeCheck() && toggle != null)
            {
                editor.RegisterPropertyChangeUndo(title);
                toggle.floatValue = newOn ? 1f : 0f;
            }

            // clickable label area to fold
            Rect lbl = new Rect(r.x + 32, r.y, r.width - 32, r.height);
            string arrow = expanded ? "▼" : "▶";
            Color prev = GUI.color;
            GUI.color = on ? Color.white : Disabled;
            if (GUI.Button(lbl, $"{arrow}  {title}", _moduleHeader))
                expanded = !expanded;
            GUI.color = prev;
            return expanded;
        }

        public static void BeginBody()
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            GUILayout.Space(2);
        }

        public static void EndBody()
        {
            GUILayout.Space(2);
            EditorGUILayout.EndVertical();
        }

        public static void Footer()
        {
            EnsureStyles();
            GUILayout.Space(6);
            Rect r = GUILayoutUtility.GetRect(0, 2, GUILayout.ExpandWidth(true));
            GUI.DrawTexture(r, GradientTex(), ScaleMode.StretchToFill);
            GUILayout.Label("Resurrection Shader — presets included: Fire, Ferrofluid, Water, Lava, Toon Outline", _footer);
        }

        static void EnsureStyles()
        {
            if (_bannerTitle != null) return;

            _bannerTitle = new GUIStyle(EditorStyles.boldLabel)
            {
                fontSize = 20,
                fontStyle = FontStyle.Bold,
                normal = { textColor = Color.white },
                alignment = TextAnchor.MiddleLeft
            };
            _bannerSub = new GUIStyle(EditorStyles.miniLabel)
            {
                fontSize = 11,
                normal = { textColor = new Color(0.92f, 0.92f, 0.95f) },
                alignment = TextAnchor.MiddleLeft
            };
            _sectionHeader = new GUIStyle(EditorStyles.label)
            {
                fontSize = 12,
                fontStyle = FontStyle.Bold,
                alignment = TextAnchor.MiddleLeft,
                normal = { textColor = Color.white },
                hover = { textColor = Color.white }
            };
            _moduleHeader = new GUIStyle(_sectionHeader);
            _footer = new GUIStyle(EditorStyles.centeredGreyMiniLabel)
            {
                wordWrap = true,
                fontSize = 10
            };
        }
    }
}
