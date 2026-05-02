extends Node2D

@export var layout_segment_scene: PackedScene

@export var segment_width: int = 40
@export var segment_height: int = 32
@export var columns: int = 12
@export var rows: int = 3
@export var grid_offset: int = 2

@export var cell_size: Vector2 = Vector2(40, 32)
@onready var grid_start: Marker2D = $GridStart
@onready var layout_area: Area2D = $Area2D

var start_pos: Vector2i

func _ready() -> void:
	start_pos = grid_start.global_position
	spawn_segments()
	spawn_split_bets()
	spawn_straight_bets()
	spawn_corner_bets()
	spawn_street_bets()
	spawn_double_street_bets()
	spawn_dozen_bets()
	spawn_column_bets()
	spawn_eighteen_bets()
	spawn_even_odd_bets()
	spawn_colour_bets()
	layout_area.add_to_group("layout_area")
	
func spawn_segments():
	for i in range(Global.DEFAULT_NUMBER_COLORS.size()):
		var segment_node = layout_segment_scene.instantiate() as LayoutSegment
		$Segments.add_child(segment_node, true)
		
		var col = i % rows
		var row = i / rows
		
		segment_node.global_position = Vector2(
			start_pos.x + (segment_width * 0.5) + col * (segment_width + grid_offset) - 1,
			start_pos.y + (segment_height * 0.5) + row * (segment_height + grid_offset) + 1
		)
		
		segment_node.set_layout_segment(i+1, Global.DEFAULT_NUMBER_COLORS.get(i+1))

func get_cell_center(number: int) -> Vector2:
	var col = (number - 1) % rows
	var row = (number - 1) / rows
	var global_pos = Vector2(
		start_pos.x + col * (segment_width + grid_offset),
		start_pos.y + row * (segment_height + grid_offset)
	)+ Vector2(segment_width, segment_height) * 0.5
	return $Bets.to_local(global_pos)

func spawn_straight_bets() -> void:
	for number in Global.DEFAULT_NUMBER_COLORS.keys():
		var zone = BetZone.new()
		zone.bet_type = Global.BetType.STRAIGHT
		zone.numbers = [number]
		zone.position = get_cell_center(number)
		var shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(34, 26)
		zone.add_child(shape)
		zone.name = Global.BetType.keys()[zone.bet_type]
		$Bets/StraightBets.add_child(zone, true)

func spawn_split_bets() -> void:
	# Horizontal splits (left-right neighbors: 1-2, 2-3, 4-5, etc.)
	for number in range(1, 37):
		if number % 3 != 0:
			var zone = BetZone.new()
			zone.bet_type = Global.BetType.SPLIT
			zone.numbers = [number, number + 1]
			zone.position = get_cell_center(number) + Vector2(cell_size.x * 0.5 + 1, 0)
			
			var shape = CollisionShape2D.new()
			shape.debug_color = Color(0, 0, 1, 0.3)
			shape.shape = RectangleShape2D.new()
			shape.shape.size = Vector2(7, 26)
			zone.add_child(shape)
			zone.name = Global.BetType.keys()[zone.bet_type]
			$Bets/SplitBets.add_child(zone, true)

	# Vertical splits (up-down neighbors: 1-4, 2-5, 3-6, etc.)
	for number in range(1, 34):
		var zone = BetZone.new()
		zone.bet_type = Global.BetType.SPLIT
		zone.numbers = [number, number + 3]
		zone.position = get_cell_center(number) + Vector2(0, cell_size.y * 0.5)
		
		var shape = CollisionShape2D.new()
		shape.debug_color = Color(0, 0, 1, 0.3)
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(34, 7)
		zone.add_child(shape)
		zone.name = Global.BetType.keys()[zone.bet_type]
		$Bets/SplitBets.add_child(zone, true)

func spawn_corner_bets() -> void:
	for number in range(1, 34):
		if number % 3 != 0:
			var zone = BetZone.new()
			zone.bet_type = Global.BetType.CORNER
			zone.numbers = [number, number + 1, number + 3, number + 4]
			zone.position = (
				get_cell_center(number) 
				+ Vector2(
					cell_size.x * 0.5 + 1, 
					cell_size.y * 0.5 + 1)
					) 
			
			var shape = CollisionShape2D.new()
			shape.debug_color = Color(0, 1, 0, 0.3)
			shape.shape = RectangleShape2D.new()
			shape.shape.size = Vector2(8, 8)
			zone.add_child(shape)
			zone.name = Global.BetType.keys()[zone.bet_type]
			$Bets/CornerBets.add_child(zone, true)

func spawn_street_bets():
	for number in range(1, 37, 3):
		if number % 3 != 0:
			var zone = BetZone.new()
			zone.bet_type = Global.BetType.STREET
			zone.numbers = [number, number + 1, number + 2]
			zone.position = (
				get_cell_center(number)
				+ Vector2(-cell_size.x * 0.5 - 1, 0))
			
			var shape = CollisionShape2D.new()
			shape.debug_color = Color(1, 0, 0, 0.3)
			shape.shape = RectangleShape2D.new()
			shape.shape.size = Vector2(8, 13)
			zone.add_child(shape)
			zone.name = Global.BetType.keys()[zone.bet_type]
			$Bets/StreetBets.add_child(zone, true)

func spawn_double_street_bets():
	for number in range(1, 34, 3):
		if number % 3 != 0:
			var zone = BetZone.new()
			zone.bet_type = Global.BetType.DOUBLE_STREET
			zone.numbers = [number, number + 1, number + 2, number + 3, number + 4, number + 5]
			zone.position = (
				get_cell_center(number)
				+ Vector2(
					-cell_size.x * 0.5 - 1, 
					cell_size.y * 0.5 + 1)
				)
				
			var shape = CollisionShape2D.new()
			shape.debug_color = Color(1, 0.5, 0, 0.3)
			shape.shape = RectangleShape2D.new()
			shape.shape.size = Vector2(8, 8)
			zone.add_child(shape)
			zone.name = Global.BetType.keys()[zone.bet_type]
			$Bets/DoubleStreetBets.add_child(zone, true)
			
func spawn_dozen_bets():
	var dozen_types = [Global.BetType.FIRST_12, Global.BetType.SECOND_12, Global.BetType.THIRD_12]
	
	for i in range(3):
		var start = i * 12 + 1  # 1, 13, 25
		var zone = BetZone.new()
		zone.bet_type = dozen_types[i]
		zone.numbers = range(start, start + 12)  # 1-12, 13-24, 25-36
		
		# Anchor to the first number of this dozen, then push below the grid
		var first_cell = get_cell_center(start)
		zone.position = Vector2(
			first_cell.x - (33 + grid_offset) * 0.5 - 33 * 0.5 - 4.5,
			first_cell.y + segment_height * 1.5 + grid_offset + 1
		)
		
		var shape = CollisionShape2D.new()
		shape.debug_color = Color(0.5, 0.5, 0.5, 0.3)
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(10, 120)
		zone.add_child(shape)
		zone.name = Global.BetType.keys()[zone.bet_type]
		$Bets/DozenBets.add_child(zone, true)

func spawn_column_bets():
	var column_types = [Global.BetType.COLUMN_1, Global.BetType.COLUMN_2, Global.BetType.COLUMN_3]
	for i in range(3):
		var zone = BetZone.new()
		zone.bet_type = column_types[i]
		zone.numbers = []
		
		# Column i+1 contains numbers: i+1, i+4, i+7, ... i+34
		for num in range(i + 1, 37, 3):
			zone.numbers.append(num)
			
		zone.position = Vector2(get_cell_center(i + 1).x, (cell_size.y+grid_offset) * (columns) + cell_size.y * 0.5 + grid_offset* 2)
		
		var shape = CollisionShape2D.new()
		shape.debug_color = Color(0.0, 0.0, 0.0, 0.3)
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(34, 26)
		zone.add_child(shape)
		zone.name = Global.BetType.keys()[zone.bet_type]
		$Bets/ColumnBets.add_child(zone, true)
		
func spawn_eighteen_bets():
	var bet_types = [Global.BetType.ONE_TO_18, Global.BetType.NINETEEN_TO_36]
	for i in range(2):
		var start = i * 18 + 1
		var zone = BetZone.new()
		zone.bet_type = bet_types[i]
		zone.numbers = range(start, start + 18)
		
		var first_cell = get_cell_center(start)
		zone.position = Vector2(
			first_cell.x - (33*2 + grid_offset) - 5,
			first_cell.y + 33 * 0.5 + grid_offset - 1 + (i*(33+grid_offset * 0.5)*4)
		)
		
		var shape = CollisionShape2D.new()
		shape.debug_color = Color(0.5, 0.5, 0.5, 0.3)
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(33, 66)
		zone.add_child(shape)
		zone.name = Global.BetType.keys()[zone.bet_type]
		$Bets/EighteenBets.add_child(zone, true)
		
func spawn_even_odd_bets():
	var even_zone = BetZone.new()
	even_zone.bet_type = Global.BetType.EVEN
	for num in range(2, 37, 2):
		even_zone.numbers.append(num)
	
	var odd_zone = BetZone.new()
	odd_zone.bet_type = Global.BetType.ODD
	for num in range(1, 37, 2):
		odd_zone.numbers.append(num)
	
	var zones = [even_zone, odd_zone]
	for i in range(zones.size()):
		var zone = zones[i]
		var anchor = get_cell_center(1)  # use number 1 as left anchor
		zone.position = Vector2(
			anchor.x - (33*2 + grid_offset) - 5,
			anchor.y + 33 * 2.5 + grid_offset*2 - 1 + (i*(33+grid_offset * 0.5)*6)
		)
		
		var shape = CollisionShape2D.new()
		shape.debug_color = Color(0.5, 0.5, 0.5, 0.3)
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(33, 66)
		zone.add_child(shape)
		$Bets/OddEven.add_child(zone, true)
		zone.name = Global.BetType.keys()[zone.bet_type]

func spawn_colour_bets():
	var red_zone = BetZone.new()
	red_zone.bet_type = Global.BetType.RED
	for num in range(1, 37):
		if Global.DEFAULT_NUMBER_COLORS[num] == Global.BetColor.RED:
			red_zone.numbers.append(num)
	
	var black_zone = BetZone.new()
	black_zone.bet_type = Global.BetType.BLACK
	for num in range(1, 37):
		if Global.DEFAULT_NUMBER_COLORS[num] == Global.BetColor.BLACK:
			black_zone.numbers.append(num)
			
	var zones = [red_zone, black_zone]
	for i in range(zones.size()):
		var zone = zones[i]
		var anchor = get_cell_center(1)  # use number 1 as left anchor
		zone.position = Vector2(
			anchor.x - (33*2 + grid_offset) - 5,
			anchor.y + 33 * 4.5 + grid_offset*3 - 1 + (i*(33+grid_offset * 0.5)*2)
		)
		
		var shape = CollisionShape2D.new()
		shape.debug_color = Color(0.687, 0.622, 0.0, 0.3)
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(33, 66)
		zone.add_child(shape)
		$Bets/ColourBets.add_child(zone, true)
		zone.name = Global.BetType.keys()[zone.bet_type]
