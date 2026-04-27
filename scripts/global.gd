extends Node

enum BetColor{
	NONE, 
	RED, 
	BLACK,
}

enum BetType{
	STRAIGHT, 
	SPLIT, 
	STREET,
	CORNER,
	DOUBLE_STREET, 
	ODD, 
	EVEN, 
	RED, 
	BLACK, 
	ONE_TO_18, 
	NINETEEN_TO_36, 
	FIRST_12, 
	SECOND_12, 
	THIRD_12, 
	COLUMN_1, 
	COLUMN_2, 
	COLUMN_3, 
}


@export var RED_COLOR: = Color("ac3232")
@export var BLACK_COLOR: = Color("1b1b1b")

var DEFAULT_NUMBER_COLORS: Dictionary[int, BetColor] = {
	1: BetColor.RED, 
	2: BetColor.BLACK, 
	3: BetColor.RED, 
	4: BetColor.BLACK, 
	5: BetColor.RED, 
	6: BetColor.BLACK, 
	7: BetColor.RED, 
	8: BetColor.BLACK, 
	9: BetColor.RED, 
	10: BetColor.BLACK, 
	11: BetColor.BLACK, 
	12: BetColor.RED, 
	13: BetColor.BLACK, 
	14: BetColor.RED, 
	15: BetColor.BLACK, 
	16: BetColor.RED, 
	17: BetColor.BLACK, 
	18: BetColor.RED, 
	19: BetColor.RED, 
	20: BetColor.BLACK, 
	21: BetColor.RED, 
	22: BetColor.BLACK, 
	23: BetColor.RED, 
	24: BetColor.BLACK, 
	25: BetColor.RED, 
	26: BetColor.BLACK, 
	27: BetColor.RED, 
	28: BetColor.BLACK, 
	29: BetColor.BLACK, 
	30: BetColor.RED, 
	31: BetColor.BLACK, 
	32: BetColor.RED, 
	33: BetColor.BLACK, 
	34: BetColor.RED, 
	35: BetColor.BLACK, 
	36: BetColor.RED, 
}

var WHEEL_ORDER: Array[int] = [
	32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10,
	5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26
]

var current_bet: BetType

func place_bet(bet: BetType):
	current_bet = bet

func get_color(bet_color: BetColor) -> Color:
	match bet_color:
		BetColor.NONE:
			return Color("1d4a21")
		BetColor.RED:
			return RED_COLOR
		BetColor.BLACK:
			return BLACK_COLOR
	return Color.PINK
