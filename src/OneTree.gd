extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	VisualServer.set_default_clear_color(Color(0.0,0.0,0.4))
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	# update() # redraw. Only call if redrawing is needed.
	pass

func _draw():
    # Your draw commands here
	var center = Vector2(100, 100)
	var radius = 80
	var angle_from = 75
	var angle_to = 195
	var color = Color(1.0, 0.0, 0.0)
	draw_line(Vector2(0,0), Vector2(50, 50), Color(255, 0, 0), 10)
	draw_circle_arc(center, radius, angle_from, angle_to, color)
	#var me = get_global_position()
	var me = Vector2(0,0)
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

func draw_circle_arc(center, radius, angle_from, angle_to, color):
    var nb_points = 32
    var points_arc = PoolVector2Array()

    for i in range(nb_points+1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

    for index_point in range(nb_points):
        draw_line(points_arc[index_point], points_arc[index_point + 1], color)
