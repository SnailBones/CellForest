extends Node2D


var BACKGROUND = Color("180f16")
var TRUNK_COLOR = Color(50, 100, 0)
# var GRID_COLOR = Color(5, 255, 50)

var XPOSITION
var YPOSITION

var height = 0;
var GRID_HEIGHT = 17;
var MAX_HEIGHT = 40;
var GROWTH_SPEED = 40;
var LW = 1

var species
var stress = 0
var onfire = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

# func _init(x, y):
# 	var draw_x = x*20
# 	var draw_y = y*20
# 	print("init!")
# 	update()
	# set_pos(draw_x, draw_y)

func _process(delta):
	pass

func _draw():
	var gridColor
	if height > 0:
		var me = Vector2(0,0)
		var color
		if onfire:
			color = Color(1.0, 0.0, 1.0)
			# color = Color(1.0, 1.0, 1.0)
		else:
			if species == 0:
				color = Color(0.0, 1-stress/2, stress+.2)
			else:
				color = Color(stress*2+.2, (1-stress)*2, 0.0)
		# print("stress is", stress)
		# red to yellow to green
		if species == 0:
			draw_grid(me, GRID_HEIGHT, color)
			draw_pine(me, height*MAX_HEIGHT, color)
		else:
			draw_grid(me, GRID_HEIGHT, color)
			draw_birch(me, height*MAX_HEIGHT, color)

func draw_pine(me, height, color): #height in pixels
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
	draw_line(rightCorner,leftCorner, color, LW)

func draw_birch(me, height, color): #height in pixels
	var x = me.x
	var y = me.y
	var trunk_height = .2 * height
	var width = .2 * height
	# height = height*.8
	var leftCorner = Vector2(x-width, y-trunk_height)
	var rightCorner = Vector2(x+width, y-trunk_height)
	var topLeft = Vector2(x-width, y-height)
	var topRight = Vector2(x+width, y-height)
	draw_polygon([leftCorner, rightCorner, topRight, topLeft], [BACKGROUND])
	draw_line(me,Vector2(x, y-trunk_height), color, LW) #trunk
	draw_line(leftCorner,topLeft, color, LW)
	draw_line(rightCorner,topRight, color, LW)
	draw_line(topRight, topLeft, color, LW)
	draw_line(rightCorner,leftCorner, color, LW)

func draw_grid(me, height, color):
	var x = me.x
	var y = me.y
	var left = Vector2(me.x-height, me.y)
	var right = Vector2(me.x+height, me.y)
	var top = Vector2(me.x, me.y+height/2)
	var bottom = Vector2(me.x, me.y-height/2)
	draw_line(left, top, color, LW)
	draw_line(top, right, color, LW)
	draw_line(right, bottom, color, LW)
	draw_line(bottom, left, color, LW)
