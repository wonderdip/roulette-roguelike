extends Node2D

@export var tick_sfx: Array[AudioStreamWAV]
@export var radius: float = 48.0

@export var spin_min: float = 8.0
@export var spin_max: float = 14.0
@export var friction_min: float = 0.982
@export var friction_max: float = 0.988
@export var stop_threshold: float = 0.2
@export var idle_speed: float = 0.4

@export var wheel_start_angle_deg: float = 0.0

@onready var ball: Node2D = $Ball
@onready var number_label: Label = $"../Number"
@onready var colour_label: Label = $"../Colour"
@onready var roulette_wheel: Wheel = $"../Wheel"

@onready var wheel_tick_player: AudioStreamPlayer2D = $WheelTickPlayer
@onready var spin_button: TextureButton = $"../SpinButton"

var angle := 0.0
var angular_velocity := 0.0
var segment_angle := 0.0
var center: Vector2

var wheel_angle: float = 0.0
var wheel_angular_velocity: float = 0.0
var wheel_friction: float = 0.985

var stopped := false
var wheel_start_angle_rad: float = 0.0

var friction: float = 0.985
var tick_timer: float = 0.0

const DIRECTION := 1.0

func _ready() -> void:
	center = roulette_wheel.position
	segment_angle = TAU / Global.WHEEL_ORDER.size()
	wheel_start_angle_rad = deg_to_rad(wheel_start_angle_deg)
	stopped = true
	ball.hide()
	
	if tick_sfx.size() > 0:
		wheel_tick_player.stream = tick_sfx[0]
		wheel_tick_player.play()
		wheel_tick_player.stop()
		
func start_spin() -> void:
	stopped = false
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
	
	if stopped:
		wheel_tick_player.stop()
		play_tick()
		roulette_wheel.rotation = wheel_angle
		lock_into_pocket()
		return

	wheel_angular_velocity *= pow(wheel_friction, delta * 60.0)
	roulette_wheel.rotation = wheel_angle
	
	angle += angular_velocity * delta
	angular_velocity *= pow(friction, delta * 60.0)
	var offset = Vector2(cos(angle), sin(angle)) * radius
	ball.global_position = center + offset
	ball.rotation_degrees = angle**2 * angular_velocity**2 * -1
	
	tick_timer -= delta
	if tick_timer <= 0.0:
		play_tick()
		# higher velocity = shorter gap between ticks
		wheel_tick_player.pitch_scale = randf_range(0.8, 0.9)
		tick_timer = clamp(1.0 / abs(angular_velocity), 0.05, 0.5)
		
	if not stopped and abs(angular_velocity) < stop_threshold:
		end_spin()
		
func play_tick():
	wheel_tick_player.stream = tick_sfx.pick_random()
	wheel_tick_player.play()
	
func normalize_angle(a: float) -> float:
	return fposmod(a, TAU)

func get_index_from_angle(a: float) -> int:
	# Subtract wheel's current rotation so pockets move with the wheel
	a = fposmod(a - wheel_angle, TAU)
	a = fposmod(a - wheel_start_angle_rad, TAU)
	a += segment_angle * 0.5
	return int(floor(a / segment_angle)) % Global.WHEEL_ORDER.size()

func lock_into_pocket():
	var index = get_index_from_angle(angle)
	var target_angle = wheel_angle + wheel_start_angle_rad + index * segment_angle
	angle = target_angle
	var offset = Vector2(cos(angle), sin(angle)) * radius
	ball.global_position = center + offset
	
func end_spin() -> void:
	stopped = true
	angular_velocity = 0.0
	wheel_angular_velocity = 0.0
	ball.end_spin()
	var index = get_index_from_angle(angle)
	var number = Global.WHEEL_ORDER[index]
	lock_into_pocket()
	
	number_label.text = str(number)
	colour_label.text = Global.BetColor.keys()[Global.DEFAULT_NUMBER_COLORS[number]]
	spin_button.disabled = false
	spin_button.modulate = Color.WHITE
	print("LANDED ON: ", number)

func _on_spin_button_pressed() -> void:
	start_spin()
