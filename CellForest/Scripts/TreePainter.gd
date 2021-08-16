extends Node2D

const ARRAY2D = preload("res://bin/grid.gdns")
# const ARRAY2D = preload("2dArray.gd")
const CELLSCRIPT = preload("res://bin/cell.gdns")

export(PackedScene) var Text

# const PERF_SCRIPT = preload("Measure.gd")
# onready var PERF_TESTER = PERF_SCRIPT.new("Painting")

var BACKGROUND = Color("180f16")
var TRUNK_COLOR = Color(50, 100, 0)
# var GRID_COLOR = Color(5, 255, 50)

# used in coloring
var spruce
var birch


# var height = 0;
var GRID_HEIGHT = 8;
var MAX_HEIGHT = 40;
# var GROWTH_SPEED = 40;
var LW = 2 # Line weight
var EXAGGERATION = 15; #terrain exageration

var YGAP = 5
var XGAP = YGAP*2

var state

var loop_world = false
# onready var screen_position = get_global_transform_with_canvas().origin

onready var screen_position = get_global_position()
# var screen_position = Vector2(0, 0)

# onready var window_size = OS.get_window_size()
# onready var window_size = get_viewport().size
# var window_size = Vector2(1024, 600)
var window_size = Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))

func _init(s, b):
	spruce = s
	birch = b

func setLabel(text, color = Color(0.0, 1.0, 1.0)):
	set("custom_colors/font_color", color)
	var label
	if get_children().size()== 0:
		label = Label.new()
		add_child(label)
	else:
		label = get_children()[0]
	# add_color_override("font_color", color)
	label.text = var2str(text)
	# label.color = color

func visualize(trees):
	state = trees;
	update();

func worldToScreen(i, j, elevation):
	return Vector2((i-j)*XGAP,(i+j-state.height/2)*YGAP - elevation * EXAGGERATION)

func screenToWorld(x, y):
	var i = (x/XGAP +y/YGAP)/2 + state.height/4
	var j = (y/YGAP - x/XGAP)/2 + state.height/4
	return Vector2(i, j)

func worldToLoopingScreen(i,j, elevation): # Makes things appear infinite...
	var all_of_em = [
		worldToScreen(i, j, elevation),
		worldToScreen(i,j+state.height, elevation),
		worldToScreen(i,j-state.height, elevation),
		worldToScreen(i+state.width,j, elevation),
		worldToScreen(i-state.width,j, elevation)
	]
	var on_screens = []
	# var margin = -80
	var margin = -32
	for new_position in all_of_em:
		if new_position.x > -screen_position.x-margin and new_position.y > -screen_position.y-margin and (new_position.x < window_size.x+margin - screen_position.x) and (new_position.y < window_size.y + margin - screen_position.y):
			on_screens.append(new_position)
	return on_screens

func getNeighborPositions(cell, neighbors):
	var neighbor1 = Vector2((1)*XGAP,(YGAP) - (neighbors[0].elevation-cell.elevation) * EXAGGERATION)
	var neighbor2 = Vector2((-1)*XGAP,(YGAP) - (neighbors[1].elevation-cell.elevation) * EXAGGERATION)
	return [neighbor1, neighbor2]

func _draw():
	if state == null:
		return;
	# draw_icon();
	# PERF_TESTER.start()
	var cell;
	for i in range(state.width):
		for j in range(state.height):
			cell = state.getCell(i, j)
			var neighbor1 = state.getLooping(i+1, j)
			var neighbor2 = state.getLooping(i, j+1)
			var neighbors
			var loop
			if loop_world:
				loop = worldToLoopingScreen(i, j, cell.elevation)
				# neighbors = [worldToLoopingScreen(i+1, j, neighbor1.elevation), worldToLoopingScreen(i, j+1, neighbor2.elevation)]

			else:
				loop = [worldToScreen(i, j, cell.elevation)]
				#neighbors = [[worldToScreen(i+1, j, neighbor1.elevation)]]
			if not loop == []:
				neighbors = getNeighborPositions(cell, [neighbor1, neighbor2])
				draw(cell, loop, neighbors, i, j)
	# PERF_TESTER.stop()
func draw(cell, positions, neighbors, i, j):
	# me += position;
	var color
	if cell.on_fire && cell.height > 0:
		color = Color(1.0, 0.0, 1.0)
		# color = Color(1.0, 1.0, 1.0)
	else:

		# 1 is water to grow, 0 is waterToLive death

		if cell.species == 1:
			# var stress = ((1-cell.water)+spruce.waterToLive)/(spruce.waterToGrow)
			var stress = 1-(cell.water-spruce.waterToLive)/spruce.waterToGrow
			# var stress = 1-(cell.water-spruce.waterToGrow)/(spruce.waterToLive)
			# color = Color(0.0, 1-stress/2, stress+.2)
			# color = Color(0.0, stress/2+.5, 1-stress/2)
			# Switching colors
			color = Color(0.0, 1-stress/2, stress/2+.5)
		elif cell.species == 2:
			var stress = 1-(cell.water-birch.waterToLive)/(birch.waterToGrow)
			# var stress = 1-(cell.water-birch.waterToGrow)/(birch.waterToLive)
			# var stress = ((1-cell.water)+birch.waterToLive)/(birch.waterToGrow)
			# var stress = ((1-cell.water)+birch.waterToLive)*(1-birch.waterToLive)
			color = Color(stress*.6+.4, (1-stress*.4), 0.0)
		elif cell.species == 3:
			color = Color(7.0, 7.0, 7.0)
	# print("stress is", stress)
	# red to yellow to green
	# var green
	# if cell.water < .5:
	# 	green = cell.water
	# else:
	# 	green = 1-cell.water
	# var landColor = Color(1-cell.water*2,green*2,(cell.water-.5)*2)
	# var landColor = Color(cell.sediment*6, 1-(cell.elevation-1)/4, cell.water*4)
	# var landColor = Color((cell.elevation-1)/4, 1-cell.sediment*12, cell.water)
	var landColor = Color(cell.sediment*6, cell.elevation/8, cell.water)

	# var landColor = Color(cell.test_var/4, cell.test_var, 1-cell.test_var)
	# var landColor = Color(cell.test_var*10, -cell.test_var*10, .2)
	# var landColor = Color(.3, .3, cell.water)
	# var landColor = Color(cell.water-1, .3, cell.water)
	# var landColor = Color(elevation/2, 0, 1-elevation/2)
	# var landColor = Color(sediment*10, 0, 0)
	# for position in positions:
	for i in range(positions.size()):
		var p = positions[i]
		#var neighbor_group = neighbors[i]
		# print("position is", position)
		# var me = Vector2(0,-cell.elevation * EXAGGERATION) + position;
		# draw_grid(p, GRID_HEIGHT, landColor)
		# draw_meshy(p, neighbors[i], landColor)

		for neighbor in neighbors: # do this twice
			draw_line(p, p+neighbor, landColor, LW)
		# for neighbor in neighbors[1][i]:
		# 	draw_line(p, neighbor[1][i], color, LW)
	var me = positions[0]
	# draw_box(me, GRID_HEIGHT, elevation * EXAGGERATION, Color(1-water*2,green*2,(water-.5)*2))
	# print("me is ", me.y, " height is ", cell.height)
	if cell.species == 1:
		# draw_grid(me, GRID_HEIGHT, color)
		draw_spruce(me, cell.height*MAX_HEIGHT, color)
	elif cell.species == 2:
		# draw_grid(me, GRID_HEIGHT, color)
		var flip = (i + j) % 2
		draw_birch(me, cell.height*MAX_HEIGHT, color, flip)
	elif cell.species == 3:
		if cell.height < 0:
			setLabel(cell.height, Color(1.0, 0.0, 0.0))
		# else:
			# setLabel(cell.height)
		draw_grid(me, -cell.height*GRID_HEIGHT, color)
		draw_grid(me, -GRID_HEIGHT-2, color)
	# else:
		# setLabel("")
	# setLabel(elevation)

func draw_spruce(me, height, color): #height in pixels
	var x = me.x
	var y = me.y
	var trunk_height = .2 * height
	var width = .2 * height
	var leftCorner = Vector2(x-width, y-trunk_height)
	var rightCorner = Vector2(x+width, y-trunk_height)
	var top = Vector2(x, y-height)
	# draw_polygon([leftCorner, rightCorner, top], [BACKGROUND])
	draw_line(me,Vector2(x, y-trunk_height), color, LW) #trunk
	draw_line(leftCorner,top, color, LW)
	draw_line(rightCorner,top, color, LW)
	draw_line(rightCorner,leftCorner, color, LW)

# func draw_birch(me, height, color): #height in pixels
# 	var x = me.x
# 	var y = me.y
# 	var trunk_height = .2 * height
# 	var width = .2 * height
# 	height = height*.8
# 	var leftCorner = Vector2(x-width, y-trunk_height)
# 	var rightCorner = Vector2(x+width, y-trunk_height)
# 	var topLeft = Vector2(x-width, y-height)
# 	var topRight = Vector2(x+width, y-height)
# 	# draw_polygon([leftCorner, rightCorner, topRight, topLeft], [BACKGROUND])
# 	draw_line(me,Vector2(x, y-trunk_height), color, LW) #trunk
# 	draw_line(leftCorner,topLeft, color, LW)
# 	draw_line(rightCorner,topRight, color, LW)
# 	draw_line(topRight, topLeft, color, LW)
# 	draw_line(rightCorner,leftCorner, color, LW)

func draw_birch(me, height, color, flip): #height in pixels
	var x = me.x
	var y = me.y
	var trunk_height = .2 * height
	var width = .2 * height
	height = height*.8
	# var leftCorner = Vector2(x-width, y-trunk_height)
	# var rightCorner = Vector2(x+width, y-trunk_height)
	# var topLeft = Vector2(x-width, y-height)
	# var topRight = Vector2(x+width, y-height)
	# draw_polygon([leftCorner, rightCorner, topRight, topLeft], [BACKGROUND])
	draw_line(me,Vector2(x, y-height), color, LW) #trunk
	if flip:
		width = -width

	draw_line(Vector2(x, y-height*.66), Vector2(x+width, y-height*.8), color, LW)
	draw_line(Vector2(x, y-height*.33), Vector2(x-width * 1.5, y-height*.6), color, LW)
	# draw_line(rightCorner,topRight, color, LW)
	# draw_line(topRight, topLeft, color, LW)
	# draw_line(rightCorner,leftCorner, color, LW)

func draw_grid(me, height, color):
	var x = me.x
	var y = me.y
	var right = Vector2(me.x+height, me.y)
	var top = Vector2(me.x, me.y+height/2)
	draw_line(top, right, color, LW)
	# draw_line(right, bottom, color, LW)
	# draw_line(bottom, left, color, LW)

func draw_meshy(me, neighbors, color):
	# draw_line(left, top, color, LW)
	for neighbor in neighbors:
		draw_line(me, neighbor, color, LW)

func draw_box(me, size, height, color):
	var x = me.x
	var y = me.y
	var left = Vector2(x-size, y)
	var right = Vector2(x+size, y)
	var top = Vector2(x, y-size/2)
	var bottom = Vector2(x, y+size/2)
	draw_line(left, top, color, LW)
	draw_line(top, right, color, LW)
	draw_line(right, bottom, color, LW)
	draw_line(bottom, left, color, LW)
	# drawing edges
	draw_line(bottom, Vector2(me.x, me.y+size/2+height), color, LW)
	draw_line(left, Vector2(me.x-size, me.y+height), color, LW)
	draw_line(right, Vector2(me.x+size, me.y+height), color, LW)

# func draw_icon():
# 	var position = worldToScreen(0,0)
# 	var stress = .2
# 	var color = Color(0.0, 1-stress/2, stress/2+.5)
# 	draw_spruce(position, 35, color)
# 	draw_grid(position, GRID_HEIGHT, Color(1,.5, 0))
