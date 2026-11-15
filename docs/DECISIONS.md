# ELYNDRA — Engineering Decisions

Format: **ID — Title**. Each entry records the decision, rationale, date and
status. Dates use the project local date (2026-11-15).

Status values: `ACCEPTED`, `SUPERSEDED`, `OPEN`.

---

## D-001 — Pin Godot 4.4.1-stable

- **Decision:** Use **Godot 4.4.1-stable** as the project engine. Minimum
  supported version is the same.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:**
  - Mature stable patch with extensive community documentation, which matters
    for a solo beginner developer.
  - Lower Android requirements than the newest stable branch (compileSdk 34,
    build-tools 34.0.0, minSdk 21) versus 4.7.2 (compileSdk 36, build-tools
    36.1.0, minSdk 24). This makes the toolchain easier to install and supports
    older devices.
  - Verified against the official Godot source for 4.4-stable/4.7-stable
    (`platform/android/java/app/config.gradle`,
    `platform/android/export/export_plugin.cpp`).
- **Alternatives considered:** Godot 4.7.2-stable (latest stable at the time).
  Upgrading later is possible; the requirement changes are recorded in
  `BUILD_STATUS.md`.
- **Constraints:** Do not change the engine version to solve an API problem
  without documenting the alternative and getting approval.

---

## D-002 — Mobile renderer by default, Compatibility fallback

- **Decision:** Default renderer is **Mobile** on Android. **Compatibility**
  (GL Compatibility) is the documented fallback for low-end devices.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** Mobile is designed for mid-range Android GPUs; Forward+ is a
  high-end desktop renderer and is not the right default. Compatibility provides
  the broadest device coverage when Mobile is too expensive or unsupported.
- **Constraints:** Forward+ may only be selected with a documented requirement
  and verified target hardware. See `PERFORMANCE_BUDGET.md`.

---

## D-003 — 1 unit = 1 meter; XZ ground plane; Y up

- **Decision:** Adopt an explicit project-wide convention:
  `1 Godot unit = 1 meter`, X = east/west, Y = up, Z = north/south, world centre
  `(0,0,0)`.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** A single explicit convention prevents scale and orientation
  bugs across scenes, scripts and imported assets. Documented in
  `TECHNICAL_ARCHITECTURE.md`, `WORLD_DESIGN.md` and this file.
- **Constraints:** All future dimensions and scripts must follow it.

---

## D-004 — PlaneMesh + thin BoxShape3D collision

- **Decision:** The flat ground uses `PlaneMesh` (`size = (1500,1500)`,
  `orientation = FACE_Y`) plus a `StaticBody3D`/`CollisionShape3D` with a
  `BoxShape3D` of `1500 x 1 x 1500`, top surface at `Y = 0`.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** PlaneMesh is the simplest correct ground primitive. A thin box
  gives a robust collision slab whose XZ footprint exactly matches the plane.
  An infinite `WorldBoundaryShape3D` was rejected because it does not match the
  1500 m footprint.
- **Constraints:** Collision must keep matching the mesh footprint if the world
  size ever changes.

---

## D-005 — Region grid as a stateless utility class

- **Decision:** `scripts/core/world_regions.gd` is a `class_name` +
  `RefCounted` utility with constants and `static` functions. It creates **no
  scene nodes** and performs **no streaming**.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** The region grid is pure math. A node tree of 225 regions would
  be wasteful and would create a false impression of streaming. A stateless
  utility is testable headlessly and cheap to call.
- **Constraints:** Do not add streaming logic in M001.

---

## D-006 — Half-open world bounds; explicit invalid region

- **Decision:** Bounds are `[-750, +750)` on X and Z. `world_to_region()`
  returns `Vector2i(-1, -1)` for out-of-bounds positions and never clamps.
  `region_center()` returns a `NAN` vector for invalid indices.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** Half-open bounds make region assignment unambiguous at edges
  and match the "exact positive maximum boundary" requirement. An explicit
  invalid sentinel prevents silent, hard-to-debug clamping.

---

## D-007 — Plain-GDScript test runner, no framework

- **Decision:** Use a custom `SceneTree` runner with `static` test modules.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** No external dependency, no install step, works with
  `godot --headless --script`, and is easy for a beginner to read. A framework
  would add maintenance and version-compatibility risk for little benefit at
  this size.

---

## D-008 — No export presets or signing material in M001

- **Decision:** M001 does not create `export_presets.cfg` or any keystore, and
  performs no Android export.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** The milestone is an inspection/configuration milestone. Adding
  export configuration before the Android toolchain exists would create
  untested, potentially secret-bearing files.
- **Constraints:** `export_presets.cfg` is **not** gitignored (it holds no
  secrets by default) and will be added in an approved Android milestone.
  Keystores and `export_credentials.cfg` are gitignored and must never be
  committed.

---

## D-009 — Branch name deviation

- **Decision:** Work happens on the Arena-managed branch
  `arena/2b36389d-elyndra`, not on `milestone-001-foundation`.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** The Arena session tracks one fixed working branch; it cannot
  be renamed or replaced. The milestone content is identical to what was
  requested.
- **Constraints:** All commits and the pull request use this branch.

---

## D-010 — Headless verification build is sandbox-only

- **Decision:** To obtain real test evidence, a headless Godot 4.4.1 editor was
  built from the official source tarball inside the sandbox, with all
  system-library features disabled. It is **not** part of the repository.
- **Date:** 2026-11-15
- **Status:** ACCEPTED
- **Rationale:** The sandbox had no Godot binary and GitHub release assets were
  unreachable. Building from the official source was the only way to run the
  required validations. The binary lives outside the repository and is not
  committed.
- **Constraints:** The build is for verification only. It is not a shipped
  artifact and must not be treated as an official Godot distribution.
