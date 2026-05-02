extends Node2D
class_name BriefCase

@export var rows: int = 2
@export var col: int = 6

var start_pos: Vector2
var chip_width: int = 30
var x_offset: int = 12
var y_offset: int = 3

@onready var big_case: Node2D = $BigCase
@onready var small_case: Node2D = $SmallCase
@onready var big_collision_shape: CollisionShape2D = $BigCase/BigArea2D/BigCollisionShape
@onready var small_collision_shape: CollisionShape2D = $SmallCase/SmallArea2D/SmallCollisionShape

var open: bool = true
var _is_animating: bool = false

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
	tween.tween_property(big_case, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
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

	var tween = create_tween()
	tween.tween_property(big_case, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished

	big_case.hide()
	small_case.show()
	small_collision_shape.disabled = false
	_is_animating = false

func spawn_chip_slots() -> void:
	for i in range(1, rows * col + 1):
		var slot = ChipSlot.new()
		slot.slot_number = i
		slot.position = get_slot_global_position(i)  # store as global; ChipSlot uses global_position
		slot.case = self
		add_child(slot)

func _on_small_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		open_case()

func _on_big_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Only close if nothing is overlapping (e.g. no chip is hovering over it)
		if %BigArea2D.get_overlapping_areas().size() < 1:
			close_case()
