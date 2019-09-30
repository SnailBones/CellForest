extends Container

# export(NodePath) var pathToPlayer = "Area2D/Forest"

# func _ready():
# 	var myPlayer = get_Node(pathToPlayer)

func toggleMenu():
	visible = !visible

func showLoop():
	pass


func toggleMinimap(val):
	print("toggled minimap ", val)


func changeSpeedTo(speed):
	print("speed changed to", speed)