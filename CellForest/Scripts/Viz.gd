# top-down data visualization

extends TextureRect

const ARRAY2D = preload("res://bin/grid.gdns")
# const ARRAY2D = preload("2dArray.gd")
const CELLSCRIPT = preload("res://bin/cell.gdns")

export(PackedScene) var Text

# const PERF_SCRIPT = preload("Measure.gd")
# onready var PERF_TESTER = PERF_SCRIPT.new("Vizzing")


# export(String, "All", "Elevation", "Water", "Sediment", "Test") var color_scheme = "All";

var color_scheme = 0

var forest

var state

var img
var img_texture
# func _init(s, b):
# 	spruce = s
# 	birch = b
func _ready():
	visible = false
	forest = get_tree().get_nodes_in_group("forest")[0]
	img = Image.new()
	img.create(forest.COLUMNS, forest.ROWS, false, Image.FORMAT_RGBA8)
	img.fill(Color(1,0,0,1))

	img_texture = ImageTexture.new()
	img_texture.create(forest.COLUMNS, forest.ROWS,  Image.FORMAT_RGBA8, 0)
	img_texture.set_data(img)
	set_texture(img_texture)



func _process(delta):
	if visible:
		visualize(forest.model.getState())
	# img.fill(Color(0,0,0,1))
	# img.lock()
	# for x in range(forest.COLUMNS):
	# 	for y in range(forest.ROWS):
	# 		img.set_pixel(x, y, Color(1,1,0, 1))
	# img.unlock()

# func _input(ev):
# 	if ev is InputEventKey:
# 		if ev.scancode == KEY_SPACE and not ev.echo and ev.pressed:
# 			change_mode()

func change_mode():
	color_scheme = color_scheme + 1
	if color_scheme == 5:
		color_scheme = 0
		visible = false
	elif color_scheme == 1:
		visible = true

func setView(cs):
	color_scheme = cs
	if color_scheme == 0:
		visible = false
	else:
		visible = true



func visualize(trees):
	# PERF_TESTER.start()
	state = trees;
	# update();
	if state == null:
		print("null state")
		return;
	img.lock()
	var cell;
	for x in range(state.width):
		for y in range(state.height):
			cell = state.getCell(x, y)
			var color = getColor(cell)
			img.set_pixel(x, y, color)
	img.unlock()
	img_texture.set_data(img)
	# PERF_TESTER.stop()

func getColor(cell):
	var color
	match color_scheme:
		# "All":
		1:
			# color = Color((cell.elevation-1)/4, 1-cell.sediment*12, cell.water)
			# color = Color(cell.sediment*6, 1-cell.elevation/2, cell.water)
			color = Color(cell.sediment*6, cell.elevation-1, cell.water)
		# "Water":
		3:
			# color = Color(.3, .3, cell.water)
			color = Color(cell.water-1, .3, cell.water)
		# "Elevation":
		2:
			# color = Color((cell.elevation-2)/8, 2-cell.elevation/2, 3-cell.elevation/2
			var change = 16
			# var value = fmod(cell.elevation+change/2, change)/change
			var value = cell.elevation/change+.5
			color = Color(value, value, value)
		# "Sediment":
		4:
			color = Color(cell.sediment*2, cell.sediment/2, 0)
		"Test":
			# color = Color(cell.test_var/10, cell.test_var/20, 0)
			color = Color(cell.test_var*10, -cell.test_var*10, 0)
	return color;
