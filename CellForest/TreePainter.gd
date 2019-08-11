extends Node2D

const ARRAY2D = preload("bin/grid.gdns")
# const ARRAY2D = preload("2dArray.gd")
const CELLSCRIPT = preload("bin/cell.gdns")

export(PackedScene) var Text

const PERF_SCRIPT = preload("Measure.gd")
onready var PERF_TESTER = PERF_SCRIPT.new("Painting")

var BACKGROUND = Color("180f16")
var TRUNK_COLOR = Color(50, 100, 0)
# var GRID_COLOR = Color(5, 255, 50)

# var XPOSITION
# var YPOSITION

# var height = 0;
var GRID_HEIGHT = 8;
var MAX_HEIGHT = 40;
# var GROWTH_SPEED = 40;
var LW = 1 # Line weight
var EXAGGERATION = 30; #terrain exageration

var YGAP = 5
var XGAP = YGAP*2

# var species = 0
# var stress = 0
# var onfire = false
# var water = .01;
# var elevation = 0
# var sediment = 0

# var state: ARRAY2D;
var state
# var tree
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

# func _init(x, y):
# 	var draw_x = x*20
# 	var draw_y = y*20
# 	print("init!")
# 	update()
	# set_pos(draw_x, draw_y)


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

# func die():
# 	height = 0
# 	onfire = false
# 	species = 0;
# 	stress = 0;

func visualize(trees):
	print("in tree painter! setting state to trees")
	state = trees;
	print("state is", trees)
	update();

func worldToScreen(i, j):
	return Vector2((i-j)*XGAP,(i+j-state.height/2)*YGAP)

func screenToWorld(x, y):
	var i = (x/XGAP +y/YGAP)/2 + state.height/4
	var j = (y/YGAP - x/XGAP)/2 + state.height/4
	return Vector2(i, j)


func _draw():
	print("drawing!")
	if state == null:
		print("null state")
		return;
	PERF_TESTER.start()
	# print("state.width is", state.width)
	# print("state.height is", state.height)
	# var sprite = get_tree().get_nodes_in_group("sprite")[0]
	# var forest = get_tree().get_nodes_in_group("forest")[0]
	# sprite.offset = get_viewport().get_mouse_position()
	# var mouse = get_viewport().get_mouse_position()
	# var worldPos = (screenToWorld(mouse.x, mouse.y))
	# sprite.set_global_position(worldToScreen(worldPos.x, worldPos.y))
	# draw_birch(get_viewport().get_mouse_position()-forest.get_global_position(), 100, Color(0.0, 1.0, 1.0))
	# draw_birch(get_viewport().get_mouse_position(), 100, Color(1.0, 1.0, 0.0))
	var cell;
	for i in range(state.width):
		for j in range(state.height):
			var position = worldToScreen(i, j)
			# print("getting cell", i, j)
			# state.lorax(i, j)
			cell = state.getCell(i, j)
			# print("cell is", cell)
			if cell != null:
				draw(cell, position)
			else:
				print("cell is null")
	# draw(tree, Vector2(0, 0))
	print("done drawing!")
	PERF_TESTER.stop()
func draw(cell, position):
	# print ("cell is", cell)
	# print("elevation is", cell.elevation)
	# var label
	# if get_children().size()== 0:
	# 	label = Label.new()
	# 	add_child(label)
	# else:
	# 	label = get_children()[0]
	# label.text = var2str(height)
	# var gridColor
	var me = Vector2(0,0 - cell.elevation * EXAGGERATION) + position;
	# me += position;
	var color
	if cell.on_fire && cell.height > 0:
		color = Color(1.0, 0.0, 1.0)
		# color = Color(1.0, 1.0, 1.0)
	else:
		# TODO: just calculate stress here, i don't need it as a property
		var stress = cell.stress
		if cell.species == 1:
			# color = Color(0.0, 1-stress/2, stress+.2)
			color = Color(0.0, stress, 1-stress/2)
		elif cell.species == 2:
			color = Color(stress*2+.2, (1-stress)*2, 0.0)
		elif cell.species == 3:
			color = Color(7.0, 7.0, 7.0)
	# print("stress is", stress)
	# red to yellow to green
	var green
	if cell.water < .5:
		green = cell.water
	else:
		green = 1-cell.water
	# var landColor = Color(1-water*2,green*2,(water-.5)*2)
	# var landColor = Color(sediment*6, 1-(elevation-1)/4, water)
	# var landColor = Color((elevation-1)/4, 1-sediment*12, water)
	var landColor = Color(.3, .3, cell.water)
	# var landColor = Color(elevation/2, 0, 1-elevation/2)
	# var landColor = Color(sediment*10, 0, 0)
	draw_grid(me, GRID_HEIGHT, landColor)
	# draw_box(me, GRID_HEIGHT, elevation * EXAGGERATION, Color(1-water*2,green*2,(water-.5)*2))
	# print("me is ", me.y, " height is ", cell.height)
	if cell.species == 1:
		# draw_grid(me, GRID_HEIGHT, color)
		draw_spruce(me, cell.height*MAX_HEIGHT, color)
	elif cell.species == 2:
		# draw_grid(me, GRID_HEIGHT, color)
		draw_birch(me, cell.height*MAX_HEIGHT, color)
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
	draw_polygon([leftCorner, rightCorner, top], [BACKGROUND])
	draw_line(me,Vector2(x, y-trunk_height), color, LW) #trunk
	draw_line(leftCorner,top, color, LW)
	draw_line(rightCorner,top, color, LW)
	# draw_line(rightCorner,leftCorner, color, LW)

func draw_birch(me, height, color): #height in pixels
	var x = me.x
	var y = me.y
	var trunk_height = .2 * height
	var width = .2 * height
	height = height*.8
	var leftCorner = Vector2(x-width, y-trunk_height)
	var rightCorner = Vector2(x+width, y-trunk_height)
	var topLeft = Vector2(x-width, y-height)
	var topRight = Vector2(x+width, y-height)
	draw_polygon([leftCorner, rightCorner, topRight, topLeft], [BACKGROUND])
	draw_line(me,Vector2(x, y-trunk_height), color, LW) #trunk
	draw_line(leftCorner,topLeft, color, LW)
	draw_line(rightCorner,topRight, color, LW)
	draw_line(topRight, topLeft, color, LW)
	# draw_line(rightCorner,leftCorner, color, LW)

func draw_grid(me, height, color):
	var x = me.x
	var y = me.y
	var left = Vector2(me.x-height, me.y)
	var right = Vector2(me.x+height, me.y)
	var top = Vector2(me.x, me.y+height/2)
	var bottom = Vector2(me.x, me.y-height/2)
	draw_line(left, top, color, LW)
	draw_line(top, right, color, LW)
	# draw_line(right, bottom, color, LW)
	# draw_line(bottom, left, color, LW)

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
