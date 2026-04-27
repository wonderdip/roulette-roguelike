extends Node2D
class_name Wheel

@export var wheel_segment_scene: PackedScene
@export var wheel_radius: float

func _ready() -> void:
	spawn_segments()

func spawn_segments() -> void:
	var total = Global.WHEEL_ORDER.size()
	var angle_step = TAU / total

	for i in range(total):
		var segment_node = wheel_segment_scene.instantiate() as WheelSegment
		add_child(segment_node, true)

		var quadrant = int(i / 9)  # 0-3
		var slot = i % 9
		var sprite_index = slot

		var sprite_rotation = 0
		match quadrant:
			0: sprite_rotation = 0
			1: sprite_rotation = 90
			2: sprite_rotation = 180
			3: sprite_rotation = 270

		var angle = angle_step * i - PI / 2 + angle_step * 0.5
		segment_node.position = Vector2(cos(angle), sin(angle)) * wheel_radius
		segment_node.position = segment_node.position.round()
		
		var number = Global.WHEEL_ORDER[i]
		segment_node.set_segment(
			number,
			Global.get_color(Global.DEFAULT_NUMBER_COLORS[number]),
			sprite_index,
			sprite_rotation,
			i * 10,
		)
