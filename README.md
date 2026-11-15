# ELYNDRA — Secrets of the Seven Realms

Milestone **001 — Foundation** (`M001`). This repository currently contains the
technical foundation of the game, not the game itself.

| | |
|---|---|
| Engine | **Godot 4.4.1-stable** (pinned, see `docs/DECISIONS.md`) |
| Language | GDScript |
| Primary target | Android |
| Default renderer | Mobile (Compatibility as fallback) |
| Main scene | `res://scenes/main/main.tscn` |
| Status | Ready for review |

---

## What this milestone delivers

- A real, openable Godot 4 project.
- A **flat 1500 × 1500 meter** ground plane centred at `(0, 0, 0)`, at `Y = 0`.
- A collision body whose footprint matches the ground exactly.
- A **15 × 15 logical region grid** (225 regions of 100 × 100 m) implemented as
  a small, tested utility — no 225 scene nodes, no fake streaming.
- A runnable main scene with a neutral environment, one directional light and a
  temporary elevated debug camera.
- A debug HUD showing world size, camera position and the current region.
- A headless validation runner and unit tests (see [Testing](#testing)).
- Documentation for the vision, architecture, world design, art direction,
  performance budget, asset licensing, test plan and build status.

Explicitly **out of scope** for M001: combat, quests, inventory, monsters, the
final player character, the third-person camera rig, region streaming and all
final art assets.

---

## Requirements

- **Godot 4.4.1-stable** (Linux editor or Windows/macOS equivalent). The project
  is pinned to this version; see `docs/DECISIONS.md` for the rationale and the
  alternative (4.7.2-stable).
- No external add-ons or dependencies are required to open or run the project.
- Android export additionally needs JDK 17, the Android SDK and Godot export
  templates. This milestone only **inspects** that tooling; it does not export.
  See `docs/BUILD_STATUS.md`.

---

## Quick start

### Open in the editor

```bash
# From the repository root, with Godot 4.4.1 on PATH:
godot --path . --editor
```

### Run the game (desktop)

```bash
godot --path .
```

### Run the validation suite headless

```bash
godot --headless --path . --script res://tests/run_tests.gd
echo "exit code: $?"
```

Expected result: every check passes and the exit code is `0`.

---

## Project structure

```
ELYNDRA/
├── project.godot              # Godot project config (main scene, renderer)
├── README.md
├── CHANGELOG.md
├── .gitignore                 # Godot 4 policy; no secrets, no keystores
├── scenes/
│   ├── main/main.tscn         # startup scene (world, light, camera, HUD)
│   ├── world/world_ground.tscn# flat 1500 x 1500 m ground + collision
│   └── debug/debug_hud.tscn   # temporary debug overlay
├── scripts/
│   ├── core/world_regions.gd  # region grid utility (constants + functions)
│   ├── world/world_ground.gd  # ground dimension reporter
│   ├── debug/debug_hud.gd     # debug overlay logic
│   └── main/main.gd           # startup wiring + ground validation
├── tests/
│   ├── run_tests.gd           # headless SceneTree runner
│   ├── region_tests.gd        # world_regions.gd unit tests
│   └── scene_tests.gd         # scene structure/dimension checks
├── assets/                    # future assets only; see assets/README.md
└── docs/                      # all project documentation
```

Empty asset sub-folders are intentionally **not** created. Git does not track
empty directories, and M001 has no final assets. See `assets/README.md` for the
planned layout.

---

## Testing

The validation suite is plain GDScript (no framework). It runs the region unit
tests and then loads the main scene and checks node structure, mesh size,
transform, collision dimensions and missing resources.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

Full details, including which checks could and could not be run in the build
environment, are in `docs/TEST_PLAN.md` and `docs/BUILD_STATUS.md`.

---

## Documentation

| Document | Purpose |
|---|---|
| `docs/PROJECT_VISION.md` | Game concept and long-term vision |
| `docs/TECHNICAL_ARCHITECTURE.md` | Engine, units, coordinates, scene/folder architecture |
| `docs/WORLD_DESIGN.md` | Exact world dimensions, boundaries, region formulas |
| `docs/ART_DIRECTION.md` | Artistic intent (no final assets yet) |
| `docs/PERFORMANCE_BUDGET.md` | Android performance strategy and risks |
| `docs/ASSET_LICENSES.md` | Asset register template and acquisition policy |
| `docs/TEST_PLAN.md` | Test cases and how to run them |
| `docs/BUILD_STATUS.md` | Actual build/validation status and Android readiness |
| `docs/DECISIONS.md` | Engineering decisions with rationale |
| `docs/MILESTONE_TRACKER.md` | Milestone task table |

---

## Android status

Renderer: **Mobile**. Android export tooling is **not verified** in this
milestone. See `docs/BUILD_STATUS.md` and `docs/PERFORMANCE_BUDGET.md`.

## License

No third-party assets are included in M001. Future assets must be recorded in
`docs/ASSET_LICENSES.md` before use.
