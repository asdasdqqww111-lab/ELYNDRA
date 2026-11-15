## WorldGround
##
## The initial flat ground of ELYNDRA.
##
## This script exposes the real dimensions of the ground mesh and its
## collision shape so the debug HUD and the validation tests can read them.
## It changes nothing at runtime; it only reports what is actually there.
class_name WorldGround
extends StaticBody3D

## The intended PlaneMesh size (X, Z) in meters.
const EXPECTED_MESH_SIZE := Vector2(1500.0, 1500.0)
## The intended collision footprint (X, Z) in meters.
const EXPECTED_COLLISION_SIZE := Vector2(1500.0, 1500.0)

@onready var _mesh_instance: MeshInstance3D = $GroundMesh
@onready var _collision: CollisionShape3D = $GroundCollision


## Return the PlaneMesh size currently on disk, or Vector2.ZERO.
func get_mesh_size() -> Vector2:
	if _mesh_instance != null and _mesh_instance.mesh is PlaneMesh:
		return (_mesh_instance.mesh as PlaneMesh).size
	return Vector2.ZERO


## Return the collision box size currently on disk, or Vector3.ZERO.
func get_collision_size() -> Vector3:
	if _collision != null and _collision.shape is BoxShape3D:
		return (_collision.shape as BoxShape3D).size
	return Vector3.ZERO


## Return true when the mesh and the collision footprint match the spec.
func is_valid() -> bool:
	var collision := get_collision_size()
	return get_mesh_size().is_equal_approx(EXPECTED_MESH_SIZE) \
		and Vector2(collision.x, collision.z).is_equal_approx(EXPECTED_COLLISION_SIZE)
