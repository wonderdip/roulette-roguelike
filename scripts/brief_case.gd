extends Node2D
class_name BriefCase

@export var rows: int
@export var col: int

var start_pos: Vector2
var chip_width: int = 30
var x_offset: int = 8
var y_offset: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = $Sprite2D/Marker2D.global_position
	spawn_chip_slots()

func get_center(number: int) -> Vector2:
	var col = (number - 1) % rows
	var row = (number - 1) / rows
	var global_pos = Vector2(
		start_pos.x + col * (chip_width + x_offset),
		start_pos.y + row * (chip_width + y_offset)
	)+ Vector2(chip_width, chip_width) * 0.5
	return $ChipSlots.to_local(global_pos)

func spawn_chip_slots():
	for i in range(1, 13):
		var slot = ChipSlot.new()
		slot.slot_number = i
		slot.position = get_center(i)
		$ChipSlots.add_child(slot)
