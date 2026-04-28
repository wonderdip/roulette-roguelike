extends Node2D
class_name SegmentOverlay

@export var color: Color

var highlighted_rects: Array[Rect2] = []
var use_bounding_box: bool = true

func _ready() -> void:
	add_to_group("segment_overlay")

func _draw() -> void:
	if highlighted_rects.is_empty():
		return
	if use_bounding_box:
		var combined = highlighted_rects[0]
		for rect in highlighted_rects:
			combined = combined.merge(rect)
		draw_rect(combined, color, false, 2.0)
	else:
		for rect in highlighted_rects:
			draw_rect(rect, color, false, 2.0)

func highlight_zone(zone: Area2D) -> void:
	highlighted_rects.clear()
	if zone == null:
		queue_redraw()
		return
	
	# Use bounding box for contained bets, per-segment for scattered ones
	use_bounding_box = _is_contiguous(zone.bet_type)
	
	for segment in get_tree().get_nodes_in_group("layout_segments"):
		if segment.number in zone.numbers:
			var local_pos = to_local(segment.global_position) + Vector2(1,-1)
			var half = Vector2(segment.get_width(), segment.get_height()) * 0.5
			highlighted_rects.append(Rect2(local_pos - half, half * 2))
	queue_redraw()

func _is_contiguous(bet_type: Global.BetType) -> bool:
	match bet_type:
		Global.BetType.RED, \
		Global.BetType.BLACK, \
		Global.BetType.ODD, \
		Global.BetType.EVEN:
			return false  # scattered, draw per segment
		_:
			return true   # contiguous block, draw bounding box
