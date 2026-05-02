extends Node2D
class_name LayoutSegment

var number: int
var color: Global.BetColor

func _ready() -> void:
	add_to_group("layout_segments")

func set_layout_segment(num: int, col: Global.BetColor):
	number = num
	color = col
	
	$Sprite2D.modulate = Global.get_color(color)
	$NumberLabel.text = str(number)

func get_width() -> int: return 42
func get_height() -> int: return 34
