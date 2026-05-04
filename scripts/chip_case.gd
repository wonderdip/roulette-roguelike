extends Node2D
class_name ChipCase

var start_pos: Vector2
var chip_width: int = 30
var x_offset: int = 4

var slots: Array[ChipSlot] = []

func _ready() -> void:
	start_pos = %Marker2D.global_position
	spawn_chip_slots()
	add_tray_segments(2)
	
func get_slot_global_position(slot_number: int) -> Vector2:
	return Vector2(
		start_pos.x + (slot_number - 1) * (chip_width + x_offset),
		start_pos.y
	)

func _tween_slotted_chips_scale(tween: Tween, from: Vector2, to: Vector2, duration: float, delay: float = 0.0) -> void:
	for slot in slots:
		if slot.case == self and slot.chip_in == true and slot.chip:
			var chip = slot.chip
			chip.scale = from
			
			tween.tween_property(chip, "scale", to, duration)\
				.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)\
				.set_delay(delay)
			
func spawn_chip_slots() -> void:
	for i in range(1, Global.max_chips + 1):
		var slot = ChipSlot.new()
		slot.slot_number = i
		slot.position = get_slot_global_position(i)
		slot.case = self
		slots.append(slot)
		add_child(slot)

func add_tray_segments(amount: int):
	for i in range(0, amount):
		var middle = %TrayMiddle.duplicate()
		middle.show()
		%TrayMiddle.add_sibling(middle, true)
