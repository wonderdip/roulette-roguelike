extends Node2D
class_name ChipSlot

@export var slot_number: int
@export var case: Node2D
@export var chip: PokerChip

func _ready() -> void:
	add_to_group("chip_slots")
	
