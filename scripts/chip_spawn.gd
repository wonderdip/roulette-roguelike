extends Node2D

@export var chip_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_chips()

func spawn_chips():
	for i in Global.ChipType.size():
		var chip = chip_scene.instantiate() as PokerChip
		chip.chip_type = i
		add_child(chip)
		chip._return_to_case()
		
