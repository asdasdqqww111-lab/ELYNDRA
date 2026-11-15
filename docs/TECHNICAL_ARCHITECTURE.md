# ELYNDRA — Technical Architecture

## 1. Engine

| Item | Value |
|---|---|
| Selected version | **Godot 4.4.1-stable** |
| Minimum supported | **Godot 4.4.1-stable** |
| Language | GDScript |
| External add-ons | None |
| Export templates | Godot 4.4.1-stable export templates (not installed in the dev sandbox for M001) |

### Why 4.4.1

Godot 4.4.1 is a mature stable patch with extensive community documentation,
which matters for a solo beginner developer. Its Android requirements are also
lower than the newest stable branch (compileSdk 34 / minSdk 21 instead of 36 /
24), which keeps the toolchain easier to install and supports older devices.
See `DECISIONS.md` (D-001) and `BUILD_STATUS.md`.

### API compatibility decisions

- Target the **Godot 4.4 GDScript API**. Scripts avoid deprecated 3.x idioms.
- Cross-script references use `preload()` in addition to `class_name`, so the
  project also runs before the editor has built the global class cache.
- No use of experimental or `until further notice` APIs.

### Known limitations

- The project has not been tested on a physical Android device yet.
- The Mobile renderer requires Vulkan-capable devices; the Compatibility
  renderer is the documented fallback.
- Region streaming, LOD and MultiMesh are not implemented (by design in M001).

## 2. Unit and coordinate convention

This is a **project-wide engineering convention**, not an assumed conversion.

```
1 Godot world unit = 1 meter
```

| Axis | Meaning |
|---|---|
| X | horizontal, east/west |
| Y | vertical (up is +Y) |
| Z | horizontal, north/south |

- World centre: `(0, 0, 0)`.
- Ground plane: `Y = 0`.
- World bounds: `X ∈ [-750, +750]`, `Z ∈ [-750, +750]` (meters).
- All dimensions in documentation and scripts follow this convention.

Region indices are 2D `(x, y)` where `y` maps to the world **Z** axis. Region
`(0, 0)` is the **south-west** corner. See `WORLD_DESIGN.md`.

## 3. Folder architecture

```
ELYNDRA/
├── project.godot
├── scenes/          # .tscn scenes, grouped by purpose
│   ├── main/        # startup and top-level scenes
│   ├── world/       # ground, terrain, region visuals
│   └── debug/       # temporary debug scenes/overlays
├── scripts/         # GDScript, grouped by purpose
│   ├── core/        # engine-level utilities (regions, math, config)
│   ├── world/       # world/terrain behaviour
│   └── debug/       # temporary debug tools
├── assets/          # imported art/audio/font assets (empty in M001)
│   ├── environments/
│   ├── textures/
│   ├── materials/
│   ├── vegetation/
│   ├── models/
│   ├── audio/
│   └── fonts/
├── resources/       # .tres/.res resources
│   ├── world/
│   └── materials/
├── addons/          # verified third-party add-ons only (empty in M001)
├── tests/           # headless validation and unit tests
└── docs/            # project documentation
```

### Deviations from the proposed M001 structure

- `assets/` sub-folders are not created as empty directories. Git cannot track
  empty folders and M001 has no assets; `assets/README.md` documents the planned
  layout. Folders will be created when the first real asset lands.
- `resources/` is present for future `.tres` resources; M001 uses scene-embedded
  sub-resources only, so it contains no files yet.
- `addons/` is empty and will remain empty until an add-on is verified.

## 4. Scene architecture

```
main.tscn (Node3D, scripts/main/main.gd)
├── World (Node3D)
│   ├── Ground (instance of world_ground.tscn)
│   │   ├── GroundMesh (MeshInstance3D, PlaneMesh 1500 x 1500)
│   │   └── GroundCollision (CollisionShape3D, BoxShape3D 1500 x 1 x 1500)
│   ├── WorldEnvironment (WorldEnvironment, neutral Environment)
│   ├── Sun (DirectionalLight3D, shadows disabled)
│   └── DebugCamera (Camera3D, temporary elevated inspection camera)
└── DebugHUD (instance of debug_hud.tscn, CanvasLayer + Label)
```

Design rules:

- Scenes are small and single-purpose.
- The ground is a reusable scene so it can be instanced and tested independently.
- The debug camera is **temporary**. The final third-person camera rig and the
  player character are out of scope for M001.
- UI is separated from the 3D world (CanvasLayer).

## 5. Rendering choice

| Setting | Value |
|---|---|
| Default renderer | **Mobile** |
| Desktop override | Mobile (same) |
| Fallback | Compatibility (GL Compatibility) for low-end devices |

`project.godot`:

```ini
[rendering]
renderer/rendering_method="mobile"
renderer/rendering_method.mobile="mobile"
```

Rationale, limitations and the fallback strategy are documented in
`PERFORMANCE_BUDGET.md`.

## 6. Main technical decisions

Summary; full detail with dates and status is in `DECISIONS.md`.

- Godot 4.4.1-stable pinned (D-001).
- Mobile renderer default, Compatibility fallback (D-002).
- 1 unit = 1 meter; XZ ground plane; Y up (D-003).
- PlaneMesh + thin BoxShape3D collision for the flat ground (D-004).
- Region grid as a stateless utility class, not scene nodes (D-005).
- Half-open world bounds; out-of-bounds returns an explicit invalid region (D-006).
- Plain-GDScript test runner, no test framework dependency (D-007).
- No `export_presets.cfg` or signing material in M001 (D-008).
