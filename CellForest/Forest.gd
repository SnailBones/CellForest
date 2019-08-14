extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var BACKGROUND = Color("180f16")
# const TREESCRIPT = preload("tree.tscn")
# const GENERIC_ARRAY2D = preload("2dArray.gd")
const ARRAY2D = preload("bin/grid.gdns")
const CELLSCRIPT = preload("bin/cell.gdns")
const MODEL = preload("bin/model.gdns")
const TREE_PAINTER = preload("TreePainter.gd")


const PERF_SCRIPT = preload("Measure.gd")
var PERF_TESTER;

# var ROWS = 50
# var COLUMNS = 50

export var ROWS = 40
export var COLUMNS = 40

export var hills = 2
export var hill_height = 2



export var SPRUCE = {
	# "crowdGrowUntil": .4,
	# "crowdDie": .41,
	"waterToSprout": .3,
	"waterToGrow": .15,
	"waterToLive": .2,
	# "portionTaken": .8,
	"portionTaken": .33,
	# how much of the water to live and grow is consumed
	"spreadMin": .3,
	# "spreadMax": .3,

	"growRate":  .06,
	"burnRate": .4,
}
export var BIRCH = {
	"waterToSprout": .4,
	"waterToGrow": .2,
	"waterToLive": .25,
	"portionTaken": .33,
	# "crowdGrowUntil": .1,
	# "crowdDie": .15,
	"spreadMin": .06,
	# "spreadMin": 10.0,
	# "spreadMax": .12,
	"growRate":  .1,
	"burnRate": .4,
}

var FARM = {
	"spreadMin": .2,
	"treesToGrow": .2, # you need wood to build
	# "countMax": 10,
	"growRate": .1,
	"waterToSprout": .1,
	"waterToGrow": .11, # min water to grow
	"waterToLive": .8, # min water to not shrink
	"waterConsumption": .15, # water consumed every time
	# "water"
	"maxSize": 1,
	# "crowdDie": 1,
	# "crowdGrowUntil": .9,
	"burnRate": .2,
	# "treesToLive": .01
}

export var FIRE = {
	"spreadMin": .2,
	"extinguishChance": .00,
	"dryAmount": .3
}

export var WATER = {
	# Precipitation follows a sine curve
	"drySeason": .02,
	"wetSeason": .025,
	# "drySeason": .07,
	# "wetSeason": .09,
	"seasonLength": 24, # full cycle in simulation steps
	"evaporation": .01,
	"diffusion": 2,
	"runoff": 1, # Relationship between slope and water given away
	"erosion":.05,
	"suspended": .2 # Any float, higher numbers mean dirt travels further
	# var suspended = 0;
}


# C for classic

var C_SPRUCE = {
	# "crowdGrowUntil": .4,
	# "crowdDie": .41,
	"waterToSprout": .15,
	"waterToGrow": .11,
	"waterToLive": .1,
	"spreadMin": .4,
	# "spreadMax": .3,

	"growRate":  .08,
	"burnRate": .3,
}
var C_BIRCH = {
	"waterToSprout": .3,
	"waterToGrow": .21,
	"waterToLive": .2,
	# "crowdGrowUntil": .1,
	# "crowdDie": .15,
	"spreadMin": .06,
	# "spreadMax": .12,
	"growRate":  .12,
	"burnRate": .3,
}
var C_FIRE = {
	"spreadMinimum": .035,
	"extinguishChance": .00,
	"dryAmount": .02
}

export var C_WATER = {
	# Precipitation follows a sine curve
	# "drySeason": 0,
	# "wetSeason": .1,
	"drySeason": .1,
	"wetSeason": .12,
	"seasonLength": 24, # full cycle in simulation steps
	"evaporation": .01,
	"diffusion": 2,
	"runoff": 1, # Relationship between slope and water given away
	"erosion":.05,
	"suspended": .2 # Any float, higher numbers mean dirt travels further
	# var suspended = 0;
}

# var WATER = {
# 	# Precipitation follows a sine curve
# 	"drySeason": .05,
# 	"wetSeason": .08,
# 	# "drySeason": .01,
# 	# "wetSeason": .02,
# 	"seasonLength": 24, # full cycle in simulation steps
# 	"evaporation": .01,
# 	# these numbers work great with no trees:
# 	# var precipitation = .2
# 	# var evaporation = .08
# 	"diffusion": 4,
# 	# var diffusion = .5 # can't be higher than 1
# 	# would be weird to be higher than .8
# 	# var runoff = .2

# 	# var runoff = 1
# 	# var erosion .2
# 	# var suspended .5
# 	"runoff": .1, # Relationship between slope and water given away
# 	"erosion":.05,
# 	"suspended": .2 # Any float, higher numbers mean dirt travels further
# 	# var suspended = 0;
# }

export var growSpeed = 1

# var trees = []
# we do new and then init because
# we're faking the init because we can't pass variables through new in
var model;
# onready var last_state = ARRAY2D.new()
# onready var next_state = ARRAY2D.new()

# onready var tree_canvas = tree_script.instance()

var tree_painter
# onready var tree_painter = TREE_PAINTER.new(SPRUCE.waterToLive, BIRCH.waterToLive)
var paused = false
var tick = 0;

var DEBUG_ELEVATION = 0
var DEBUG_WATER = 0
var DEBUG_NEG_WATER = 0
var DEBUG_MAX_WATER = 0

func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_SPACE and not ev.echo and ev.pressed:
		#code
		# get_tree().paused = true
		paused = !paused
		# $pause_popup.show()

func _ready():
	# last_state.init(ROWS, COLUMNS)
	# next_state.init(ROWS, COLUMNS)
	# var screen_size = OS.get_screen_size(screen=0)
	# var window_size = OS.get_window_size()
	# OS.set_window_position(screen_size*0.5 - window_size*0.5)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	# this doesn't work
	VisualServer.set_default_clear_color(BACKGROUND)

	PERF_TESTER = PERF_SCRIPT.new();

	tree_painter = TREE_PAINTER.new(SPRUCE, BIRCH)

	# var tree_script = load("Tree.gd")
	# var tree_script = load("Tree.tscn")
	# var tree_script = preload("tree.tscn")
	model = MODEL.new()
	print("About to make model")
	model.setup(COLUMNS, ROWS, growSpeed, SPRUCE, BIRCH, WATER, FIRE)
	print("resized")
	for x in range(COLUMNS):
		for y in range(ROWS):
			var cell = model.getCell(x, y)
			cell.species = randi() % 3
			# cell.species = 1
			# cell.water = randf()/2
			cell.water = .5
			cell.elevation = sin(((float(x)/ROWS)+.25)*PI*2*hills) + sin(((float(x+y)/(ROWS+COLUMNS))+.25)*PI*2*hills) + 1 * hill_height
			if cell.species > 0:
				cell.height = randf()
			# model.setCell(x, y, cell)
	# var instance = tree_script.new(i, j)
	# 		var cell = CELLSCRIPT.new()
	# 		cell.species = randi() % 3
	# 		# cell.species = 2
	# 		# cell.setSpecies(1)
	# 		# cell.setWater(.5)
	# 		# print("instance is", instance)
	# 		# instance.species = randi() % 3
	# 		# instance.species = 2
	# 		# instance.species = 0
	# 		cell.elevation = sin(((float(i)/ROWS)+.25)*PI*2*hills) + sin(((float(j+i)/COLUMNS)+.25)*PI*2*hills) + 1 * hill_height#+ randf()/2
	# 		# instance.water = instance.elevation/3
			# cell.water = 100
	# 		# if j == 0:
	# 		# 	print ("float is ", float(i)/ROWS*PI)
	# 		# 	print("elevation is ", instance.elevation)
	# 		# if cell.isATree():
	# 		if cell.species > 0:
	# 			cell.height = randf()
	# 		# instance.species = 2
	# 		# instance.XPOSITION = i
	# 		# instance.YPOSITION = j
	# 		model.setCell(i+COLUMNS/2, j+ROWS/2, cell)
	# 		# row.append(instance)
	# 		# instance.my_init_setter(a,b,c,d)

	# tree_canvas.tree = cell
	add_child(tree_painter)
	# tree_paints.setCell(i+COLUMNS/2, j+ROWS/2, tree_canvas)
	print("aboit to get state")
	# var state = model.getState()
	print("about to viziualize")
	# tree_painter.visualize(state);
	print("visualized")
		# trees.append(row)

func _process(delta):
	if !paused:
		var rain = getRain(tick)
		tick += 1
		# print("growing")
		PERF_TESTER.start()
		var a = model.growAll()
		# print("flowing")
		var b = model.flowAll(rain)
		PERF_TESTER.stop()
		# print("getting state")
		# print("about to viz")
		tree_painter.visualize(model.getState())
		DEBUG_WATER = 0
		DEBUG_NEG_WATER = 0
		DEBUG_MAX_WATER = 0
		DEBUG_ELEVATION = 0

func loraxIpsum(tree, message):
	#He speaks through the trees. Well, one tree in particular.
	# if (tree == [4,4]):
	if (tree == [0,0]):
		print(": ", message)

func getRain(tick):
	# rain follows a curving sine function according to the seasons
	# this was helpful: https://www.desmos.com/calculator
	var rain = (sin(tick * 2 * PI / WATER.seasonLength)+1)*(WATER.drySeason-WATER.wetSeason)/2+WATER.wetSeason
	# they're switched so wet season comes first
	return rain

func loopMe(x, y):
	# return last_state.Get(x%COLUMNS, y%ROWS)
	x += COLUMNS #Ensure no negatives
	y += ROWS
	return[x%COLUMNS, y%ROWS]
	# return trees[x % COLUMNS][y%ROWS]


	# add diagonal neighbors
# func get_looping_neighbors(x, y):
# 	var neighbors = []
# 	neighbors.append(loopMe(x-1, y-1))
# 	# neighbors.append(loopMe(x-1, y))
# 	neighbors.append(loopMe(x-1, y+1))
# 	# neighbors.append(loopMe(x, y-1))
# 	# neighbors.append(loopMe(x, y))
# 	# neighbors.append(loopMe(x, y+1))
# 	neighbors.append(loopMe(x+1, y-1))
# 	# neighbors.append(loopMe(x+1, y))
# 	neighbors.append(loopMe(x+1, y+1))
# 	return neighbors

# # rectangular neighbors
# func get_adjacent_neighbors(x, y):
# 	var neighbors = []
# 	neighbors.append(loopMe(x-1, y))
# 	neighbors.append(loopMe(x, y-1))
# 	neighbors.append(loopMe(x, y+1))
# 	neighbors.append(loopMe(x+1, y))
# 	return neighbors

func handleMouse(mouse_p, speed):
	var reach = speed/400
	var inWorld = tree_painter.screenToWorld(mouse_p.x, mouse_p.y)
	var x = inWorld.x
	var y = inWorld.y
	# for i in range(max(i-reach, 0), min(i+reach, state.height)):
	for i in range(x-reach, x+reach):
		for j in range(y-reach, y+ reach):
			var distance = (inWorld-Vector2(i, j)).length_squared()
			if (distance <= reach*reach):
				var cell = model.getState().getLooping(i, j);
				if cell.isATree():
					cell.on_fire = true;
					# print("cell height is", cell.height)
					# print("i is ", i, " j is,", j)
					# model.setCell(i, j, cell)
					# last_state.setCell(i, j, cell)
