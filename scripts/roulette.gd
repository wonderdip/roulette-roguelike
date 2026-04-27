extends Node2D


@export var red_color: Color
@export var black_color: Color
@onready var bet_label: Label = $BetLabel

func _process(delta: float) -> void:
	if Global.current_bet:
		bet_label.text = Global.BetType.keys()[Global.current_bet]
