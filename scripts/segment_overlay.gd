extends Node2D
class_name SegmentOverlay

@export var color: Color

var highlighted_rects: Array = []  # Array of Array[Rect2], one per zone
var use_bounding_box: bool = true

func _ready() -> void:
	add_to_group("segment_overlay")


func _draw() -> void:
	if highlighted_rects.is_empty():
		return
	for zone_rects in highlighted_rects:
		if zone_rects.is_empty():
			continue
		if zone_rects[0][1]:  # use_bounding_box flag stored alongside
			var combined: Rect2 = zone_rects[0][0]
			for i in range(1, zone_rects.size()):
				combined = combined.merge(zone_rects[i][0])
			draw_rect(combined, color, false, 2.0)
		else:
			for pair in zone_rects:
				draw_rect(pair[0], color, false, 2.0)

func highlight_zones(zones: Array) -> void:
	highlighted_rects.clear()
	if zones.is_empty():
		queue_redraw()
		return

	for zone in zones:
		var contiguous = _is_contiguous(zone.bet_type)
		var zone_rects: Array = []
		for segment in get_tree().get_nodes_in_group("layout_segments"):
			if segment.number in zone.numbers:
				var local_pos = to_local(segment.global_position) + Vector2(1, -1)
				var half = Vector2(segment.get_width(), segment.get_height()) * 0.5
				zone_rects.append([Rect2(local_pos - half, half * 2), contiguous])
		highlighted_rects.append(zone_rects)

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
