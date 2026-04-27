extends Node2D
class_name WheelSegment

@export var segment_sprites: Array[Texture] = []

func set_segment(number: int, color: Color, segment: int, sprite_rotation_deg: int, label_rotation: float):
	$Sprite2D.rotation_degrees = sprite_rotation_deg
	$Sprite2D.texture = segment_sprites.get(segment)
	$Sprite2D.modulate = color
	$NumberLabel.text = str(number)
	$NumberLabel.rotation_degrees = label_rotation + 5
	
