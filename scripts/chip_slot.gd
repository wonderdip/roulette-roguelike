extends Node2D
class_name ChipSlot

@export var slot_number: int
@export var case: BriefCase
@export var chip: PokerChip  # The chip currently occupying this slot (null = free)

func _ready() -> void:
	add_to_group("chip_slots")
	# Use the case's computed global position as our world position
	if case:
		global_position = case.get_slot_global_position(slot_number)

func is_free() -> bool:
	return chip == null
