# Changelog

All notable changes to ELYNDRA are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-11-15

### Milestone 001 — Foundation

#### Added
- Godot 4.4.1-stable project configuration with the Mobile renderer as the
  Android default.
- Flat 1500 × 1500 meter ground (`PlaneMesh`) centred at `(0, 0, 0)`, `Y = 0`,
  with a matching `StaticBody3D` / `BoxShape3D` collision footprint.
- `scripts/core/world_regions.gd`: 15 × 15 logical region utility with
  constants, `world_to_region()`, `region_center()` and `is_region_valid()`.
- Runnable main scene with a neutral `WorldEnvironment`, one
  `DirectionalLight3D` (shadows off) and a temporary elevated debug camera.
- Temporary debug HUD showing world size, camera position and current region.
- Headless validation runner (`tests/run_tests.gd`), region unit tests
  (`tests/region_tests.gd`) and scene validation (`tests/scene_tests.gd`).
- Godot 4 `.gitignore` covering `.godot/`, build artifacts, keystores and
  `export_credentials.cfg`.
- Documentation set: vision, technical architecture, world design, art
  direction, performance budget, asset licenses, test plan, build status,
  decisions and milestone tracker.

#### Notes
- No combat, quests, inventory, monsters, final characters, third-person
  camera or region streaming. Those are future milestones.
- Android export is inspection-only in this milestone; no APK/AAB was produced.
