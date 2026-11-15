# ELYNDRA — Build Status

Last updated: **2026-11-15**
Engine under test: **Godot 4.4.1-stable** (`4.4.1.stable.custom_build`)

This document reports what was **actually** executed and observed. Anything not
executed is marked **NOT RUN**.

---

## A. Environment audit

| Item | Result |
|---|---|
| Workspace before work | Git repository with a single `README.md` (10 bytes); no Godot project |
| Godot editor (pre-installed) | **Not installed**; no binary anywhere on the system |
| Git | 2.39.5 |
| GitHub connection | Connected as `asdasdqqww111-lab`; remote `https://github.com/asdasdqqww111-lab/ELYNDRA.git` |
| Disk | 20 GB free |
| OS | Debian GNU/Linux 12 (bookworm), x86_64, 2 CPUs, 3.8 GB RAM |
| Java JDK | **Not installed** |
| Android SDK / build tools / platform | **Not installed** |
| Godot export templates | **Not installed** |
| Signing keystore | **None** (none created; none should be committed) |
| Outbound network | GitHub, npm and PyPI allowed; GitHub release-asset hosts (`objects.githubusercontent.com`, `release-assets.githubusercontent.com`) **blocked** |

### Engine used for validation

No official Godot editor binary could be downloaded (release assets are on a
blocked host). A **headless-only Godot 4.4.1 editor was built from the official
source tarball** in the sandbox to run the validations:

```
scons platform=linuxbsd target=editor arch=x86_64 dev_build=no debug_symbols=no \
      lto=none optimize=speed vulkan=yes opengl3=no x11=no wayland=no alsa=no \
      pulseaudio=no dbus=no speechd=no fontconfig=no udev=no libdecor=no \
      touch=no use_sowrap=no openxr=no -j2
```

Build result: **success**, `bin/godot.linuxbsd.editor.x86_64`, version string
`4.4.1.stable.custom_build`, elapsed 50 m 13 s.

This is a **verification-only, sandbox-local** build. It is not part of the
repository and is not a shipped artifact. Known build-related messages:
`libxkbcommon` not found (dead-key support disabled) and `fontconfig` not found
(system font support disabled). Both are harmless for headless validation and do
not affect the project files.

---

## B. Project structure

```
ELYNDRA/
├── project.godot
├── README.md
├── CHANGELOG.md
├── .gitignore
├── assets/README.md
├── scenes/
│   ├── main/main.tscn
│   ├── world/world_ground.tscn
│   └── debug/debug_hud.tscn
├── scripts/
│   ├── core/world_regions.gd        (+ .gd.uid)
│   ├── world/world_ground.gd        (+ .gd.uid)
│   ├── debug/debug_hud.gd           (+ .gd.uid)
│   └── main/main.gd                 (+ .gd.uid)
├── tests/
│   ├── run_tests.gd                 (+ .gd.uid)
│   ├── region_tests.gd              (+ .gd.uid)
│   └── scene_tests.gd               (+ .gd.uid)
└── docs/  (10 documents)
```

Startup scene: **`res://scenes/main/main.tscn`** (set in `project.godot`).

`.gd.uid` files are Godot 4.4 script UID files generated during the import pass.
They are tracked in Git (standard practice) and are not secrets.

---

## C. World implementation

| Property | Value | Verified by |
|---|---|---|
| Mesh type | `PlaneMesh` | `tests/scene_tests.gd` |
| Mesh size | `Vector2(1500, 1500)` | scene test PASS |
| Orientation | `FACE_Y` (XZ ground plane) | scene test PASS |
| World transform | identity, origin `(0, 0, 0)` | scene test PASS |
| Collision | `StaticBody3D` + `CollisionShape3D` + `BoxShape3D(1500, 1, 1500)` | scene test PASS |
| Collision origin | `(0, -0.5, 0)` → top surface at `Y = 0` | scene test PASS |
| Unit convention | 1 unit = 1 m; X/Z ground; Y up; centre `(0,0,0)` | documented + code |

The ground is perfectly flat; no sculpting, slopes or random deformation.

---

## D. Region system

`scripts/core/world_regions.gd` (stateless utility, no scene nodes, no
streaming):

- Constants: `REGION_SIZE=100`, `REGION_COUNT_X=15`, `REGION_COUNT_Z=15`,
  `WORLD_SIZE=1500`, `WORLD_HALF_SIZE=750`, `TOTAL_REGION_COUNT=225`.
- Functions: `world_to_region()`, `region_center()`, `is_region_valid()`.
- Half-open bounds `[-750, +750)`; out-of-bounds → `Vector2i(-1, -1)`; invalid
  centre → `NAN`.
- 52 unit checks, all PASS (see E).

---

## E. Test report (actual commands and results)

### E.1 Import / project load

```
$ godot --headless --path . --import
...
update_scripts_classes: step 0: WorldRegions
update_scripts_classes: step 1: DebugHUD
update_scripts_classes: step 2: MainScene
update_scripts_classes: step 3: WorldGround
import exit=0
```

Result: **PASS**. The project loads and all four global classes register. No
script parse errors. The only messages are the sandbox-build `fontconfig`
notices described in section A.

### E.2 Validation suite

```
$ godot --headless --path . --script res://tests/run_tests.gd
...
 Total:  78
 Passed: 78
 Failed: 0
 RESULT: PASS
TEST_EXIT=0
```

Result: **PASS** — 78/78.

| Group | Checks | Passed | Failed |
|---|---|---|---|
| Region utility unit tests | 52 | 52 | 0 |
| Scene validation | 26 | 26 | 0 |

The scene validation also printed the game's own startup line, proving the main
scene instantiates and runs:

```
ELYNDRA: world ready - 1500 x 1500 m, 225 logical regions
```

### E.3 Headless launch smoke test

```
$ godot --headless --path . --quit-after 5
Godot Engine v4.4.1.stable.custom_build - https://godotengine.org

ELYNDRA: world ready - 1500 x 1500 m, 225 logical regions
LAUNCH_EXIT=0
```

Result: **PASS**. The startup scene launches headless and exits cleanly.

### E.4 Error / warning scan

A full capture of the test run and the launch run was scanned for
`ERROR|WARNING|SCRIPT ERROR|Parse Error|Invalid|Failed`. The only match was the
summary line `Failed: 0`. No project errors or warnings were observed.

### E.5 Checks NOT RUN

| Check | Reason |
|---|---|
| Android export (APK/AAB) | Milestone is inspection-only; no Android SDK/JDK/templates present |
| Physical device run | No Android device available |
| GPU rendering / visual screenshot | Sandbox build is headless-only (no X11/Wayland/GL); not a project limitation |
| Official Godot editor binary | Release assets unreachable from the sandbox; source build used instead |

---

## F. Android readiness (inspection only — no export performed)

### Detected tooling

| Component | Detected |
|---|---|
| Java JDK | No |
| Android SDK | No |
| Android build tools / platforms | No |
| Godot export templates | No |
| Signing keystore | No (none created) |

### Requirements for the selected Godot version (4.4.1-stable)

Verified against the official Godot source
(`platform/android/java/app/config.gradle`,
`platform/android/java/gradle/wrapper/gradle-wrapper.properties`,
`platform/android/export/export_plugin.cpp` at tag `4.4.1-stable`):

| Requirement | Godot 4.4.1 |
|---|---|
| JDK | **17** (`JavaVersion.VERSION_17`) |
| Android Gradle Plugin | **8.2.0** |
| Gradle | **8.2** |
| compileSdk | **34** |
| targetSdk | **34** |
| minSdk | **21** (OpenGL/Compatibility), **24** (Vulkan/Mobile default) |
| build-tools | **34.0.0** |
| NDK | 23.2.8568313 (only for source builds; not needed for export) |
| Export templates | `Godot_v4.4.1-stable_export_templates.tpz` |

For comparison, Godot 4.7.2-stable requires AGP 8.6.1, Gradle 8.11.1,
compileSdk/targetSdk 36, build-tools 36.1.0, minSdk 24 (Vulkan), JDK 17.

### Renderer

- Default: **Mobile** (`rendering/renderer_method="mobile"`).
- Fallback: **Compatibility** (`gl_compatibility`) for devices that cannot run
  Mobile. Effective `minSdk` is 21 with Compatibility and 24 with Mobile.

### Required user-side actions (for a later Android milestone)

1. Install **JDK 17**.
2. Install the **Android SDK command-line tools**, **build-tools 34.0.0** and
   **platform android-34**.
3. Install the **Godot 4.4.1 export templates** (`--headless --doctool`? no —
   via Editor → Manage Export Templates, or copy the `.tpz`).
4. Create a signing keystore **locally** and never commit it.
5. Set up `export_presets.cfg` and `export_credentials.cfg` (gitignored).

### Not verified

- No APK/AAB was produced.
- No device or emulator run was performed.
- Android export is **NOT VERIFIED** and must not be claimed as such.

---

## G. Git

| Item | Value |
|---|---|
| Branch | `arena/2b36389d-elyndra` (see decision D-009) |
| Base | `main` @ `c173e8a` |
| Working tree | Clean after commits |
| Secrets committed | None |

---

## H. Known issues and risks

1. **Sandbox engine build.** Validation used a custom headless build, not an
   official editor binary. It is API-identical for the tested features but is
   not an official distribution.
2. **No Android verification.** Renderer choice and Android settings are
   reasoned, not device-tested.
3. **No fontconfig in the sandbox build.** Only affects system-font lookup in
   the sandbox; irrelevant to the project.
4. **Camera is temporary.** The elevated debug camera is not the final
   third-person camera.
5. **No streaming.** The 15×15 grid is logical only; filling the world without
   streaming will break the performance budget.
6. **Asset pipeline empty.** No textures, models or audio; performance targets
   are unmeasured.
