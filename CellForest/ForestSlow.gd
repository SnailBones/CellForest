extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var BACKGROUND = Color("180f16")
# const TREESCRIPT = preload("tree.tscn")
# const ARRAY2D = preload("2dArray.gd")
const ARRAY2D = preload("bin/grid.gdns")
const CELLSCRIPT = preload("bin/cell.gdns")
const TREE_PAINTER = preload("TreePainter.gd")


const PERF_SCRIPT = preload("Measure.gd")
var PERF_TESTER;

# var ROWS = 50
# var COLUMNS = 50

export var ROWS = 40
export var COLUMNS = 40

export var hills = 2
export var hill_height = 2



export(Dictionary) var SPRUCE = {
	# "crowdGrowUntil": .4,
	# "crowdDie": .41,
	"waterToSprout": .3,
	"waterToGrow": .25,
	"waterToLive": .1,
	"portionTaken": .4,
	# how much of the water to live and grow is consumed
	"spreadMin": .3,
	# "spreadMax": .3,

	"growRate":  .06,
	"burnRate": .4,
}
export var BIRCH = {
	"waterToSprout": .3,
	"waterToGrow": .5,
	"waterToLive": .2,
	"portionTaken": .1,
	# "crowdGrowUntil": .1,
	# "crowdDie": .15,
	"spreadMin": .06,
	# "spreadMax": .12,
	"growRate":  .12,
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

var FIRE = {
	"spreadMinimum": .2,
	"extinguishChance": .00,
	"dryAmount": .3
}

var WATER = {
	# Precipitation follows a sine curve
	# "drySeason": 0,
	# "wetSeason": .1,
	"drySeason": .005,
	"wetSeason": .015,
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

var growConstant = 1

# var trees = []
# we do new and then init because
# we're faking the init because we can't pass variables through new in
onready var last_state = ARRAY2D.new()
onready var next_state = ARRAY2D.new()

# onready var tree_canvas = tree_script.instance()

# This is a placeholder: we don't really need a whole ARRAY, just one!
onready var tree_painter = TREE_PAINTER.new()
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
	# print("ready!")
	# last_state.init(ROWS, COLUMNS)
	last_state.setup(ROWS, COLUMNS)

	# print("setup!")
	next_state.setup(ROWS, COLUMNS)

	# var cell0 = next_state.getCell(0, 0)
	# print("before anything: cell at 0 0 is ", cell0)
	# print("height is ", cell0.height)


	# next_state.setCell(0, 0, CELLSCRIPT.new())
	# var cell0 = next_state.getCell(0, 0)
	# print("after set: cell at 0 0 is ", cell0)
	# print("height is ", cell0.height)

	# next_state.setCell(0, 1, CELLSCRIPT.new())
	# var cell1 = next_state.getCell(0, 1)
	# print("cell at 0 1 is ", cell1)
	# print("height is ", cell1.height)

	# cell0 = next_state.getCell(0, 0)
	# print("cell at 0 0 is ", cell0)
	# print("height is ", cell0.height)


	# for i in range(2):
	# 	# Sets the same cells as above
	# 	next_state.setCell(0, 0, CELLSCRIPT.new())
	# # # for i in range(1):
	# # 	# Sets the same cells as above
	# # 	next_state.setCell(0, i, CELLSCRIPT.new())

	# cell0 = next_state.getCell(0, 0)
	# print("cell at 0 0 is ", cell0)
	# print("height is ", cell0.height)

	# for i in range(10):
	# 	for j in range(10):
	# 		print("looping cell at ", i,  " ", j, " is ", next_state.getCell(i, j))
	# 		next_state.lorax(i, j)
	# 		print("height is", next_state.getCell(i, j).height)
	# 		print("species is", next_state.getCell(i, j).species)


	# var cell2 = next_state.getCell(0, 0)
	# print("cell at 0 0 is ", cell2)
	# print("height is", cell2.height)

	# return
	# var screen_size = OS.get_screen_size(screen=0)
	# var window_size = OS.get_window_size()
	# OS.set_window_position(screen_size*0.5 - window_size*0.5)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	# this doesn't work
	VisualServer.set_default_clear_color(BACKGROUND)

	PERF_TESTER = PERF_SCRIPT.new();

	# var tree_script = load("Tree.gd")
	# var tree_script = load("Tree.tscn")
	# var tree_script = preload("tree.tscn")
	# for i in range(-COLUMNS/2, COLUMNS/2):
	# 	for j in range(-ROWS/2, ROWS/2):
	# 		var x = i+COLUMNS/2
	# 		var y = j+ROWS/2




	for x in range(COLUMNS):
		for y in range(ROWS):
			# var instance = tree_script.new(i, j)
			# if ([x, y] != [0, 0]):
			# 	print("before new cell 0 0 is", next_state.getCell(0, 0))
			# print("START! LOOP: ", x, " ", y)
			# next_state.lorax(0,0)
				# var cell0 =  next_state.getCell(0, 0)
				# print("cell 0 0 is", cell0)
				# print("cell 0 0 height  is", cell0.height)
			# cell = CELLSCRIPT.new()
			var cell = next_state.getCell(x, y)
			# if ([x, y] != [0, 0]):
			# 	print("after new cell 0 0 is", next_state.getCell(0, 0))
			# print("AFTER INIT:!")
			# next_state.lorax(0,0)
			cell.species = randi() % 3
			# # cell.species = 2
			# # cell.setSpecies(1)
			# # cell.setWater(.5)
			# # print("instance is", instance)
			# # instance.species = randi() % 3
			# # instance.species = 2
			# # instance.species = 0
			cell.elevation = sin(((float(x)/ROWS)+.25)*PI*2*hills) + sin(((float(x+y)/(ROWS+COLUMNS))+.25)*PI*2*hills) + 1 * hill_height#+ randf()/2
			# # instance.water = instance.elevation/3
			cell.water = randf()/2
			# # if j == 0:
			# # 	# print ("float is ", float(i)/ROWS*PI)
			# # 	print("elevation is ", cell.elevation)
			# # if cell.isATree():
			if cell.species > 0:
				cell.height = randf()
			# # instance.species = 2
			# instance.XPOSITION = i
			# instance.YPOSITION = j
			# if ([x, y] != [0, 0]):
				# print("cell 0 0 is", next_state.getCell(0, 0))
			next_state.setCell(x, y, cell)
			# print("AFTER UPDATE NEXT STATE:!")
			# next_state.lorax(0,0)
			# print (" ")
			# var cell2 = next_state.getCell(x, y)
			# print(" locally saved cell ", x, " ", y, "is", cell)
			# print("cell ", x, " ", y, "is", next_state.getCell(x, y))
			# print("cell ", x, " ", y, "height  is", cell2.height)
			# cell0 =  next_state.getCell(0, 0)
			# print("cell 0 0 is", cell0)
			# print("cell 0 0 height  is", cell0.height)
			# print("     end loop    ")
			# print (" ")
			# print("cell is", cell)
			# print(i+COLUMNS/2, " y ", j+ROWS/2)
			# print("height is ", next_state.getCell(i+COLUMNS/2, j+ROWS/2).height)
			# row.append(instance)
			# instance.my_init_setter(a,b,c,d)
	# print ("cell 39 39")
	# print("height  is", next_state.getCell(39, 39).height)
	# tree_canvas.tree = cell

	# print("starting loop!")
	# # var cell: CELLSCRIPT
	# for x in range(COLUMNS):
	# 	# for y in range(trees[0].size()):
	# 	for y in range(ROWS):
	# 		print("getting cell")
	# 		next_state.lorax(x, y)
	# 		var cell = next_state.getCell(x, y)
	# 		print("cell at ", x, " ", y, " is ", cell)
	# 		print("height is", cell.height)
	add_child(tree_painter)
	# tree_paints.setCell(i+COLUMNS/2, j+ROWS/2, tree_canvas)
	# print("painting")
	tree_painter.visualize(next_state);
		# trees.append(row)

func _process(delta):
	if !paused:
		var rain = getRain(tick)
		# var rainPort = rain/WATER.wetSeason
		# VisualServer.set_default_clear_color(Color(.5-rainPort, rainPort/2,rainPort))
		tick += 1
		# last_state = next_state;
		last_state.imitate(next_state);
		# last state should never be changed
		# PERF_TESTER.start()
		# print("starting to grow")
		for i in range(COLUMNS):
						# for y in range(trees[0].size()):
			for j in range(ROWS):
				# print(next_state.getCell(i,j).height)
				# var cell = next_state.getCell(i, j)
				# print("cell at ", i, " ", j, " is ", cell)
				# print("height is", cell.height)
				# var tree = [i, j]
				var tree = last_state.grow(i, j, 10)
				# print("grow -> setCell")
				# tree.height = tree.height + .1;
				next_state.setCell(i,j, tree)
				# var close = get_adjacent_neighbors(i,j) + get_diagonal_neighbors(i, j)
				# updateLife(tree, close)
		# PERF_TESTER.stop()
		# ensure that water is effected by both the tree loop and the water loop
		# last_state = next_state;
		last_state.imitate(next_state)
		PERF_TESTER.start()
		for i in range(COLUMNS):
			for j in range(ROWS):
				# var tree = [i, j]
				# var close = get_adjacent_neighbors(i,j)
				# meanWater(tree, close, rain)
				var tree = last_state.flow(i, j, rain)
				# if (i == 0 and j == 0):
				# 	print(":  tree water is", tree.water)
				# 	print(":  rain is", rain)

				next_state.setCell(i,j, tree)
		PERF_TESTER.stop()
		tree_painter.visualize(next_state)
		DEBUG_WATER = 0
		DEBUG_NEG_WATER = 0
		DEBUG_MAX_WATER = 0
		DEBUG_ELEVATION = 0

func tryToGrowFarm(tree, s = FARM):
	if tree.water > s.waterToLive:
		tree.height -= s.growRate;
		if tree.height <= 0:
			tree.die();
			# if grow == true && (tree.height >= s.maxSize || sum < FARM.treesToGrow):
			# 	grow = false;
	elif tree.height < 1:
		tree.height += s.growRate * growConstant;
	# tree.water -= tree.height * s.waterConsumption + s.waterConsumption/2
	# if tree.water <= 0:
	# 	# tree.die()
	# 	tree.water = 0
	if tree.height <= 0:
		tree.die();


	# elif tree.water >= s.waterToGrow:
	# 	var gAmount = min(tree.water-s.waterToGrow, s.growRate)* growConstant #delta;
	# 	# if tree.water >= gAmount:
	# 	tree.height += gAmount
	# 	tree.water -= gAmount
	# tree.water -= tree.height * s.waterToLive #waterFromLiving
	# # tree.stress = sum/s.crowdDie
	# tree.stress = 1-s.waterToLive-tree.water
func tryToGrow(tree, s):
	if tree.on_fire:
		tree.height -= s.burnRate
		# if randf() < FIRE.extinguishChance:
			# tree.on_fire = false;
		if tree.height <= 0:
			# no idea why i need this but i do or else it bugs with negative heigts
			# tree.height = 0
			tree.die();
			return
	else:
		if !tree.isATree():
			# tryToGrowFarm(tree)
			print("BARF! I'm a farm! Go Reneable FARMS!")
		else:
			# if tree.water < s.waterToLive:
			if tree.water < s.waterToLive:
				# should big trees be easier to kill?
				# maybe big trees should need more water to grow
				tree.die();
				return
			tree.water -= tree.height * s.waterToLive * s.portionTaken
			# big trees do consume more water
			# a bug could be introduced here if trees have a height greater than one
			if tree.water >= s.waterToGrow:
				# grow with water OVER limit
				var gAmount = min(tree.water-s.waterToGrow, s.growRate)* growConstant # delta
				# var gAmount = min(s.waterToGrow, s.growRate)* growConstant
				#delta;
				# if tree.water >= gAmount:
				tree.height += gAmount
				# if (tree.height < 0 or gAmount < 0):
				# 	print("Negative height is", tree.height)
				# 	print("growing by ", gAmount)
				# 	print("water is", tree.water)
				tree.water -= gAmount * s.portionTaken
			# tree.stress = sum/s.crowdDie
			tree.stress = 1-s.waterToLive-tree.water
func updateLife(treeId, nIds):

	var spruce = 0;
	var birch = 0;
	var fire = 0;
	var farm = 0;
	var farmcount = 0;
	# var water = 0;
	# print("id is", treeId)
	# print("About to get GDSCript")
	# var treeLast = last_state.G(treeId)
	# print("tree is", treeId)
	# print("i is", treeId[0], "j is", treeId[1])
	var treeLast = last_state.getCell(treeId[0], treeId[1])
	# print("tree is", treeId)
	# print("i is", treeId[0], "j is", treeId[1])
	# print("last tree is", treeLast)
	# print("last tree elevation is", treeLast.elevation)
	# print("last tree height is", treeLast.height)
	var treeNext = next_state.G(treeId)
	for id in nIds:
		# print("neighbor is", id)
		var neighbor = last_state.G(id)
		if neighbor.on_fire:
			fire += neighbor.height
		elif neighbor.species == 1:
			spruce += neighbor.height
		elif neighbor.species == 2:
			birch += neighbor.height
		elif neighbor.species == 3:
			farm += neighbor.height
			farmcount += 1;

	# scarcity of localresources
	# var sum = (spruce + birch + tree.height)/(neighbors.size()+1)
	# var sum = (spruce + birch)/(neighbors.size())
	spruce = spruce/4
	birch = birch/4
	fire = fire/4
	farm = farm/4

	# var s = null
	var grow = false;

	var s = null;

	# farm can overtake trees
	var meanHeight = (spruce + birch+ treeLast.height)/(5)
	if farm > FARM.spreadMin && treeLast.water + treeLast.height*10 >= FARM.waterToGrow && meanHeight >= FARM.treesToGrow:
		if treeLast.isATree():
			treeNext.water += treeLast.height;
			treeNext.height = 0;
			grow = true;
		treeNext.species = 3
		grow = true;

	if treeLast.isEmpty() && fire < FIRE.spreadMinimum && treeLast.water:
		if birch > BIRCH.spreadMin && treeLast.water >= BIRCH.waterToSprout:
			treeNext.species = 2
			grow = true
		elif spruce > SPRUCE.spreadMin && treeLast.water >= SPRUCE.waterToSprout:
			treeNext.species = 1
			grow = true
	if treeLast.species == 1:
		s = SPRUCE;
	elif treeLast.species == 2:
		s = BIRCH;
	elif treeLast.species == 3:
		# farm is benifited by trees
		s = FARM;
		# tryToGrowFarm(tree, FARM)
		# if treeNeighbors < s.treesToLive:
		# 	tree.height -= s.growRate * delta;
		# 	if tree.height <= 0:
		# 		tree.die();
		# elif tree.height < 1:
		# 	tree.height += s.growRate * delta;
	if s:
		if treeLast.isATree():
			if fire > FIRE.spreadMinimum*treeLast.height:
				treeNext.water -= FIRE.dryAmount
				if treeNext.water <= s.waterToLive:
					treeNext.on_fire = true
		# tryToGrow(treeNext, s)
		# print("growing!")
		treeNext.grow(s ,growConstant)

	# var waterFromLiving = .1 # water consumed by tree that is not growing

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

func niceWater(here, neighbors, rain):
	# This is a refactoring of meanWater, the functionality is the same
	# It's easier to understand, but it performs worse.
	# It also shares a weird bug. With runoff, the water doesn't remain totally constant
	var hereLast = last_state.G(here)

	DEBUG_WATER += hereLast.water
	if hereLast.water > DEBUG_MAX_WATER:
		DEBUG_MAX_WATER = hereLast.water
	# Catches rounding errors that would otherwise escalate horribly
	var next = next_state.G(here)
	# if (hereLast.water < 0):
	# 	hereLast.water = 0
	var totalWater = hereLast.water;
	var totalElevation = 0
	var waterWeight = 1000 # Constant for how much slope effects diffusion
	for n in neighbors:
		var neighbor = last_state.G(n)
		# totalWater += neighbor.water
		# 4 times, we approach the average of the neighbor.
		# including weighting myself, we divide by 5 for average.
		var flatChange = (neighbor.water -hereLast.water)/5

		var elevationDif = clamp((neighbor.elevation-hereLast.elevation)*waterWeight, -1, 1)
		# var elevationDif = waterWeight*(neighbor.elevation-hereLast.elevation)
		# if neighbor is higher, gain a percentage of NEIGHBOR's water
		# Effectively, flow happens before diffusion.
		var slopeChange = 0
		if elevationDif > 0.01:
			slopeChange = elevationDif * neighbor.water/4.0
			slopeChange = neighbor.water/4
		# if neighbor is lower, lose a percentage of MY water
		elif elevationDif < -0.01:
			# slopeChange = elevationDif * hereLast.water/4.0
			slopeChange = -hereLast.water/4

		# var slopeChange = flatChange * (1 + elevationDif)
		# next.water += flatChange*.8+ elevationDif*.2
		next.water += slopeChange
		# next.water += flatChange
		DEBUG_ELEVATION += neighbor.water
	if next.water < 0:
		DEBUG_NEG_WATER += next.water
		next.water = 0;
		#Each one alone is taking ALL the water, so adding them together we half each
	# var meanWater = totalWater/5


func meanWater(here, neighbors, rain):
	# this is a simple, experimental,
	# faith-based cell algorithm
	# the premise is: if every cell become the average of its neighbors
	# the overall amount of water will remain constant
	# also, if we add to cells with higher neighbors,
	# and subtract from cells with lower neighbors the same amount
	# or if we interpolate toward the average
	# it should still be constant.

	# it almost works. numbers change weirdly.
	# lets try not to worry about that for now.

	# TODO: Add erosion.

	var hereLast = last_state.G(here)
	# if (hereLast.water < 0):
	# 	hereLast.water = 0
	var totalWater = hereLast.water;
	var totalFlow = 0
	# var waterWeight = 1 # Constant for how much slope effects diffusion
	for n in neighbors:
		# var neighbor = last_state.G(n)
		var neighbor = last_state.getCell(n[0], n[1])
		# print("n is ", n, " neighbor is", neighbor)
		totalWater += neighbor.water
		var slope = clamp((neighbor.elevation-hereLast.elevation)*WATER.runoff, -1, 1)
		if slope > 0:
			totalFlow += neighbor.water * slope
		elif slope < 0:
			totalFlow += hereLast.water * slope
		# totalElevation +=(neighbor.elevation-hereLast.elevation) * waterWeight
		# clamp ensure that we'll never give away too much water and go negative
		# doing in for each neighbor ensure that it's symmetric,
		# so we have conservation of water mass.
	var meanWater = totalWater/5
	# Could interpolate this down to reduce diffusion... but why would we?
	var meanFlow = totalFlow/4
	# var flatWater = meanWater + rain
	var flatWater = meanWater
	# Amount of water if we're not
	# masochistically trying to account for elevation.
	# portion of water to add/subtract depending on slope.
	# Elevation is working correctly, I checked.
	# DEBUG_ELEVATION += meanElevation + 1
	# This number is the average height of a neighbor, dampening outliers.
	# It should never be below 0 or above 1.
	# needs a cap, otherwise it goes inifitite or negative
	# at most you can lose all water or double water.
	# however, the cap means that water is not always conserved, oops.
	# i.e. one really steep tower will add more water to its neighbors than it has any right to.
	# var newWater = flatWater + meanElevation # effectively adding flatwater to a weighted slopewater.
	# lower elevations get more water
	# TODO better method, get is hacky
	# loraxIpsum(tree, "flatWater:", flatWater)
	# loraxIpsum(here, "Water "+ str(newWater) + " Flat Water " + str(flatWater))
	# loraxIpsum(here, "Elevation "+ str(meanElevation))
	# var hereNext = next_state.G(here)
	var hereNext = hereLast;
	hereNext.water = meanWater + meanFlow + rain
	DEBUG_WATER += hereNext.water
	if hereNext.water > DEBUG_MAX_WATER:
		DEBUG_MAX_WATER = hereLast.water
	# hereNext.water = flatWater
	var boo = next_state.G(here)
	next_state.S(here, hereNext)

func updateWater(here, neighbors, rain):

		# Each step only half of the water gets updated
		# We work in a checkerboard pattern, so no too adjacent waters
		# get updated at the same time.

		# This means that order doesn't matter, and performance is improved.

		# Flow => Drop sediment => Absorbed by trees => Rain
		var hereLast = last_state.G(here)
		# TODO: this feels wrong,
		# it should be completely dependent on the last state
		# not on anything else done this state
		# i. e. each cell should only edit itself
		# then we can only get from last and set on here
		var hereNext = next_state.G(here)
		hereNext.water + rain
		if hereNext.water >= 1:
			hereNext.water = 1
		if hereNext.water <= 0:
			hereNext.water = 0


		if hereNext.water > 0:
		# We start with flow, then convection.

		# Flow: go downhill unless water height too high--there's a pond!

		# Convection: go to dryer neighbors. let's not have too much of this
		# so we can have a more varied environment.

			# var lowest = here
			var totalWeights = 0
			var downNeighbors = []
			# var diffusionWeights = 0
			# var diffuseNeighbors = []
			for n in neighbors:
				var neighbor = next_state.G(n)
				var drop = max(here.elevation-neighbor.elevation, 0)
				var waterDif = max(here.water-neighbor.water, 0)
				var weight = drop * 3 + waterDif * 5

				# TODO:
				# for elevation to actually do interesting things with trees
				# there needs to be runoff: they can't absorb it all at once
				# there needs to be:
				# either very unequal distribution of precipitation (in time, maybe also space)
				# or hidden supply of underground water innaccessible to trees
				# i.e. underground runoff
				# if (neighbor.elevation < here.elevation):
					# TODO: account for water height in ponds
					# var difference = here.elevation-neighbor.elevation
					# We exaggerate difference: so water has a strong preference
					# to pick the very best route
					# Hopefully this will produce more interesting terrain.
					# i.e. less smooth
					# var weight = difference * difference
				# var weight = difference
				# var weight = difference
				if (weight > 0):
					totalWeights += weight
					#second value is exaggerated weight
					downNeighbors.append([neighbor, weight])

				# if neighbor.water < here.water:
				# 	var difference = here.water-neighbor.water
				# 	var weight = difference/10
				# 	nona/Veictn- += weight
				# 	downNeighbors.append([neighbor, weight])


			# for n in diffuseNeighbors:

			#Give up runoff % of all water, spread according to elevationdrop
			# Also be scaled by total elevation difference
			# and you should never give up ALL your water
			# - have a cap at 50% total water loss?

			var maxLeave = .9 #Only 90% of water can ever leave

			var giveAway = min((totalWeights * WATER.runoff/3), maxLeave)*here.water

			#TODO a square curve for water might give cooler terrain
			var sedAway = giveAway * WATER.erosion
			here.elevation -= sedAway
			# loraxIpsum(here, "Water "+ str(here.water) )
			# loraxIpsum(here, "Giving away "+ str(giveAway) + " water")
			#  and " + str(sedAway) + " sediment")
			# loraxIpsum(here, "elevation "+ str(here.elevation) )

			for n in downNeighbors:
				var neighbor = n[0]
				var weight = n[1]

				var myPercent = weight/totalWeights
				var movedWater = myPercent * giveAway
				neighbor.water += movedWater


				# var waterForce = movedWater * movedWater
				# var erode = waterForce * erosion
				# var erode = movedWater * erosion
				# neighbor.sediment += erode
				# here.elevation-= erode
				neighbor.sediment+= myPercent * sedAway

				# Sediment transfers evenly

				var waterPercent = movedWater/here.water
				var sedimentMove = here.sediment*waterPercent

				here.sediment -= sedimentMove
				neighbor.sediment += sedimentMove

					#evaporate

			here.water -= giveAway

			# diffusion: give a bit of water to all my neighbors
			# this doesn't make trees competive, hmmm
			# var diffuse = here.water * diffusion
			# for neighbor in neighbors:
			# 	neighbor.water += diffuse/4
				# var diffused = 0
				# if neighbor.water < here.water:
				# 	diffused = (here.water-neighbor.water)*diffusion
				# var run = 0;
				# this conditional stuff is bad because it means
				# behaviour becoumes order-dependent

			if here.water >= 1:
				here.water -= WATER.evaporation

			# Maximimum amount of sediment held is speed times amount of water times constant
			# (I think I had to look this up)

			# Perhaps we can consider speed equal to the proportion of water leaving?
			# The more you give away, the more you hold!
			# TODO: move this before? that would make more depositing
			# as is we can effectively skirt the max by passing off the sediment
			# before we measure it
			var waterHold = giveAway * WATER.suspended

			# here.elevation += here.sediment
			# here.sediment = 0
			if here.sediment > waterHold:
				var deposit = here.sediment - waterHold
				here.sediment -= deposit
				here.elevation += deposit

func loopMe(x, y):
	# return last_state.Get(x%COLUMNS, y%ROWS)
	x += COLUMNS #Ensure no negatives
	y += ROWS
	return[x%COLUMNS, y%ROWS]
	# return trees[x % COLUMNS][y%ROWS]


	# add diagonal neighbors
func get_diagonal_neighbors(x, y):
	var neighbors = []
	neighbors.append(loopMe(x-1, y-1))
	# neighbors.append(loopMe(x-1, y))
	neighbors.append(loopMe(x-1, y+1))
	# neighbors.append(loopMe(x, y-1))
	# neighbors.append(loopMe(x, y))
	# neighbors.append(loopMe(x, y+1))
	neighbors.append(loopMe(x+1, y-1))
	# neighbors.append(loopMe(x+1, y))
	neighbors.append(loopMe(x+1, y+1))
	return neighbors

# rectangular neighbors
func get_adjacent_neighbors(x, y):
	var neighbors = []
	neighbors.append(loopMe(x-1, y))
	neighbors.append(loopMe(x, y-1))
	neighbors.append(loopMe(x, y+1))
	neighbors.append(loopMe(x+1, y))
	return neighbors

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
				# var cell = next_state.getLooping(i, j);
				# var cell = next_state.getCell(i, j);
				var cell = next_state.G(loopMe(i, j))
				if cell.isATree():
					cell.on_fire = true;
					# print("cell height is", cell.height)
					# print("i is ", i, " j is,", j)
					# next_state.setCell(i, j, cell)
					# last_state.setCell(i, j, cell)
