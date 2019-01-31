extends Node2D

# class member variables go here, for example:
var leg_position= 0.0
var anim_speed = .02
var goal
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	VisualServer.set_default_clear_color(Color(0.0,0.0,0.4))
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	leg_position= fmod(leg_position+anim_speed, 1)
	var food = get_nearest_food()
	approach(food, delta)
	update() # redraw. Only call if redrawing is needed.
	pass

func _draw():
	var me = Vector2(0,0)
	draw_me(me, 50, abs(.5-leg_position) ,Color(255, 255, 255))

func draw_me(me, height, pos, color): #height in pixels
	var x = me.x
	var y = me.y
	var lw = 2
	var width = 1 * height * pos
	var leftCorner = Vector2(x-width, y)
	var rightCorner = Vector2(x+width, y)
	var top = Vector2(x, y-height)
	# draw_line(me,Vector2(x, y-trunk_height), color, lw) #trunk
	draw_line(leftCorner,top, color, lw)
	draw_line(rightCorner,top, color, lw)


func get_nearest_food():
	var spawn_points = get_tree().get_nodes_in_group("plants")
	var us = to_global(position)
	var nearest_plant = spawn_points[0]
	var smallest_distance = us.distance_to(to_global(nearest_plant.position))
	for spawn_point in spawn_points:
		var distance = us.distance_to(to_global(nearest_plant.position))
		if distance < smallest_distance:
			nearest_plant = spawn_point
			smallest_distance = distance
	return nearest_plant

func approach(goal, delta):
	var SPEED = 50
	var vector = ((to_global(goal.position) - to_global(position)).normalized())
	# print("goal is", goal)
	# print("vector is", vector)

	position = position + vector * SPEED * delta
	#move(vector * SPEED * delta)
