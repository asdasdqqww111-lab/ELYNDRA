# ELYNDRA — Test Plan

## 1. Approach

Milestone 001 uses a **lightweight custom GDScript test runner**. No test
framework dependency is introduced. The runner:

- is a `SceneTree` script (Godot requires `--script` targets to inherit from
  `SceneTree` or `MainLoop`);
- runs the region unit tests, then loads the main scene and validates it;
- prints one line per check with `PASS` / `FAIL`;
- exits with code `0` when all checks pass and `1` otherwise.

## 2. How to run

```bash
# From the repository root, with Godot 4.4.1 on PATH:
godot --headless --path . --script res://tests/run_tests.gd
echo "exit code: $?"
```

Other useful commands:

```bash
# Import the project and report script/scene errors (editor import pass):
godot --headless --path . --import

# Run the actual game for one frame headless (startup smoke test):
godot --headless --path . --quit-after 2
```

`--quit-after` is a Godot 4 CLI option that quits after N engine iterations.

## 3. Test cases

### 3.1 Region utility (`tests/region_tests.gd`)

| Group | Cases |
|---|---|
| Constants | `REGION_SIZE`, `REGION_COUNT_X`, `REGION_COUNT_Z`, `WORLD_SIZE`, `WORLD_HALF_SIZE`, `TOTAL_REGION_COUNT`, and `X*Z == TOTAL` |
| World corners | `(-750,-750)`, `(749.999,-750)`, `(-750,749.999)`, `(749.999,749.999)` |
| World centre | `(0,0)` → region `(7,7)` |
| Boundary transitions | `-50 / -50.0001`, `50 / 49.9999` on X and Z; `-650`, `650` |
| Negative coordinates | `(-300,-200)`, `(-1,-1)`, `(-749.999,-749.999)`, `(-750,0)` |
| Exact positive maximum | `(750,0)`, `(0,750)`, `(750,750)` → invalid |
| Outside minimum | `(-750.0001,0)` → invalid |
| Invalid indices | `(-1,0)`, `(0,-1)`, `(15,0)`, `(0,15)`, `(-1,-1)` false; `(0,0)`, `(7,7)`, `(14,14)` true |
| Region centres | `(0,0)`, `(7,7)`, `(14,14)`, `(0,14)`, `(14,0)`, `(1,2)`; invalid → NAN |
| Round trip | centre of the returned region is within 50 m of the input position |

### 3.2 Scene validation (`tests/scene_tests.gd`)

| Check | Expected |
|---|---|
| Main scene setting | `res://scenes/main/main.tscn` |
| Loaded scene path | `res://scenes/main/main.tscn` |
| Nodes | `Main`, `World`, `World/Ground`, `World/WorldEnvironment`, `World/Sun`, `World/DebugCamera`, `DebugHUD` |
| Ground script | present, `is_valid()` true |
| PlaneMesh | `size == (1500,1500)`, `orientation == FACE_Y` |
| GroundMesh transform | origin `(0,0,0)`, identity basis |
| Collision | `BoxShape3D`, `size == (1500,1,1500)`, origin `(0,-0.5,0)` |
| Environment | present and non-null |
| Region grid | 225 |
| Missing resources | no `MeshInstance3D` without a mesh; at least one mesh and one script |

### 3.3 Project-level checks (performed by the build/CI, recorded in BUILD_STATUS.md)

1. Project loads in Godot headless mode.
2. GDScript parsing succeeds (no script errors).
3. Main scene is configured as the startup scene.
4. Main scene launches headless (`--quit-after`).
5. No missing resources or broken references reported by Godot.

## 4. What can and cannot be tested here

The test environment used for this milestone had **no Godot editor binary
available** and no Android tooling. A headless Godot editor was built from the
official 4.4.1 source in the sandbox to run the checks. See `BUILD_STATUS.md`
for the exact commands, results and anything that could not be run.

Rules observed:

- Tests that cannot run are reported as **NOT RUN**, never as passed.
- Godot's own stderr output is treated as evidence, not filtered out.
- No test result is fabricated.

## 5. Future tests (later milestones)

- Streaming stress tests (region load/unload).
- Device performance tests (frame time, memory, thermal).
- Save/load round trips.
- Combat/quest system tests once those systems exist.
- Export tests (APK/AAB) in an approved Android milestone.
