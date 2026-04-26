extends Node2D

@export var sfx: Array[AudioStreamWAV]

func start_spin():
	$BallRollPlayer.stream = sfx.get(0)
	$BallRollPlayer.play()
	
func end_spin():
	$BallRollPlayer.stop()
	await get_tree().process_frame
	$BallRollPlayer.stream = sfx.get(1)
	$BallRollPlayer.play()
