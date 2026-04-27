extends Node2D

@export var sfx: Array[AudioStreamWAV]
@onready var ball_roll_player: AudioStreamPlayer2D = $BallRollPlayer

func start_spin():
	ball_roll_player.pitch_scale = randf_range(0.8, 0.9)
	ball_roll_player.stream = sfx.get(0)
	ball_roll_player.play()
	await ball_roll_player.finished
	ball_roll_player.stream = sfx.get(2)
	ball_roll_player.play()
	
func end_spin():
	ball_roll_player.stop()
	await get_tree().process_frame
	ball_roll_player.pitch_scale = randf_range(0.8, 0.9)
	ball_roll_player.stream = sfx.get(1)
	ball_roll_player.play()
