extends Control


var BACKGROUND = Color("180f16")
const ARRAY2D = preload("bin/grid.gdns")
const CELLSCRIPT = preload("bin/cell.gdns")
const MODEL = preload("bin/model.gdns")
const TREE_PAINTER = preload("TreePainter.gd")


const PERF_SCRIPT = preload("Measure.gd")
var PERF_TESTER;

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
	"portionTaken": .25,
	# "portionTaken": .33,
	# how much of the water to live and grow is consumed
	"spreadMin": .5,
	# "spreadMax": .3,

	"growRate":  .06,
	"burnRate": .4,
}
export var BIRCH = {
	"waterToSprout": .4,
	"waterToGrow": .2,
	"waterToLive": .25,
	# "portionTaken": .33,
	"portionTaken": .2,
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
	"wetSeason": .022,
	# "drySeason": .07,
	# "wetSeason": .09,
	"seasonLength": 24, # full cycle in simulation steps
	"evaporation": .02,
	# "evaporation": 0,
	"diffusion": .0, # Percentage toward equlibrium with neighbors reached. Must be less than 1.
	# Higher diffusion means less runoff.
	"runoff": 1, # Water's sensitivity to slopes
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


export var growSpeed = 2


var model;


var tree_painter

var paused = false
var tick = 0;

var mouse_p
var old_mouse_p
const mouse_effect = .1

var DEBUG_ELEVATION = 0
var DEBUG_WATER = 0
var DEBUG_NEG_WATER = 0
var DEBUG_MAX_WATER = 0

func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_SPACE and not ev.echo and ev.pressed:
		paused = !paused

func _ready():
	# var screen_size = OS.get_screen_size(screen=0)
	# var window_size = OS.get_window_size()
	# OS.set_window_position(screen_size*0.5 - window_size*0.5)
	VisualServer.set_default_clear_color(BACKGROUND)

	PERF_TESTER = PERF_SCRIPT.new();

	tree_painter = TREE_PAINTER.new(SPRUCE, BIRCH)
	mouse_p = get_viewport().get_mouse_position()

	model = MODEL.new()
	print("About to make model")
	model.setup(COLUMNS, ROWS, growSpeed, SPRUCE, BIRCH, WATER, FIRE)
	print("resized")
	for x in range(COLUMNS):
		for y in range(ROWS):
			var cell = model.getCell(x, y)
			# cell.species = randi() % 3
			cell.species = 0
			cell.water = randf()/2
			cell.elevation = sin(((float(x)/ROWS)+.25)*PI*2*hills) + sin(((float(x+y)/(ROWS+COLUMNS))+.25)*PI*2*hills) + 1 * hill_height
			if cell.species > 0:
				cell.height = randf()
	# 		cell.elevation = sin(((float(i)/ROWS)+.25)*PI*2*hills) + sin(((float(j+i)/COLUMNS)+.25)*PI*2*hills) + 1 * hill_height#+ randf()/2

	add_child(tree_painter)

func _process(delta):
	if !paused:
		var rain = getRain(tick)
		tick += 1
		PERF_TESTER.start()
		var a = model.growAll()
		var b = model.flowAll(rain)
		PERF_TESTER.stop()
		handleMouse(delta)
		tree_painter.visualize(model.getState())
		DEBUG_WATER = 0
		DEBUG_NEG_WATER = 0
		DEBUG_MAX_WATER = 0
		DEBUG_ELEVATION = 0

func loraxIpsum(tree, message):
	# He speaks through the trees. That is, one tree in particular.
	if (tree == [0,0]):
		print(": ", message)

func getRain(tick):
	# rain follows a curving sine function according to the seasons
	# this was helpful: https://www.desmos.com/calculator
	var rain = (sin(tick * 2 * PI / WATER.seasonLength)+1)*(WATER.drySeason-WATER.wetSeason)/2+WATER.wetSeason
	# they're switched so wet season comes first
	return rain


# Mouse is handled in cell space for speed
func handleMouse(delta):
	old_mouse_p = mouse_p
	mouse_p = get_viewport().get_mouse_position()
	var speed = 0
	if (old_mouse_p != mouse_p):
		var change = (mouse_p-old_mouse_p).length()
		speed = change/delta
	if (speed > 100 or Input.is_mouse_button_pressed(2) or Input.is_mouse_button_pressed(1)):
			doMouse(speed)


func doMouse(speed):
	var inWorld = tree_painter.screenToWorld(mouse_p.x, mouse_p.y)
	var x = inWorld.x
	var y = inWorld.y
	if speed > 100:
		var reach = speed/400
		# for i in range(max(i-reach, 0), min(i+reach, state.height)):
		for i in range(x-reach, x+reach):
			for j in range(y-reach, y+ reach):
				var distance = (inWorld-Vector2(i, j)).length_squared()
				if (distance <= reach*reach):
					var cell = model.getState().getLooping(i, j);
					if cell.isATree():
						cell.on_fire = true;
	if Input.is_mouse_button_pressed(2):  # Right mouse button.
		var reach = 10;
		for i in range(x-reach, x+reach):
			for j in range(y-reach, y+ reach):
				var distance = (inWorld-Vector2(i, j)).length_squared()
				if (distance <= reach*reach):
					var cell = model.getState().getLooping(i, j);
					cell.elevation = cell.elevation + (mouse_effect * (1-distance/(reach*reach)))
	if Input.is_mouse_button_pressed(1):  # Left mouse button.
		var reach = 10;
		for i in range(x-reach, x+reach):
			for j in range(y-reach, y+ reach):
				var distance = (inWorld-Vector2(i, j)).length_squared()
				if (distance <= reach*reach):
					var cell = model.getState().getLooping(i, j);
					cell.elevation = cell.elevation - (mouse_effect * (1-distance/(reach*reach)))
