extends Node2D
class_name PokerChip

@export var value: int = 10

var dragging: bool = false
var nearest_zone: Area2D = null
var snap_radius: float = 10.0

func _ready() -> void:
	$Area2D.input_pickable = true
	$Area2D.connect("input_event", _on_input_event)

func _process(delta: float) -> void:
	if dragging:
		var mouse_world = get_global_mouse_position()
		global_position = global_position.lerp(
		mouse_world,
		15 * delta
		)
		_find_nearest_zone()
	
	
	if nearest_zone != last_zone:
		# Clear old highlights
		if last_zone:
			_set_zone_highlight(last_zone, false)
		# Apply new highlights
		if nearest_zone:
			_set_zone_highlight(nearest_zone, true)
		last_zone = nearest_zone
		
func _on_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
		else:
			_drop()

var last_zone: Area2D = null

func _find_nearest_zone() -> void:
	var closest_dist = snap_radius
	nearest_zone = null
	
	for zone in get_tree().get_nodes_in_group("bet_zones"):
		var dist = global_position.distance_to(zone.global_position)
		if dist < closest_dist:
			closest_dist = dist
			nearest_zone = zone

func _set_zone_highlight(zone: Area2D, highlighted: bool) -> void:
	for segment in get_tree().get_nodes_in_group("layout_segments"):
		if segment.number in zone.numbers:
			segment.set_highlight(highlighted)

func _drop() -> void:
	dragging = false
	if last_zone:
		_set_zone_highlight(last_zone, true)
		Global.place_bet(nearest_zone.bet_type)
