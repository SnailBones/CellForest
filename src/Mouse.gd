extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var old_position
var forest

func _ready():
	old_position = get_viewport().get_mouse_position()
	forest = get_tree().get_nodes_in_group("forest")[0]
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	old_position = global_position
	global_position = get_viewport().get_mouse_position()
	var change = (global_position-old_position).length()
	if (change > 0):
		for tree in forest.get_children():
			var distance = (tree.global_position-global_position).length()
			# print("distance is", distance)
			# if distance < 100:
			# 	var damage = (100-distance)*(100-distance)*change/1000
			# 	tree.height = max(0, tree.height-damage)
			if distance < 60:
				tree.onfire = true
				# tree.update()
	pass
