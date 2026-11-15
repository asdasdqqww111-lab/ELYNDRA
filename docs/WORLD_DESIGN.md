# ELYNDRA — World Design

This document is the authoritative source for world dimensions and region
mathematics in Milestone 001.

## 1. World dimensions

| Property | Value |
|---|---|
| Width on X | **exactly 1500 meters** |
| Width on Z | **exactly 1500 meters** |
| Centre | **X = 0, Z = 0** |
| Ground height | **Y = 0** |
| X bounds | **-750 to +750** |
| Z bounds | **-750 to +750** |
| Area | 2.25 km² |

The initial ground is **perfectly flat**. No hills, mountains, valleys, slopes,
random deformation or terrain sculpting. Any verticality is future work.

## 2. Implementation

- Mesh: `PlaneMesh` with `size = Vector2(1500, 1500)` and
  `orientation = FACE_Y` (the XZ ground plane).
- Transform: identity; the plane is centred on the origin by construction.
- Collision: `StaticBody3D` + `CollisionShape3D` with a `BoxShape3D` of
  `Vector3(1500, 1, 1500)` positioned so its top surface is exactly `Y = 0`
  (shape origin at `Y = -0.5`).
- The collision footprint therefore matches the ground in X and Z.

Verification is automated: `tests/scene_tests.gd` reads the live node
properties and checks the mesh size, orientation, transform and collision size.

## 3. Region grid

The world is partitioned **logically**, not with scene nodes.

| Property | Value |
|---|---|
| Regions along X | 15 |
| Regions along Z | 15 |
| Region size | **100 × 100 meters** |
| Total regions | **225** |

### Indexing convention

- Region indices are `Vector2i(x, y)` with `x, y ∈ [0, 14]`.
- Region `(0, 0)` is the **south-west** corner.
- The `y` index maps to the world **Z** axis.
- Bounds are **half-open**: `-750` is inclusive, `+750` is exclusive.

### Formulas

```
region_index.x = floor((position.x + 750) / 100)
region_index.y = floor((position.z + 750) / 100)

region_center.x = -750 + index.x * 100 + 50
region_center.z = -750 + index.y * 100 + 50
region_center.y = 0
```

### Boundary behaviour

- A position is converted to an index, then validated.
- If the index is outside `0..14` on either axis, `world_to_region()` returns
  `Vector2i(-1, -1)` (`WorldRegions.INVALID_REGION`).
- Positions are **never clamped** into the grid.
- `region_center()` returns a `Vector3` filled with `NAN` for an invalid index.

### Examples

| World position (X, Z) | Region | Region centre (X, Z) |
|---|---|---|
| (-750, -750) | (0, 0) | (-700, -700) |
| (0, 0) | (7, 7) | (0, 0) |
| (749.999, 749.999) | (14, 14) | (700, 700) |
| (750, 0) | invalid (-1, -1) | NAN |
| (-50, 0) | (7, 7) | (0, 0) |
| (-50.0001, 0) | (6, 7) | (-100, 0) |

## 4. Code

`scripts/core/world_regions.gd` exposes:

```gdscript
WorldRegions.REGION_SIZE        # 100.0
WorldRegions.REGION_COUNT_X     # 15
WorldRegions.REGION_COUNT_Z     # 15
WorldRegions.WORLD_SIZE         # 1500.0
WorldRegions.WORLD_HALF_SIZE    # 750.0
WorldRegions.TOTAL_REGION_COUNT # 225

WorldRegions.world_to_region(position: Vector3) -> Vector2i
WorldRegions.region_center(index: Vector2i) -> Vector3
WorldRegions.is_region_valid(index: Vector2i) -> bool
```

There are **no** region scene nodes and **no** streaming in this milestone.

## 5. Future streaming concept (not implemented)

The 15 × 15 grid is designed so that a future streaming system can:

1. Track the player's region from `world_to_region(player.global_position)`.
2. Load only the regions within a chosen visibility radius.
3. Use `region_center(index)` to place region content.
4. Use the region index as a stable key for save data and world-state records.

Streaming, LOD, culling and region content are explicitly out of scope for
Milestone 001. Nothing in this repository pretends to stream.
