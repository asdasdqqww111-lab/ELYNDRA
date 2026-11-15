## Main
##
## Root of the Milestone 001 main scene.
##
## It wires the temporary debug camera to the debug HUD and verifies the
## ground at startup. It is intentionally small: the final player character
## and the third-person camera are out of scope for this milestone.
class_name MainScene
extends Node3D

# Preloaded so this script also works before the editor builds the class cache.
const Regions = preload("res://scripts/core/world_regions.gd")

@onready var _ground = $World/Ground
@onready var _camera: Camera3D = $World/DebugCamera
@onready var _hud = $DebugHUD


func _ready() -> void:
	if _hud != null:
		_hud.setup(_camera)
	if _ground != null and not _ground.is_valid():
		push_error("ELYNDRA: ground dimensions do not match the 1500 x 1500 m spec")
	else:
		print("ELYNDRA: world ready - %.0f x %.0f m, %d logical regions" % [
			Regions.WORLD_SIZE, Regions.WORLD_SIZE,
			Regions.TOTAL_REGION_COUNT,
		])
