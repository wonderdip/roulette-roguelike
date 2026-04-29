extends Node2D


@export var red_color: Color
@export var black_color: Color
@onready var bet: Label = $Scoring/Control/BetDetails/HBoxContainer/VBoxContainer2/Bet
@onready var odds: Label = $Scoring/Control/BetDetails/HBoxContainer/VBoxContainer2/Odds
@onready var payout: Label = $Scoring/Control/BetDetails/HBoxContainer/VBoxContainer2/Payout
@onready var round_label: Label = $Scoring/Control/RoundLabel
@onready var spin_button: TextureButton = $SpinButton

var num_text = ""
var color_text = ""

func _ready() -> void:
	Global.update_bet.connect(_on_bet_placed)
	spin_button.disabled = true
	
func _on_bet_placed() -> void:
	if Global.current_bet:
		spin_button.disabled = false
		if Global.current_bet.number:
			num_text = str(Global.current_bet.number)
		if Global.current_bet.color != Global.BetColor.NONE:
			color_text = Global.current_bet.color_to_string()
		
		bet.text = Global.type_to_string(Global.current_bet.type)
		odds.text = "%.2f" % Global.get_odds(Global.current_bet.type) + "%"
		payout.text = "%s" % roundi(Global.calculate_payout(Global.current_bet, 10)) + "$"
