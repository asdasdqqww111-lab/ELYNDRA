## RegionTests
##
## Unit tests for scripts/core/world_regions.gd.
##
## Pure GDScript, no framework. Each test returns a dictionary with:
##   name, passed, expected, actual
## Run with tests/run_tests.gd.
extends RefCounted

# Preloaded so the tests run with `godot --headless --script` even before the
# editor has built the global class cache.
const Regions = preload("res://scripts/core/world_regions.gd")


static func run() -> Array[Dictionary]:
	var r: Array[Dictionary] = []

	# --- Constants -----------------------------------------------------------
	_check_float(r, "REGION_SIZE == 100.0", Regions.REGION_SIZE, 100.0)
	_check_int(r, "REGION_COUNT_X == 15", Regions.REGION_COUNT_X, 15)
	_check_int(r, "REGION_COUNT_Z == 15", Regions.REGION_COUNT_Z, 15)
	_check_float(r, "WORLD_SIZE == 1500.0", Regions.WORLD_SIZE, 1500.0)
	_check_float(r, "WORLD_HALF_SIZE == 750.0", Regions.WORLD_HALF_SIZE, 750.0)
	_check_int(r, "TOTAL_REGION_COUNT == 225", Regions.TOTAL_REGION_COUNT, 225)
	_check_bool(
		r,
		"REGION_COUNT_X * REGION_COUNT_Z == TOTAL_REGION_COUNT",
		Regions.REGION_COUNT_X * Regions.REGION_COUNT_Z == Regions.TOTAL_REGION_COUNT,
		true
	)

	# --- Four world corners (inside the half-open bounds) --------------------
	_check_region(r, "SW corner (-750, -750)", Vector3(-750, 0, -750), Vector2i(0, 0))
	_check_region(r, "SE corner (749.999, -750)", Vector3(749.999, 0, -750), Vector2i(14, 0))
	_check_region(r, "NW corner (-750, 749.999)", Vector3(-750, 0, 749.999), Vector2i(0, 14))
	_check_region(r, "NE corner (749.999, 749.999)", Vector3(749.999, 0, 749.999), Vector2i(14, 14))

	# --- World center --------------------------------------------------------
	_check_region(r, "world center (0, 0)", Vector3(0, 0, 0), Vector2i(7, 7))

	# --- Region boundary transitions (half-open: lower edge belongs to region) -
	_check_region(r, "x = -50.0 belongs to region 7", Vector3(-50.0, 0, 0), Vector2i(7, 7))
	_check_region(r, "x = -50.0001 belongs to region 6", Vector3(-50.0001, 0, 0), Vector2i(6, 7))
	_check_region(r, "x = 50.0 belongs to region 8", Vector3(50.0, 0, 0), Vector2i(8, 7))
	_check_region(r, "x = 49.9999 belongs to region 7", Vector3(49.9999, 0, 0), Vector2i(7, 7))
	_check_region(r, "z = -50.0 belongs to region 7", Vector3(0, 0, -50.0), Vector2i(7, 7))
	_check_region(r, "z = -50.0001 belongs to region 6", Vector3(0, 0, -50.0001), Vector2i(7, 6))
	_check_region(r, "z = 50.0 belongs to region 8", Vector3(0, 0, 50.0), Vector2i(7, 8))
	_check_region(r, "z = 49.9999 belongs to region 7", Vector3(0, 0, 49.9999), Vector2i(7, 7))
	_check_region(r, "x = -650 belongs to region 1", Vector3(-650, 0, 0), Vector2i(1, 7))
	_check_region(r, "x = 650 belongs to region 14", Vector3(650, 0, 0), Vector2i(14, 7))
	_check_region(r, "z = -650 belongs to region 1", Vector3(0, 0, -650), Vector2i(7, 1))
	_check_region(r, "z = 650 belongs to region 14", Vector3(0, 0, 650), Vector2i(7, 14))

	# --- Negative coordinates ------------------------------------------------
	_check_region(r, "negative (-300, -200)", Vector3(-300, 0, -200), Vector2i(4, 5))
	_check_region(r, "negative (-1, -1)", Vector3(-1, 0, -1), Vector2i(7, 7))
	_check_region(r, "negative (-749.999, -749.999)", Vector3(-749.999, 0, -749.999), Vector2i(0, 0))
	_check_region(r, "negative (-750, 0)", Vector3(-750, 0, 0), Vector2i(0, 7))

	# --- Exact positive maximum boundary (exclusive -> invalid) ---------------
	_check_region(r, "x = 750 is outside", Vector3(750, 0, 0), Vector2i(-1, -1))
	_check_region(r, "z = 750 is outside", Vector3(0, 0, 750), Vector2i(-1, -1))
	_check_region(r, "(750, 750) is outside", Vector3(750, 0, 750), Vector2i(-1, -1))
	_check_region(r, "x = -750.0001 is outside", Vector3(-750.0001, 0, 0), Vector2i(-1, -1))

	# --- Invalid indices -----------------------------------------------------
	_check_bool(r, "is_region_valid(-1, 0) == false", Regions.is_region_valid(Vector2i(-1, 0)), false)
	_check_bool(r, "is_region_valid(0, -1) == false", Regions.is_region_valid(Vector2i(0, -1)), false)
	_check_bool(r, "is_region_valid(15, 0) == false", Regions.is_region_valid(Vector2i(15, 0)), false)
	_check_bool(r, "is_region_valid(0, 15) == false", Regions.is_region_valid(Vector2i(0, 15)), false)
	_check_bool(r, "is_region_valid(-1, -1) == false", Regions.is_region_valid(Vector2i(-1, -1)), false)
	_check_bool(r, "is_region_valid(0, 0) == true", Regions.is_region_valid(Vector2i(0, 0)), true)
	_check_bool(r, "is_region_valid(7, 7) == true", Regions.is_region_valid(Vector2i(7, 7)), true)
	_check_bool(r, "is_region_valid(14, 14) == true", Regions.is_region_valid(Vector2i(14, 14)), true)

	# --- Region center calculations ------------------------------------------
	_check_center(r, "center(0, 0)", Vector2i(0, 0), Vector3(-700, 0, -700))
	_check_center(r, "center(7, 7)", Vector2i(7, 7), Vector3(0, 0, 0))
	_check_center(r, "center(14, 14)", Vector2i(14, 14), Vector3(700, 0, 700))
	_check_center(r, "center(0, 14)", Vector2i(0, 14), Vector3(-700, 0, 700))
	_check_center(r, "center(14, 0)", Vector2i(14, 0), Vector3(700, 0, -700))
	_check_center(r, "center(1, 2)", Vector2i(1, 2), Vector3(-600, 0, -500))
	_check_center_nan(r, "center(-1, -1) is NAN", Vector2i(-1, -1))

	# --- Round trip: center of the returned region is near the position ------
	var samples := [
		Vector3(0, 0, 0),
		Vector3(-749.0, 0, -749.0),
		Vector3(749.0, 0, 749.0),
		Vector3(123.4, 0, -456.7),
		Vector3(-321.0, 0, 654.0),
	]
	for i in samples.size():
		var p: Vector3 = samples[i]
		var idx := Regions.world_to_region(p)
		var c := Regions.region_center(idx)
		var passed := Regions.is_region_valid(idx) \
			and absf(c.x - p.x) <= Regions.REGION_SIZE * 0.5 \
			and absf(c.z - p.z) <= Regions.REGION_SIZE * 0.5
		_add(r, "round trip %d: center within its region" % i, passed, "within 50 m", str(c))

	return r


# --- helpers ---------------------------------------------------------------

static func _add(r: Array[Dictionary], test_name: String, passed: bool, expected: String, actual: String) -> void:
	r.append({
		"name": test_name,
		"passed": passed,
		"expected": expected,
		"actual": actual,
	})


static func _check_float(r: Array[Dictionary], test_name: String, actual: float, expected: float) -> void:
	_add(r, test_name, is_equal_approx(actual, expected), str(expected), str(actual))


static func _check_int(r: Array[Dictionary], test_name: String, actual: int, expected: int) -> void:
	_add(r, test_name, actual == expected, str(expected), str(actual))


static func _check_bool(r: Array[Dictionary], test_name: String, actual: bool, expected: bool) -> void:
	_add(r, test_name, actual == expected, str(expected), str(actual))


static func _check_region(r: Array[Dictionary], test_name: String, position: Vector3, expected: Vector2i) -> void:
	var actual := Regions.world_to_region(position)
	_add(r, test_name, actual == expected, str(expected), str(actual))


static func _check_center(r: Array[Dictionary], test_name: String, index: Vector2i, expected: Vector3) -> void:
	var actual := Regions.region_center(index)
	_add(r, test_name, actual.is_equal_approx(expected), str(expected), str(actual))


static func _check_center_nan(r: Array[Dictionary], test_name: String, index: Vector2i) -> void:
	var actual := Regions.region_center(index)
	_add(r, test_name, actual.x != actual.x, "NAN", str(actual))
