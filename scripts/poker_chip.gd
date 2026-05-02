extends Node2D
class_name PokerChip

@export var value: int = 10
@export var chip_drop: Array[AudioStream]
@export var chip_pickup: Array[AudioStream]

var dragging: bool = false
var nearest_zone: BetZone = null
var last_zone: BetZone = null
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and dragging:
			_drop()
			
func _on_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if not Global.spinning:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pick_up()
				
func chip_shake():
	var sprite = $Sprite2D
	
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees", 15, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "rotation_degrees", -15, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "rotation", 0.0, 0.1)
	
func _find_nearest_zone() -> void:
	var candidates = []
	
	for zone in get_tree().get_nodes_in_group("bet_zones"):
		var dist = global_position.distance_to(zone.global_position)
		if dist < snap_radius:
			candidates.append({"zone": zone, "dist": dist, "priority": get_bet_priority(zone.bet_type)})
	
	if candidates.is_empty():
		nearest_zone = null
		return
	
	# Sort by priority descending, then distance ascending as tiebreaker
	candidates.sort_custom(func(a, b):
		if a.priority != b.priority:
			return a.priority > b.priority
		return a.dist < b.dist
	)
	
	nearest_zone = candidates[0].zone

func _set_zone_highlight(zone: Area2D, highlighted: bool) -> void:
	var overlay = get_tree().get_first_node_in_group("segment_overlay")
	if overlay:
		overlay.highlight_zone(zone if highlighted else null)

func pick_up():
	dragging = true
	$AudioStreamPlayer2D.stream = chip_pickup.pick_random()
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.95, 1.05)
	$AudioStreamPlayer2D.play()
	chip_shake()
	var played_chips = get_tree().get_first_node_in_group("played_chips")
	reparent(played_chips)

func _drop() -> void:
	dragging = false
	$AudioStreamPlayer2D.stream = chip_drop.pick_random()
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.95, 1.05)
	$AnimationPlayer.play("chip_bounce")
	$AudioStreamPlayer2D.play()
	chip_shake()
	
	if _is_over_layout():
		if last_zone:
			_set_zone_highlight(last_zone, true)
			Global.place_bet(nearest_zone)
	else:
		_return_to_tray()

func _is_over_layout() -> bool:
	var layout_area = get_tree().get_first_node_in_group("layout_area")
	if layout_area == null:
		return false
	for area in $Area2D.get_overlapping_areas():
		if area == layout_area:
			return true
	return false

func _return_to_tray() -> void:
	_set_zone_highlight(last_zone, false)
	last_zone = null
	nearest_zone = null
	var slots = get_tree().get_nodes_in_group("chip_slots")
	var chip_container = get_tree().get_first_node_in_group("chip_container")
	if slots.is_empty():
		return
		
	var slot : ChipSlot = slots[0]
	var slot_position: Vector2 = slot.global_position
	
	if not slot.case.open:
		slot.case.open_case()
	
	reparent(chip_container)
	var tween = create_tween()
	tween.tween_property(self, "global_position", slot_position, 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

func get_bet_priority(bet_type: Global.BetType) -> int:
	match bet_type:
		Global.BetType.STRAIGHT:      return 7  # 35:1
		Global.BetType.SPLIT:         return 6  # 17:1
		Global.BetType.STREET:        return 5  # 11:1
		Global.BetType.CORNER:        return 4  # 8:1
		Global.BetType.DOUBLE_STREET: return 3  # 5:1
		Global.BetType.FIRST_12, Global.BetType.SECOND_12, Global.BetType.THIRD_12: return 2  # 2:1
		Global.BetType.COLUMN_1, Global.BetType.COLUMN_2, Global.BetType.COLUMN_3: return 2
		_:                            return 1  # even money bets
