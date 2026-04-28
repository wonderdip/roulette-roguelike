extends Resource
class_name Bet

var type: Global.BetType = Global.BetType.STRAIGHT
var color: Global.BetColor = Global.BetColor.NONE
var number: int

func type_to_string():
	return Global.BetType.keys()[type]

func color_to_string():
	if color != null:
		return Global.BetColor.keys()[color]
	return ""
