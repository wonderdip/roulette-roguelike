extends Node2D
class_name Wheel

@export var wheel_segment_scene: PackedScene
@export var ball: Ball
@export var spin_button: TextureButton

@export var wheel_radius: float

@export var tick_sfx: Array[AudioStreamWAV]
@export var radius: float = 96.0

@export var spin_min: float = 14.0
@export var spin_max: float = 24.0
@export var friction_min: float = 0.982
@export var friction_max: float = 0.988
@export var stop_threshold: float = 0.2
@export var idle_speed: float = 0.4

@export var wheel_start_angle_deg: float = 0.0

var angle := 0.0
var angular_velocity := 0.0
var segment_angle := 0.0
var center: Vector2

var wheel_angle: float = 0.0
var wheel_angular_velocity: float = 0.0
var wheel_friction: float = 0.985

var wheel_start_angle_rad: float = 0.0

var friction: float = 0.985
var tick_timer: float = 0.0

const DIRECTION := 0.0

var segments: Array[WheelSegment]

func _ready() -> void:
	spawn_segments()
	if spin_button:
		spin_button.connect("pressed", _on_spin_button_pressed)
		
	center = position
	segment_angle = TAU / Global.WHEEL_ORDER.size()
	wheel_start_angle_rad = deg_to_rad(wheel_start_angle_deg)
	ball.hide()
	
func spawn_segments() -> void:
	var total = Global.WHEEL_ORDER.size()
	var angle_step = TAU / total

	for i in range(total):
		var segment_node = wheel_segment_scene.instantiate() as WheelSegment
		%Spinner.add_child(segment_node, true)
		segments.append(segment_node)
		
		var quadrant = int(i / 9)  # 0-3
		var slot = i % 9
		var sprite_index = slot

		var sprite_rotation = 0
		match quadrant:
			0: sprite_rotation = 0
			1: sprite_rotation = 90
			2: sprite_rotation = 180
			3: sprite_rotation = 270

		var target_angle = angle_step * i - PI / 2 + angle_step * 0.5
		segment_node.position = Vector2(cos(target_angle), sin(target_angle)) * wheel_radius
		segment_node.position = segment_node.position.round()
		
		var number = Global.WHEEL_ORDER[i]
		segment_node.set_segment(
			number,
			Global.number_to_color(number),
			sprite_index,
			sprite_rotation,
			i * 10,
		)
	
func start_spin() -> void:
	Global.spinning = true
	ball.show()
	ball.start_spin()
	angle = randf_range(0.0, TAU)
	angular_velocity = randf_range(spin_min, spin_max) * DIRECTION
	friction = randf_range(friction_min, friction_max)
	wheel_angular_velocity = randf_range(spin_min * 0.4, spin_max * 0.4) * -DIRECTION
	wheel_friction = randf_range(friction_min, friction_max)
	spin_button.disabled = true
	spin_button.modulate = Color.GRAY

func _process(delta: float) -> void:
	# Wheel always drifts at idle_speed, spin adds on top
	wheel_angle += (wheel_angular_velocity + (-idle_speed)) * delta
	
	if not Global.spinning:
		%WheelTickPlayer.stop()
		%Spinner.rotation = wheel_angle
		lock_into_pocket()
		return

	wheel_angular_velocity *= pow(wheel_friction, delta * 60.0)
	%Spinner.rotation = wheel_angle
	
	angle += angular_velocity * delta
	angular_velocity *= pow(friction, delta * 60.0)
	var offset = Vector2(cos(angle), sin(angle)) * radius
	ball.global_position = center + offset
	ball.rotation_degrees = angle**2 * angular_velocity**2 * -1
	
	tick_timer -= delta
	if tick_timer <= 0.0:
		play_tick()
		# higher velocity = shorter gap between ticks
		%WheelTickPlayer.pitch_scale = randf_range(0.8, 0.9)
		tick_timer = clamp(1.0 / abs(angular_velocity), 0.05, 0.5)
		
	if Global.spinning and abs(angular_velocity) < stop_threshold:
		end_spin()
		
func play_tick():
	%WheelTickPlayer.stream = tick_sfx.pick_random()
	%WheelTickPlayer.play()
	
func normalize_angle(a: float) -> float:
	return fposmod(a, TAU)

func get_index_from_angle(a: float) -> int:
	a = fposmod(a - wheel_angle, TAU)
	a = fposmod(a - wheel_start_angle_rad, TAU)
	# Removed the + segment_angle * 0.5 here
	return int(floor(a / segment_angle)) % Global.WHEEL_ORDER.size()

func lock_into_pocket():
	var index = get_index_from_angle(angle)
	# Snap to pocket centre by adding segment_angle * 0.5
	var target_angle = wheel_angle + wheel_start_angle_rad + index * segment_angle + segment_angle * 0.5
	angle = target_angle
	var offset = Vector2(cos(angle), sin(angle)) * radius
	ball.global_position = center + offset
	
func end_spin() -> void:
	Global.spinning = false
	angular_velocity = 0.0
	wheel_angular_velocity = 0.0
	ball.end_spin()
	var index = get_index_from_angle(angle)
	var number = Global.WHEEL_ORDER[index]
	lock_into_pocket()
	
	spin_button.disabled = false
	spin_button.modulate = Color.WHITE
	for bet in Global.current_bets:
		print("Bet: ", bet.type_to_string(), " | Winner: ", Global.is_bet_winner(bet, number))
	print("LANDED ON: ", number)
	
func _on_spin_button_pressed() -> void:
	start_spin()
