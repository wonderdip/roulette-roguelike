extends Node2D
class_name WheelSegment

@export var segment_sprites: Array[Texture] = []

var number: int
var color: Global.BetColor = Global.BetColor.NONE

func _ready() -> void:
	z_index = -1

func set_segment(num: int, col: Global.BetColor, segment: int, sprite_rotation_deg: int, label_rotation: float):
	number = num
	color = col
	
	$Sprite2D.rotation_degrees = sprite_rotation_deg
	$Sprite2D.texture = segment_sprites.get(segment)
	$Sprite2D.modulate = Global.get_color(color)
	$NumberLabel.text = str(number)
	$NumberLabel.rotation_degrees = label_rotation + 5
	
func change_number(num: int):
	number = num
	$NumberLabel.text = str(number)

func change_color(col: Global.BetColor):
	color = col
	$Sprite2D.modulate = Global.get_color(color)
