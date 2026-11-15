## WorldRegions
##
## Logical region grid for the ELYNDRA world.
##
## This is a pure utility class: it has no scene nodes, no state and no
## streaming. It only converts world positions to region indices and back.
## See docs/WORLD_DESIGN.md for the full coordinate convention.
##
## Convention (project-wide):
##   X = east/west, Y = up, Z = north/south. 1 Godot unit = 1 meter.
##   Region (0, 0) is the south-west corner of the world.
##   World bounds are half-open: -750 inclusive, +750 exclusive on X and Z.
##   Positions outside those bounds return INVALID_REGION, never a clamped
##   valid region.
class_name WorldRegions
extends RefCounted

## Size of one square region in meters.
const REGION_SIZE: float = 100.0
## Number of regions along X.
const REGION_COUNT_X: int = 15
## Number of regions along Z.
const REGION_COUNT_Z: int = 15
## Total world size in meters (X and Z).
const WORLD_SIZE: float = 1500.0
## Half of WORLD_SIZE. The world spans [-WORLD_HALF_SIZE, +WORLD_HALF_SIZE).
const WORLD_HALF_SIZE: float = 750.0
## Total number of logical regions (15 * 15).
const TOTAL_REGION_COUNT: int = 225

## Sentinel returned by world_to_region() for positions outside the world.
const INVALID_REGION: Vector2i = Vector2i(-1, -1)


## Convert a world position to a region index.
##
## The Y coordinate is ignored because regions are a 2D partition of the XZ
## ground plane. Returns INVALID_REGION (-1, -1) when the position is outside
## the world bounds; the value is never silently clamped into the grid.
static func world_to_region(position: Vector3) -> Vector2i:
	var x := int(floor((position.x + WORLD_HALF_SIZE) / REGION_SIZE))
	var z := int(floor((position.z + WORLD_HALF_SIZE) / REGION_SIZE))
	var index := Vector2i(x, z)
	if not is_region_valid(index):
		return INVALID_REGION
	return index


## Return the world-space center of a region at Y = 0.
##
## Formula: X = -750 + index.x * 100 + 50, Z = -750 + index.y * 100 + 50.
## Returns a Vector3 filled with NAN when the index is invalid.
static func region_center(index: Vector2i) -> Vector3:
	if not is_region_valid(index):
		return Vector3(NAN, NAN, NAN)
	var x := -WORLD_HALF_SIZE + (index.x * REGION_SIZE) + (REGION_SIZE * 0.5)
	var z := -WORLD_HALF_SIZE + (index.y * REGION_SIZE) + (REGION_SIZE * 0.5)
	return Vector3(x, 0.0, z)


## Return true when the index is inside the 15 x 15 grid (0..14 on both axes).
static func is_region_valid(index: Vector2i) -> bool:
	return index.x >= 0 and index.x < REGION_COUNT_X \
		and index.y >= 0 and index.y < REGION_COUNT_Z
