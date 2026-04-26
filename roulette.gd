extends Node2D


@export var red_color: Color
@export var black_color: Color

var wheel_numbers = [
	32, 15, 19, 4, 21, 2, 25, 17, 34,
	6, 27, 13, 36, 11, 30, 8, 23, 10,
	5, 24, 16, 33, 1, 20, 14, 31, 9,
	22, 18, 29, 7, 28, 12, 35, 3, 26
]

var wheel_colours: Dictionary[int, String] = {
	1: "Red", 2: "Black", 3: "Red", 4: "Black", 5: "Red",
	6: "Black", 7: "Red", 8: "Black", 9: "Red", 10: "Black",
	11: "Black", 12: "Red", 13: "Black", 14: "Red", 15: "Black",
	16: "Red", 17: "Black", 18: "Red", 19: "Red", 20: "Black",
	21: "Red", 22: "Black", 23: "Red", 24: "Black", 25: "Red",
	26: "Black", 27: "Red", 28: "Black", 29: "Black", 30: "Red",
	31: "Black", 32: "Red", 33: "Black", 34: "Red", 35: "Black",
	36: "Red"
}

func get_colour(number: int) -> Color:
	match wheel_colours.get(number, "Green"):
		"Red":   return red_color
		"Black": return black_color
		_:       return Color.GREEN
