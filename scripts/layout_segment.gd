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

var tween: Tween

func set_highlight(highlighted: bool) -> void:
	if tween:
		tween.kill()
	if highlighted:
		tween = create_tween()
		tween.set_loops()  # loop forever
		tween.tween_property($Sprite2D, "modulate", Global.get_color(color).lightened(0.4), 0.4)
		tween.tween_property($Sprite2D, "modulate", Global.get_color(color), 0.4)
	else:
		$Sprite2D.modulate = Global.get_color(color)
