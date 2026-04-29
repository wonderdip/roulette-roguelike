extends Node

signal update_bet

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

var BET_TYPE_PAYOUTS: = {
	BetType.STRAIGHT: 35, 
	BetType.SPLIT: 17, 
	BetType.STREET: 11, 
	BetType.CORNER: 8,
	BetType.DOUBLE_STREET: 5,
	BetType.ODD: 1, 
	BetType.EVEN: 1, 
	BetType.RED: 1, 
	BetType.BLACK: 1, 
	BetType.ONE_TO_18: 1, 
	BetType.NINETEEN_TO_36: 1, 
	BetType.FIRST_12: 2, 
	BetType.SECOND_12: 2, 
	BetType.THIRD_12: 2, 
	BetType.COLUMN_1: 2, 
	BetType.COLUMN_2: 2, 
	BetType.COLUMN_3: 2, 
}

const BET_TYPE_COUNTS : Dictionary[BetType, int] = {
	BetType.STRAIGHT: 1,
	BetType.SPLIT: 2,
	BetType.STREET: 3,
	BetType.CORNER: 4,
	BetType.DOUBLE_STREET: 6,
	BetType.ODD: 18,
	BetType.EVEN: 18,
	BetType.RED: 18,
	BetType.BLACK: 18,
	BetType.ONE_TO_18: 18,
	BetType.NINETEEN_TO_36: 18,
	BetType.FIRST_12: 12,
	BetType.SECOND_12: 12,
	BetType.THIRD_12: 12,
	BetType.COLUMN_1: 12,
	BetType.COLUMN_2: 12,
	BetType.COLUMN_3: 12,
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


enum GamePhase{
	BETTING,
	START_SPIN,
	END_SPIN,
	SHOP,
}

var current_bet: Bet
var current_chip: PokerChip
var current_money: float
@export var starter_money: int

var current_phase: GamePhase = GamePhase.BETTING
var max_spins: int = 4
var spins: int = 0
var spinning: bool = false
var current_round: int = 1

func _ready() -> void:
	randomize()
	current_money = starter_money
	
	
func get_odds(bet_type: BetType) -> float:
	var numbers: float = BET_TYPE_COUNTS.values()[bet_type]
	return (numbers / 36)*100

func calculate_payout(bet: Bet, bet_amount: int) -> float:
	if not BET_TYPE_PAYOUTS.has(bet.type):
		return 0
	
	var multiplier = BET_TYPE_PAYOUTS[bet.type]
	return bet_amount * multiplier

func is_bet_winner(bet: Bet, winning_number: int) -> bool:
	if current_bet:
		match bet.type:
			BetType.STRAIGHT:
				return bet.number == winning_number
			
			BetType.RED:
				return number_to_color(winning_number) == BetColor.RED
			
			BetType.BLACK:
				return number_to_color(winning_number) == BetColor.BLACK
			
			BetType.EVEN:
				return winning_number != 0 and winning_number % 2 == 0
			
			BetType.ODD:
				return winning_number % 2 == 1
			
			_:
				return bet.bet_zone.numbers.has(winning_number)
	return false

func place_bet(bet_zone: BetZone):
	current_bet = Bet.new()
	current_bet.type = bet_zone.bet_type
	
	current_bet.color = BetColor.NONE
	current_bet.number = 0
	current_bet.bet_zone = bet_zone
	
	if current_bet.type == BetType.STRAIGHT and bet_zone.numbers.size() > 0:
		current_bet.number = bet_zone.numbers[0]
		current_bet.color = number_to_color(current_bet.number)
		
	update_bet.emit()
	
func type_to_string(type: BetType):
	match type:
		BetType.STRAIGHT: return "Straight"
		BetType.SPLIT: return "Split"
		BetType.STREET: return "Street"
		BetType.DOUBLE_STREET: return "Double Street"
		BetType.CORNER: return "Corner"
		BetType.ODD: return "Odd"
		BetType.EVEN: return "Even"
		BetType.RED: return "Red"
		BetType.BLACK: return "Black"
		BetType.ONE_TO_18: return "First 18"
		BetType.NINETEEN_TO_36: return "Second 18"
		BetType.FIRST_12: return "First Dozen"
		BetType.SECOND_12: return "Second Dozen"
		BetType.THIRD_12: return "Third Dozen"
		BetType.COLUMN_1: return "First Column"
		BetType.COLUMN_2: return "Second Column"
		BetType.COLUMN_3: return "Third COlumn"

func number_to_color(number: int) -> BetColor:
	return DEFAULT_NUMBER_COLORS[number]
	
func get_color(bet_color: BetColor) -> Color:
	match bet_color:
		BetColor.NONE:
			return Color("1d4a21")
		BetColor.RED:
			return RED_COLOR
		BetColor.BLACK:
			return BLACK_COLOR
	return Color.PINK
