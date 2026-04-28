extends Node2D


@export var red_color: Color
@export var black_color: Color
@onready var bet_label: Label = $BetLabel

var num_text = ""
var color_text = ""

func _process(_delta: float) -> void:
	if Global.current_bet:
		if Global.current_bet.number:
			num_text = str(Global.current_bet.number)
		if Global.current_bet.color != Global.BetColor.NONE:
			color_text = Global.current_bet.color_to_string()
			
		bet_label.text = "%s \n%s \n%s" % [
			Global.current_bet.type_to_string(),
			color_text,
			num_text
		]
