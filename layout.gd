extends Node2D

@export var layout_segment_scene: PackedScene
@onready var roulette: Node2D = $".."

@export var segment_width: int = 39
@export var segment_height: int = 39
@export var columns: int = 12
@export var rows: int = 3
@export var grid_offset: int

func _ready() -> void:
	for i in range(roulette.wheel_numbers.size()):
		var segment_node = layout_segment_scene.instantiate() as LayoutSegment
		add_child(segment_node, true)
		
		var col = i % rows
		var row = i / rows
		
		segment_node.global_position = Vector2(
			651 + col * (segment_width + grid_offset),
			29 + row * (segment_height + grid_offset)
		)
		
		segment_node.set_layout_segment(i+1, roulette.get_colour(i+1))
