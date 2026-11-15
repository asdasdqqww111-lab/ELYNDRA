## ELYNDRA - Milestone 001 validation runner.
##
## Runs headless:
##   godot --headless --path . --script res://tests/run_tests.gd
##
## The script must inherit from SceneTree (Godot requirement for --script).
## It exits with code 0 when every check passes and 1 otherwise.
extends SceneTree

const RegionTests = preload("res://tests/region_tests.gd")
const SceneTests = preload("res://tests/scene_tests.gd")

var _total := 0
var _failed := 0
var _ran := false


# The checks run on the first processed frame rather than in _initialize(),
# because the scene tree (and therefore _ready(), @onready variables and global
# transforms) is only active once the main loop is running.
func _process(_delta: float) -> bool:
	if _ran:
		return true
	_ran = true
	_run()
	return true


func _run() -> void:
	print("==================================================")
	print(" ELYNDRA - Milestone 001 validation")
	print("==================================================")

	_run_region_tests()
	_run_scene_tests()
	_print_summary()

	quit(1 if _failed > 0 else 0)


func _run_region_tests() -> void:
	print("\n--- Region utility unit tests ---")
	var results := RegionTests.run()
	for res in results:
		_report(res)


func _run_scene_tests() -> void:
	print("\n--- Scene validation ---")
	var results: Array[Dictionary] = []
	var main_scene_path := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene_path.is_empty():
		_add(results, "main scene is configured", false, "a scene path", "empty")
	else:
		var packed: PackedScene = load(main_scene_path)
		if packed == null:
			_add(results, "main scene loads", false, "PackedScene", "null")
		else:
			var instance := packed.instantiate()
			if instance == null:
				_add(results, "main scene instantiates", false, "Node", "null")
			else:
				root.add_child(instance)
				results = SceneTests.validate(instance)
				instance.free()
	for res in results:
		_report(res)


func _report(res: Dictionary) -> void:
	_total += 1
	var passed: bool = res["passed"]
	if not passed:
		_failed += 1
	var tag := "PASS" if passed else "FAIL"
	print("[%s] %s" % [tag, res["name"]])
	if not passed:
		print("        expected: %s" % res["expected"])
		print("        actual:   %s" % res["actual"])


func _print_summary() -> void:
	print("\n==================================================")
	print(" Total:  %d" % _total)
	print(" Passed: %d" % (_total - _failed))
	print(" Failed: %d" % _failed)
	print(" RESULT: %s" % ("PASS" if _failed == 0 else "FAIL"))
	print("==================================================")


func _add(r: Array[Dictionary], test_name: String, passed: bool, expected: String, actual: String) -> void:
	r.append({
		"name": test_name,
		"passed": passed,
		"expected": expected,
		"actual": actual,
	})
