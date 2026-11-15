## DebugHUD
##
## Temporary on-screen debug information for Milestone 001.
##
## Shows the world size, the camera position and the logical region under the
## camera. This is a debug aid, not a final UI.
class_name DebugHUD
extends CanvasLayer

# Preloaded (instead of relying on the global class name) so this script also
# works before the editor has built the global class cache.
const Regions = preload("res://scripts/core/world_regions.gd")

@onready var _label: Label = $Label

var _camera: Camera3D = null


## Attach the camera whose position should be reported.
func setup(camera: Camera3D) -> void:
	_camera = camera


func _process(_delta: float) -> void:
	if _label == null:
		return
	var lines: Array[String] = [
		"ELYNDRA - Milestone 001 debug",
		"World: %.0f x %.0f m   Regions: %d x %d (%d)" % [
			Regions.WORLD_SIZE, Regions.WORLD_SIZE,
			Regions.REGION_COUNT_X, Regions.REGION_COUNT_Z,
			Regions.TOTAL_REGION_COUNT,
		],
	]
	if _camera != null:
		var position := _camera.global_position
		var region := Regions.world_to_region(position)
		lines.append("Camera: (%.1f, %.1f, %.1f)" % [position.x, position.y, position.z])
		if region == Regions.INVALID_REGION:
			lines.append("Region: outside world bounds")
		else:
			lines.append("Region: %s   center: %s" % [
				str(region), str(Regions.region_center(region))
			])
	_label.text = "\n".join(PackedStringArray(lines))
