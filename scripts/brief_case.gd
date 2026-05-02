extends Node2D
class_name BriefCase

@export var rows: int
@export var col: int

var start_pos: Vector2
var chip_width: int = 30
var x_offset: int = 8
var y_offset: int = 3

@onready var big_case: Node2D = $BigCase
@onready var small_case: Node2D = $SmallCase

@onready var big_collision_shape: CollisionShape2D = $BigCase/BigArea2D/BigCollisionShape
@onready var small_collision_shape: CollisionShape2D = $SmallCase/SmallArea2D/SmallCollisionShape

var open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = %Marker2D.global_position
	%Chips.add_to_group("chip_container")
	%PlayedChips.add_to_group("played_chips")
	close_case()
	spawn_chip_slots()

func get_center(number: int) -> Vector2:
	var col = (number - 1) % rows
	var row = (number - 1) / rows
	var global_pos = Vector2(
		start_pos.x + col * (chip_width + x_offset),
		start_pos.y + row * (chip_width + y_offset)
	)+ Vector2(chip_width, chip_width) * 0.5
	return %ChipSlots.to_local(global_pos)

func open_case():
	open = true
	big_collision_shape.disabled = true
	small_collision_shape.disabled = true
	big_case.show()
	small_case.hide()
	
	big_case.scale = Vector2(0,0)
	var tween = create_tween()
	tween.tween_property(big_case, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	big_collision_shape.disabled = false
	
func close_case():
	open = false
	big_collision_shape.disabled = true
	small_collision_shape.disabled = true
	
	big_case.scale = Vector2(1,1)
	var tween = create_tween()
	tween.tween_property(big_case, "scale", Vector2(0, 0), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	small_case.show()
	await tween.finished
	small_collision_shape.disabled = false
	big_case.hide()
	
func spawn_chip_slots():
	for i in range(1, 13):
		var slot = ChipSlot.new()
		slot.slot_number = i
		slot.position = get_center(i)
		slot.case = self
		%ChipSlots.add_child(slot)

func _on_small_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			open_case()

func _on_big_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if %BigArea2D.get_overlapping_areas().size() < 1:
				close_case()
