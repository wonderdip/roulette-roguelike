extends Area2D
class_name BetZone


var bet_type: Global.BetType
var numbers: Array = []

func _ready() -> void:
	add_to_group("bet_zones")
