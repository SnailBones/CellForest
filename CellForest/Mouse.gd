extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var old_position
var forest
const effect = 80

func _ready():
	global_position = get_viewport().get_mouse_position()
	forest = get_tree().get_nodes_in_group("forest")[0]
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

# func inRange(vect1, vect,)


func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	old_position = global_position
	global_position = get_viewport().get_mouse_position()
	if (old_position != global_position):
		var change = (global_position-old_position).length()
		if (change > 100):
			var speed = change/delta
			# var speedRoot = sqrt(speed)*2+10
			forest.handleMouse(global_position, speed);
			# for tree in forest.get_children():
			# 	# if tree.isATree():
			# 	var distance = (tree.global_position-global_position).length_squared()
			# 	# print("distance is", distance)
			# 	# if distance < 100:
			# 	# 	var damage = (100-distance)*(100-distance)*change/1000
			# 	# 	tree.height = max(0, tree.height-damage)
			# 	if distance < speed+20:
			# 		# tree.tree.on_fire = true
			# 		# tree.lightOnFire();
			# 		# # forest.next_state
			# 		# tree.update()
	# if Input.is_action_pressed("Mouse_Action"):
	# 	print ("DOWN")
	if Input.is_mouse_button_pressed(2):  # Right mouse button.
		# print('Left mouse button pressed. ', get_viewport().get_mouse_position())
		for tree in forest.get_children():
			var distance = (tree.global_position-global_position).length()
			if distance < 80:
				tree.tree.elevation = tree.tree.elevation + (.4 * (1-distance/effect))
				# tree.elevation = tree.elevation - (.4 * (distance/effect-.7))
	if Input.is_mouse_button_pressed(1):  # Left mouse button.
		# print('Left mouse button pressed. ', get_viewport().get_mouse_position())
		for tree in forest.get_children():
			var distance = (tree.global_position-global_position).length()
			if distance < 80:
				tree.tree.elevation = tree.tree.elevation + (.4 * (distance/effect-1))
				# tree.elevation = tree.elevation + (.4 * (distance/effect-.7))

# func _input(event):
# 	# Mouse in viewport coordinates
# 	if event is InputEventMouseButton:
# 		if event.button_index == BUTTON_LEFT:
# 			for tree in forest.get_children():
# 				var distance = (tree.global_position-global_position).length_squared()
# 				if distance < 20:
# 						tree.species = 3
# 						tree.height = 1
# 					# print ("left click")
# 					# build a mountain
# 					# print ("right click")
