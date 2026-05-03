extends Node2D

@onready var bet_details_template: NinePatchRect = %BetDetails
@onready var bets_container: VBoxContainer = $Scoring/Control/BetsContainer
@onready var round_label: Label = $Scoring/Control/RoundLabel
@onready var spin_button: TextureButton = $SpinButton

@export var shader: Shader

func _ready() -> void:
	Global.update_bet.connect(_on_bet_updated)
	spin_button.disabled = true
	bet_details_template.hide()

func _on_bet_updated() -> void:
	# Clear all existing bet displays
	for child in bets_container.get_children():
		child.queue_free()

	if Global.current_bets.is_empty():
		spin_button.disabled = true
		return

	spin_button.disabled = false

	for i in Global.current_bets.size():
		var bet = Global.current_bets[i]
		var chip = Global.current_chips[i]
		var details = bet_details_template.duplicate()
		details.show()
		bets_container.add_child(details)
		details.get_node("HBoxContainer/VBoxContainer2/Bet").text = Global.type_to_string(bet.type)
		details.get_node("HBoxContainer/VBoxContainer2/Odds").text = "%.2f%%" % Global.get_odds(bet.type)
		details.get_node("HBoxContainer/VBoxContainer2/Payout").text = "%d$" % roundi(Global.calculate_payout(bet, chip))
		
		var mat = ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("original_palette", Global.original_palette)
		mat.set_shader_parameter("new_palette", Global.chip_palettes[chip.chip_type])
		mat.set_shader_parameter("colors_count", 6)
		mat.set_shader_parameter("tolerance", 0.01)
		details.get_node("Sprite2D").material = mat
