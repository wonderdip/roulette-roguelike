extends Node2D
class_name ChipCase

@export var rows: int = 2
@export var col: int = 6

var start_pos: Vector2
var chip_width: int = 30
var x_offset: int = 12
var y_offset: int = 4

@onready var big_case: Node2D = $BigCase
@onready var small_case: Node2D = $SmallCase
@onready var big_collision_shape: CollisionShape2D = %BigCollisionShape
@onready var small_collision_shape: CollisionShape2D = %SmallCollisionShape

var open: bool = true
var _is_animating: bool = false
var slots: Array[ChipSlot] = []

func _ready() -> void:
	start_pos = %Marker2D.global_position
	spawn_chip_slots()
	close_case()

func get_slot_global_position(slot_number: int) -> Vector2:
	var c = (slot_number - 1) % rows
	var r = (slot_number - 1) / rows
	return Vector2(
		start_pos.x + c * (chip_width + x_offset) + chip_width * 0.5,
		start_pos.y + r * (chip_width + y_offset) + chip_width * 0.5
	)

func open_case() -> void:
	if open or _is_animating:
		return
	_is_animating = true
	open = true

	big_collision_shape.disabled = true
	small_collision_shape.disabled = true
	small_case.hide()
	big_case.show()
	big_case.scale = Vector2.ZERO

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(small_case, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(big_case, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	_tween_slotted_chips_scale(tween, Vector2.ZERO, Vector2.ONE, 0.3, 0.05)
	await tween.finished

	big_collision_shape.disabled = false
	_is_animating = false

func close_case() -> void:
	if not open or _is_animating:
		return
	_is_animating = true
	open = false

	big_collision_shape.disabled = true
	small_collision_shape.disabled = true
	small_case.show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(big_case, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(small_case, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_slotted_chips_scale(tween, Vector2.ONE, Vector2.ZERO, 0.15)
	await tween.finished
	
	big_case.hide()
	
	small_collision_shape.disabled = false
	_is_animating = false

func _tween_slotted_chips_scale(tween: Tween, from: Vector2, to: Vector2, duration: float, delay: float = 0.0) -> void:
	for slot in slots:
		if slot.case == self and slot.chip_in == true and slot.chip:
			var chip = slot.chip
			chip.scale = from
			tween.tween_property(chip, "scale", to, duration)\
				.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)\
				.set_delay(delay)
			
func spawn_chip_slots() -> void:
	for i in range(1, rows * col + 1):
		var slot = ChipSlot.new()
		slot.slot_number = i
		slot.position = get_slot_global_position(i)
		slot.case = self
		slots.append(slot)
		add_child(slot)

func _on_small_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		open_case()

func _on_big_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		await get_tree().process_frame
		var overlapping = %BigArea2D.get_overlapping_areas()
		if overlapping.any(func(a): return a.get_parent() is PokerChip and a.get_parent().dragging):
			return
		close_case()

func _on_small_area_2d_mouse_entered() -> void:
	small_case.modulate = Color(0.8, 0.8, 0.8)

func _on_small_area_2d_mouse_exited() -> void:
	small_case.modulate = Color.WHITE
