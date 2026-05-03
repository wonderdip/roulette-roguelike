extends Node2D
class_name PokerChip

@export var chip_type: Global.ChipType = Global.ChipType.WHITE


@export var shader: Shader
@export var chip_drop: Array[AudioStream]
@export var chip_pickup: Array[AudioStream]

var dragging: bool = false
var nearest_zone: BetZone = null
var last_zone: BetZone = null
var home_slot: ChipSlot = null

var _layout_area: Area2D = null

func _ready() -> void:
	$Area2D.input_pickable = true
	$Area2D.connect("input_event", _on_input_event)
	_layout_area = get_tree().get_first_node_in_group("layout_area")
	_apply_palette()
	
	for slot in get_tree().get_nodes_in_group("chip_slots"):
		if slot.slot_number == chip_type + 1:
			home_slot = slot
			slot.chip = self
			
			
func _apply_palette() -> void:
	if Global.chip_palettes.is_empty():
		return
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("original_palette", Global.original_palette)
	mat.set_shader_parameter("new_palette", Global.chip_palettes[chip_type])
	mat.set_shader_parameter("colors_count", 6)
	mat.set_shader_parameter("tolerance", 0.01)
	$Sprite2D.material = mat

func get_chip_value():
	return Global.CHIP_VALUES.values()[chip_type]

func _process(delta: float) -> void:
	if not dragging:
		return

	global_position = global_position.lerp(get_global_mouse_position(), 15.0 * delta)
	_find_nearest_zone()

	if nearest_zone != last_zone:
		if last_zone:
			_set_zone_highlight(last_zone, false)
		if nearest_zone:
			_set_zone_highlight(nearest_zone, true)
		last_zone = nearest_zone

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and dragging:
			_drop()

func _on_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if Global.spinning:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()  # stop the click reaching the case
		pick_up()

func pick_up() -> void:
	dragging = true
	home_slot.chip_in = false
	scale = Vector2.ONE
	Global.remove_bet(self)
	_play_sfx(chip_pickup)
	chip_shake()

func _drop() -> void:
	dragging = false
	_play_sfx(chip_drop)
	$AnimationPlayer.play("chip_bounce")
	chip_shake()
	
	if _is_over_layout() and nearest_zone != null:
		_set_zone_highlight(nearest_zone, true)
		Global.place_bet(nearest_zone, self)  # pass self
	else:
		_clear_highlight()
		_return_to_case()

func _find_nearest_zone() -> void:
	var best: BetZone = null
	var best_priority: int = -1

	for zone in $Area2D.get_overlapping_areas():
		if zone is BetZone:
			var priority = get_bet_priority(zone.bet_type)
			if priority > best_priority:
				best_priority = priority
				best = zone

	nearest_zone = best

func _set_zone_highlight(zone: BetZone, highlighted: bool) -> void:
	var overlay = get_tree().get_first_node_in_group("segment_overlay")
	if not overlay:
		return
		
	var zones = []
	for placed_zone in Global.current_bets.map(func(b): return b.bet_zone):
		zones.append(placed_zone)
		
	# Add or remove the hovered zone
	if highlighted and zone and not zones.has(zone):
		zones.append(zone)
	elif not highlighted:
		zones.erase(zone)
		
	overlay.highlight_zones(zones)

func _clear_highlight() -> void:
	last_zone = null
	nearest_zone = null
	var overlay = get_tree().get_first_node_in_group("segment_overlay")
	if overlay:
		var zones = Global.current_bets.map(func(b): return b.bet_zone)
		overlay.highlight_zones(zones)

func _is_over_layout() -> bool:
	if _layout_area == null:
		return false
	# Use position-based check rather than physics overlap
	# since overlap state may lag behind visual position
	var layout_shape = _layout_area.get_node_or_null("CollisionShape2D")
	if layout_shape == null:
		return false
	var rect = Rect2(
		_layout_area.global_position,
		layout_shape.shape.size
	)
	return rect.has_point(global_position)

func _return_to_case() -> void:
	home_slot.chip_in = true
	if home_slot.case.open:
		go_to_chip_slot()
	else:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "global_position", home_slot.case.global_position, 0.3)\
			.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func go_to_chip_slot():
	home_slot.chip_in = true
	var tween = create_tween()
	tween.tween_property(self, "global_position", home_slot.global_position, 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	if not home_slot.case.open:
		scale = Vector2.ZERO

func chip_shake() -> void:
	var tween = create_tween()
	tween.tween_property($Sprite2D, "rotation_degrees", 15.0, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Sprite2D, "rotation_degrees", -15.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Sprite2D, "rotation", 0.0, 0.1)

func _play_sfx(pool: Array[AudioStream]) -> void:
	if pool.is_empty():
		return
	$AudioStreamPlayer2D.stream = pool.pick_random()
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.95, 1.05)
	$AudioStreamPlayer2D.play()

func get_bet_priority(bet_type: Global.BetType) -> int:
	match bet_type:
		Global.BetType.STRAIGHT: return 1
		Global.BetType.SPLIT: return 2
		Global.BetType.STREET: return 6
		Global.BetType.CORNER: return 3
		Global.BetType.DOUBLE_STREET: return 6
		Global.BetType.FIRST_12, Global.BetType.SECOND_12, Global.BetType.THIRD_12: return 5
		Global.BetType.COLUMN_1, Global.BetType.COLUMN_2, Global.BetType.COLUMN_3: return 4
		_: return 1
