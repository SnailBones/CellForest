extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var BACKGROUND = Color("180f16")

var YGAP = 10
var XGAP = YGAP*2

var ROWS = 40
var COLUMNS = 40

var PINE = {
	"crowdGrowUntil": .4,
	"crowdDie": .41,
	"spreadMin": .2,
	"spreadMax": .3,

	"growRate":  .6,
	"burnRate": .3,
}
var BIRCH = {
	"crowdGrowUntil": .1,
	"crowdDie": .15,
	"spreadMin": .03,
	"spreadMax": .12,
	"growRate":  .6,
	"burnRate": .3,
}
var FIRE = {
	"spreadMinimum": .02,
	"extinguishChance": .01
}

var trees = []

func _ready():
	# var screen_size = OS.get_screen_size(screen=0)
	# var window_size = OS.get_window_size()
	# OS.set_window_position(screen_size*0.5 - window_size*0.5)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	# this doesn't work
	VisualServer.set_default_clear_color(BACKGROUND)

	# var tree_script = load("Tree.gd")
	# var tree_script = load("Tree.tscn")
	var tree_script = preload("Tree.tscn")
	for i in range(-ROWS/2, ROWS/2):
		var row = []
		for j in range(-COLUMNS/2, COLUMNS/2):
			# var instance = tree_script.new(i, j)
			var instance = tree_script.instance()
			# print("instance is", instance)
			instance.position = Vector2((i-j)*XGAP,(i+j)*YGAP)
			var rand = randf()*2
			if rand > .5:
				instance.height = rand
			else:
				instance.height = 0
			instance.species = randi() % 2
			# instance.XPOSITION = i
			# instance.YPOSITION = j
			add_child(instance)
			row.append(instance)
			instance.update()
			# instance.my_init_setter(a,b,c,d)
		trees.append(row)
	print("trees is", trees)
	pass

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	# update() # redraw. Only call if redrawing is needed.
	for i in range(trees.size()):
		for j in range(trees[0].size()):
			var tree = trees[i][j]
			# if tree.height < 1:
			var neighbors = get_neighbors(i, j)
			growMe(tree, neighbors, delta)
	# pass

func growMe(tree, neighbors, delta):
	var pine = 0;
	var birch = 0;
	var fire = 0;
	for k in range(neighbors.size()):
		var neighbor = neighbors[k]
		if neighbor.onfire:
			fire += neighbor.height
		elif neighbor.species == 0:
			pine += neighbor.height
		else:
			birch += neighbor.height

	# scarcity of localresources
	var sum = (pine + birch + tree.height)/(neighbors.size()+1)
	# var sum = (pine + birch)/(neighbors.size())
	pine = pine/neighbors.size()
	birch = birch/neighbors.size()
	fire = fire/neighbors.size()
 #understory needs to not compete directly
 # var BIRCH = {
	#  "crowdGrowUntil": .1,
	#  "crowdDie": .2,
	#  "spreadMin": .01,
	#  "spreadMax": .6,
	#  "growRate":  .2,
 # }

	var s
	var grow = false;

	if tree.height == 0 && sum < PINE.spreadMax && fire < FIRE.spreadMinimum:
		if birch > BIRCH.spreadMin && sum < BIRCH.spreadMax:
			tree.species = 1
			grow = true
		elif pine > PINE.spreadMin:
			tree.species = 0
			grow = true
	if tree.species == 0:
		s = PINE;
	else:
		s = BIRCH;

	if tree.height > 0:
		if fire > FIRE.spreadMinimum:
			tree.onfire = true
		elif sum > s.crowdDie: #&& sum > tree.height:
			tree.height = 0;
		elif sum < s.crowdGrowUntil:
			grow = true;
	if tree.onfire:
		tree.height -= s.burnRate
		if randf() < FIRE.extinguishChance:
			tree.onfire = false;
		if tree.height <= 0:
			tree.height = 0
			tree.onfire = false
	elif grow:
		tree.height += s.growRate * delta;
	tree.stress = sum/s.crowdDie
	tree.update()


func _draw():
	pass
		# Your draw commands here
	# var center = Vector2(100, 100)
	# var radius = 80
	# var angle_from = 75
	# var angle_to = 195
	# var color = Color(1.0, 0.0, 0.0)
	# draw_line(Vector2(0,0), Vector2(50, 50), Color(255, 0, 0), 10)
	# #var me = get_global_position()
	# var me = Vector2(0,0)
	# draw_pine(me, 50, Color(255, 0, 255))

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

func get_neighbors(x, y):
	var maxX = trees.size()-1;
	var maxY = trees[0].size()-1;
	# print("x is", x, "y is", y)
	# print("maxX is", maxX, "maxY is", maxY)
	# print("x[4] is", trees[4])
	var neighbors = []
	if x > 0:
		neighbors.append(trees[x-1][y])
		if y > 0:
			neighbors.append(trees[x-1][y-1])
		if y < maxY:
				neighbors.append(trees[x-1][y+1])

	if x < maxX:
		neighbors.append(trees[x+1][y])
		if y > 0:
			neighbors.append(trees[x+1][y-1])
		if y < maxY:
				neighbors.append(trees[x+1][y+1])

	if y > 0:
		neighbors.append(trees[x][y-1])

	if y < maxY:
		neighbors.append(trees[x][y+1])
	return neighbors

func draw_circle_arc(center, radius, angle_from, angle_to, color):
		var nb_points = 32
		var points_arc = PoolVector2Array()

		for i in range(nb_points+1):
				var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
				points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

		for index_point in range(nb_points):
				draw_line(points_arc[index_point], points_arc[index_point + 1], color)
