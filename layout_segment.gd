extends Node2D
class_name LayoutSegment

func set_layout_segment(number: int, color: Color):
	$Sprite2D.modulate = color
	$NumberLabel.text = str(number)
