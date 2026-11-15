## SceneTests
##
## Validates the Milestone 001 main scene: node structure, ground dimensions,
## collision footprint and environment/light/camera presence.
##
## Pure GDScript, no framework. Run with tests/run_tests.gd.
extends RefCounted

# Preloaded so the tests run with `godot --headless --script` even before the
# editor has built the global class cache.
const Regions = preload("res://scripts/core/world_regions.gd")

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const EXPECTED_MESH_SIZE := Vector2(1500.0, 1500.0)
const EXPECTED_COLLISION_SIZE := Vector3(1500.0, 1.0, 1500.0)


static func validate(root: Node) -> Array[Dictionary]:
	var r: Array[Dictionary] = []

	# --- Project configuration ----------------------------------------------
	var setting := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	_check_string(r, "main scene setting is %s" % MAIN_SCENE_PATH, setting, MAIN_SCENE_PATH)
	_check_string(r, "loaded scene path is %s" % MAIN_SCENE_PATH, root.scene_file_path, MAIN_SCENE_PATH)

	# --- Node structure ------------------------------------------------------
	_check_bool(r, "root node is named 'Main'", root.name == "Main", true)
	_check_bool(r, "root node is Node3D", root.is_class("Node3D"), true)
	_check_node(r, root, "World", "Node3D")
	_check_node(r, root, "World/Ground", "StaticBody3D")
	_check_node(r, root, "World/WorldEnvironment", "WorldEnvironment")
	_check_node(r, root, "World/Sun", "DirectionalLight3D")
	_check_node(r, root, "World/DebugCamera", "Camera3D")
	_check_node(r, root, "DebugHUD", "CanvasLayer")

	# --- Ground --------------------------------------------------------------
	var ground := root.get_node_or_null("World/Ground")
	if ground != null:
		_check_ground(r, ground)
	else:
		_add(r, "ground checks skipped (node missing)", false, "ground", "missing")

	# --- Mesh ----------------------------------------------------------------
	var mesh_instance := root.get_node_or_null("World/Ground/GroundMesh")
	if mesh_instance != null:
		_check_mesh(r, mesh_instance)
	else:
		_add(r, "mesh checks skipped (node missing)", false, "mesh", "missing")

	# --- Collision -----------------------------------------------------------
	var collision := root.get_node_or_null("World/Ground/GroundCollision")
	if collision != null:
		_check_collision(r, collision)
	else:
		_add(r, "collision checks skipped (node missing)", false, "collision", "missing")

	# --- Environment ---------------------------------------------------------
	var env_node := root.get_node_or_null("World/WorldEnvironment")
	if env_node != null:
		var env = env_node.get("environment")
		_check_bool(r, "WorldEnvironment has an Environment", env != null, true)
	else:
		_add(r, "environment checks skipped (node missing)", false, "environment", "missing")

	# --- Missing-resource scan ----------------------------------------------
	_scan_missing_resources(r, root)

	# --- Logical region grid -------------------------------------------------
	_check_int(r, "region grid total == 225", Regions.TOTAL_REGION_COUNT, 225)

	return r


# --- ground ----------------------------------------------------------------

static func _check_ground(r: Array[Dictionary], ground: Node) -> void:
	_check_bool(r, "Ground has a script attached", ground.get_script() != null, true)
	var valid: bool = ground.call("is_valid")
	_check_bool(r, "Ground dimensions are valid (mesh + collision)", valid, true)
	_check_vec2(r, "Ground mesh size == (1500, 1500)", ground.call("get_mesh_size"), EXPECTED_MESH_SIZE)
	_check_vec3(
		r,
		"Ground collision size == (1500, 1, 1500)",
		ground.call("get_collision_size"),
		EXPECTED_COLLISION_SIZE
	)


# --- mesh ------------------------------------------------------------------

static func _check_mesh(r: Array[Dictionary], mesh_instance: Node) -> void:
	var mesh = mesh_instance.get("mesh")
	_check_bool(r, "GroundMesh has a mesh resource", mesh != null, true)
	if mesh is PlaneMesh:
		_check_vec2(r, "PlaneMesh.size == (1500, 1500)", (mesh as PlaneMesh).size, EXPECTED_MESH_SIZE)
		_check_int(r, "PlaneMesh.orientation == FACE_Y (1)", (mesh as PlaneMesh).orientation, 1)
	else:
		_add(r, "PlaneMesh.size == (1500, 1500)", false, "PlaneMesh", str(mesh))
		_add(r, "PlaneMesh.orientation == FACE_Y (1)", false, "PlaneMesh", str(mesh))

	var t: Transform3D = (mesh_instance as Node3D).global_transform
	_check_vec3(r, "GroundMesh global origin == (0, 0, 0)", t.origin, Vector3.ZERO)
	_check_bool(r, "GroundMesh global basis is identity", t.basis.is_equal_approx(Basis.IDENTITY), true)


# --- collision -------------------------------------------------------------

static func _check_collision(r: Array[Dictionary], collision: Node) -> void:
	var shape = collision.get("shape")
	_check_bool(r, "GroundCollision has a shape resource", shape != null, true)
	if shape is BoxShape3D:
		_check_vec3(
			r,
			"BoxShape3D.size == (1500, 1, 1500)",
			(shape as BoxShape3D).size,
			EXPECTED_COLLISION_SIZE
		)
	else:
		_add(r, "BoxShape3D.size == (1500, 1, 1500)", false, "BoxShape3D", str(shape))

	var t: Transform3D = (collision as Node3D).global_transform
	_check_vec3(r, "GroundCollision global origin == (0, -0.5, 0)", t.origin, Vector3(0.0, -0.5, 0.0))


# --- missing resources -----------------------------------------------------

static func _scan_missing_resources(r: Array[Dictionary], root: Node) -> void:
	var mesh_count := 0
	var script_count := 0
	for node in _all_nodes(root):
		if node is MeshInstance3D:
			mesh_count += 1
			if (node as MeshInstance3D).mesh == null:
				_add(r, "MeshInstance3D '%s' has a mesh" % node.name, false, "mesh", "null")
		if node.get_script() != null:
			script_count += 1
	_check_bool(r, "scene contains at least one MeshInstance3D", mesh_count > 0, true)
	_check_bool(r, "scene contains at least one scripted node", script_count > 0, true)


static func _all_nodes(root: Node) -> Array[Node]:
	var out: Array[Node] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		out.append(node)
		stack.append_array(node.get_children())
	return out


# --- helpers ---------------------------------------------------------------

static func _add(r: Array[Dictionary], test_name: String, passed: bool, expected: String, actual: String) -> void:
	r.append({
		"name": test_name,
		"passed": passed,
		"expected": expected,
		"actual": actual,
	})


static func _check_string(r: Array[Dictionary], test_name: String, actual: String, expected: String) -> void:
	_add(r, test_name, actual == expected, expected, actual)


static func _check_int(r: Array[Dictionary], test_name: String, actual: int, expected: int) -> void:
	_add(r, test_name, actual == expected, str(expected), str(actual))


static func _check_bool(r: Array[Dictionary], test_name: String, actual: bool, expected: bool) -> void:
	_add(r, test_name, actual == expected, str(expected), str(actual))


static func _check_vec2(r: Array[Dictionary], test_name: String, actual: Vector2, expected: Vector2) -> void:
	_add(r, test_name, actual.is_equal_approx(expected), str(expected), str(actual))


static func _check_vec3(r: Array[Dictionary], test_name: String, actual: Vector3, expected: Vector3) -> void:
	_add(r, test_name, actual.is_equal_approx(expected), str(expected), str(actual))


static func _check_node(r: Array[Dictionary], root: Node, path: String, type_name: String) -> void:
	var node := root.get_node_or_null(path)
	if node == null:
		_add(r, "node '%s' exists" % path, false, type_name, "missing")
	else:
		_add(r, "node '%s' is %s" % [path, type_name], node.is_class(type_name), type_name, node.get_class())
