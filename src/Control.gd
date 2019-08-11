extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var BACKGROUND = Color("180f16")

var XGAP = 24
var YGAP = 12
var ROWS = 4
var COLUMNS = 12

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	VisualServer.set_default_clear_color(BACKGROUND)
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	# update() # redraw. Only call if redrawing is needed.
	pass

func _draw():
    # Your draw commands here
	#var me = get_global_position()
	for i in range(-ROWS, ROWS):
		for j in range(-COLUMNS, COLUMNS):
			var me = Vector2(j*XGAP,i*YGAP)
			draw_pine(me, 50, Color(255, 255, 0))

func draw_pine(me, height, color): #height in pixels
	var x = me.x
	var y = me.y
	var lw = 2
	var trunk_height = .2 * height
	var width = .2 * height
	var leftCorner = Vector2(x-width, y-trunk_height)
	var rightCorner = Vector2(x+width, y-trunk_height)
	var top = Vector2(x, y-height)
	draw_line(me,Vector2(x, y-trunk_height), color, lw) #trunk
	draw_line(leftCorner,top, color, lw)
	draw_line(rightCorner,top, color, lw)
	draw_line(rightCorner,leftCorner, color, lw)
	draw_polygon([leftCorner, rightCorner, top], [BACKGROUND])
