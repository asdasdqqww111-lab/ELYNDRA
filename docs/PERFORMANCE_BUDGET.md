# ELYNDRA — Performance Budget (Android)

> Milestone 001 is a **strategy document**. It defines the budget and the
> approach; there is not enough content yet to measure real frame times. No
> benchmark numbers are claimed.

## 1. Target devices

- **Primary:** mid-range Android devices from the last ~4 years.
- **Minimum to evaluate:** Android 5.0 (API 21) per the Godot 4.4 default
  `minSdk`. Devices without Vulkan must use the Compatibility renderer.
- No specific device has been profiled yet. Device testing is required before
  any performance claim is made.

## 2. Renderer

| Decision | Value |
|---|---|
| Default | **Mobile** |
| Fallback | **Compatibility (GL Compatibility)** |

**Why Mobile:** it is Godot's mobile-oriented renderer, designed for tile-based
and mid-range GPUs, with a lower baseline cost than Forward+. Forward+ is not
used as the default because it targets high-end desktop hardware and is not a
good fit for the Android baseline.

**Why not Forward+ by default:** significantly higher baseline cost; only
justifiable with a documented requirement and verified target hardware.

**Limitations of Mobile:** some advanced rendering features are unavailable or
reduced. Art direction must be authored within those limits.

**Fallback strategy:** if a device cannot run Mobile at an acceptable frame
rate, switch `rendering/renderer/rendering_method.mobile` to `gl_compatibility`.
Compatibility has broader device support but fewer features and different
visual output. The project should be tested in both renderers.

## 3. Milestone 001 cost controls

- One untextured ground plane (a single draw call).
- One `DirectionalLight3D` with **shadows disabled**.
- No post-processing (TAA, debanding, SSAO, etc. disabled or unused).
- No MSAA (disabled in `project.godot`).
- No textures, no imported meshes, no vegetation instances.
- One debug HUD label (negligible).
- A single lightweight `Environment` with a flat background colour and ambient
  light.

## 4. Future budget framework

These are the levers and rough targets for later milestones. They are not yet
measured.

| Area | Strategy | Rough target |
|---|---|---|
| Draw calls | Batch static geometry; use MultiMesh for vegetation | < 200 per frame on mid-range |
| Visibility | Region-based streaming + `VisibleOnScreen` culling | Only nearby regions active |
| LOD | LODGroup / manual LOD for props and characters | 2–3 levels, switch by distance |
| MultiMesh | MultiMeshInstance3D for grass, trees, rocks | One draw call per vegetation type |
| Texture memory | Power-of-two, atlasing, compressed (ETC2/ASTC) | < 256 MB total |
| Shadow cost | One directional shadow cascade, low resolution, limited distance | Mobile shadow size 2048 or lower |
| Region streaming | Load radius around the player; unload far regions | 1–2 regions beyond view |
| Device profiling | Profile on real hardware, not in the editor | 30–60 fps on target devices |

## 5. Known risks

1. **Untested on hardware.** All numbers above are targets, not measurements.
2. **Mobile renderer feature gaps.** Effects used in demos may not exist in
   Mobile; every effect must be verified.
3. **2.25 km² world.** Without streaming, a full-world view could exceed the
   draw-call and texture budgets. Streaming is required before the world is
   filled.
4. **Vegetation.** Thousands of instances are forbidden in M001; future
   vegetation must use MultiMesh and LOD from the start.
5. **Thermals and battery.** Sustained performance matters more than peak;
   profiling must include thermal throttling.
6. **Storage.** A large world plus assets can exceed the 2 GB APK expansion
   limits; asset delivery needs planning later.

## 6. Profiling procedure (for later milestones)

1. Run on a physical device via `adb` with the GPU profile hooks enabled.
2. Capture Godot's built-in profiler and the Android GPU inspector.
3. Measure CPU frame time, GPU frame time, draw calls, triangles and memory.
4. Compare against the budget above; fix the worst offender first.
5. Record the device, OS, Godot version, renderer and results in
   `BUILD_STATUS.md`.

## 7. Summary

M001 is deliberately cheap: one plane, one light, no shadows, no post-processing.
The budget above is the plan for keeping the full game inside mobile limits.
No device claim is made until real profiling is done.
