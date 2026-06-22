# 🜂 Resurrection — VRChat Master Shader

> *Reborn for VRChat.* A modular avatar shader —

Built for the **Built-in Render Pipeline**

---

## ✨ Features

| Module | What it does |
| --- | --- |
| **Base / PBR** | Albedo, normal, metallic/smoothness, occlusion, reflection probes, specular control. |
| **Lighting** | Realistic *or* flat/toon ramp shading, shadow strength, min/max brightness clamp, monochrome light option (great for consistent VRChat worlds). |
| **Emission** | Emission map + HDR color, pulsing. |
| **Rim / Fresnel** | Glowing edge light. |
| **Outline** | Inverted-hull outline with texture, emission (bloom-friendly), noise jitter, and vertex-color width masking. |
| **🔥 Fire** | Fully procedural animated flames. Rises along **world-up** so it always licks upward no matter how the avatar is posed. Three-color gradient (core → mid → tip), flicker, distortion, maskable. |
| **🖤 Liquid / Ferrofluid** | The headline effect — see below. |
| **Color Grading** | Saturation, contrast, hue shift. |

## 🖤 The Liquid Module (gravity-reactive)

Inspired by ferrofluid art — black liquid dripping and pooling over a surface.

The core idea: we take a **world-space gravity vector** and project it onto each fragment's
**surface tangent plane**. That projection is the direction the liquid *would* run along the
surface. Because it's computed in world space, when you **tilt or rotate the avatar the flow
direction follows real-world down** — the coating pools and drips toward the floor instead of
being locked to the mesh.

Controls:

- **Liquid Type** — Ferrofluid (black metallic), Water, Lava, Mercury, Slime. Each retunes
  metallic/smoothness automatically.
- **Flow State** — `Static`, `Flowing`, `Dripping` (elongated tendrils), `Pooling` (gathers on
  down-facing areas).
- **Coverage / Edge Softness / Scale** — how much of the surface is wet and how crisp the edge is.
- **Flow Speed / Drip Length / Viscosity / Surface Tension** — the motion + shape of the rivulets.
- **Particles / Bubbles** — droplet highlights inside the body.
- **Metallic / Smoothness / Fresnel / Wobble** — the material look (normal wobble perturbs the
  surface for that liquid sheen).
- **Gravity Reaction** — blend between mesh-locked and fully world-gravity driven.
- **Gravity Direction (World)** — defaults to `(0,-1,0)`. Animate this from an avatar parameter
  for fake-physics sloshing.

> **Tip:** drive `_GravityDirection` from a Constraint or animation that reads your head/hip
> orientation to make the liquid slosh as you move.

---

## 📦 Installation

1. Copy the `Assets/Resurrection` folder into your Unity project's `Assets`.
2. Let Unity import (it will generate `.meta` files automatically).
3. Create a material → **Shader → Resurrection/Master**.
4. Open the material — the custom **Resurrection** inspector appears with the preset bar on top.

## 🎛️ Presets

Click a preset in the inspector's **Presets** bar and hit **Apply**:

- **🔥 Inferno** — animated fire + ember outline + rim.
- **🖤 Ferrofluid** — the dripping black liquid.
- **💧 Water Flow** — clear gravity-aware water.
- **🌋 Lava** — molten flow + emission + fire.
- **✏️ Toon Outline** — flat cel shading with ink outline.
- **✨ Holo Rim** — iridescent sci-fi rim glow.
- **Default** — clean base, all effects off.

Presets are also mirrored as editable JSON in `Assets/Resurrection/Presets/` for sharing.

---

## 🗂️ Project layout

```
Assets/Resurrection/
├── Shaders/
│   ├── Resurrection.shader          # master shader: ForwardBase/Add, Outline, ShadowCaster
│   └── Includes/
│       ├── Res_Properties.cginc     # shared uniforms
│       ├── Res_Common.cginc         # structs, noise, color helpers
│       ├── Res_Lighting.cginc       # custom PBR / toon lighting
│       ├── Res_Fire.cginc           # procedural fire
│       ├── Res_Liquid.cginc         # gravity-reactive liquid
│       ├── Res_Vertex.cginc         # shared vertex stage
│       ├── Res_ForwardFrag.cginc    # forward fragment compositing
│       └── Res_Outline.cginc        # inverted-hull outline
├── Editor/
│   ├── ResurrectionInspector.cs     # custom ShaderGUI (the menu)
│   ├── ResurrectionGUI.cs           # neon banner / section styling
│   └── ResurrectionPresets.cs       # one-click presets
└── Presets/                         # JSON preset mirrors
```

## ⚠️ Notes & limitations

- Targets the **built-in** pipeline (VRChat). Not URP/HDRP.
- VRChat caps shader instructions; the procedural fire/liquid use FBM noise — heavy presets on
  high-poly avatars cost GPU. Tune `_FireScale`/`_LiquidScale` octaves for mobile/Quest.
- `Refraction` is exposed but is a simple fresnel-tint approximation here (no grab-pass) so it
  stays Quest-compatible.
- Written and structured for correctness; compile inside Unity to generate `.meta` GUIDs.

## License

MIT — do what you like, credit appreciated. Not affiliated with Poiyomi.
