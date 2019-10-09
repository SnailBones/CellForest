extends Node

const Panner = preload("Panner.gd")


const B_DIE = [0, 8]
const S_DIE = [1, 9]
const B_LIGHT = [2, 10]
const S_LIGHT = [3, 11]
const B_GROW = [4, 12]
const S_GROW = [5, 13]
const B_SPROUT = [6, 14]
const S_SPROUT = [7, 15]


# major chord
const major = [0, 4.0/12, 7.0/12]
# minor chord
const cminor = [0, 3.0/12, 7.0/12]
const aminor = [0, 4.0/12, 9.0/12]
# black keys
const black = [0, 2.0/12, 4.0/12, 7.0/12, 9.0/12]

const blues = [0, 3.0/12, 5.0/12, 6.0/12, 7.0/12, 10.0/12]

# onready var birch_die = $"BirchDie"
# onready var spruce_die = $"SpruceDie"
# onready var birch_burn = $"BirchBurn"
# onready var spruce_burn = $"SpruceBurn"
# onready var birch_ambient = $"BirchAmbient"
# onready var spruce_ambient = $"SpruceAmbient"
onready var sound_glass = load("res://Sound/glass.wav")
onready var sound_cello = load("res://Sound/cello.wav")
onready var sound_oboe = load("res://Sound/oboe.wav") # a chord
onready var sound_harmonica = load("res://Sound/harmonica.wav")
onready var sound_gong = load("res://Sound/gong.wav") # weird harmonies, better to modulate volume?
onready var sound_trombone = load("res://Sound/trombone.wav")
onready var sound_clarinet = load("res://Sound/clarinet.wav")
onready var sound_digeridoo = load("res://Sound/digeridoo.wav") # funky sounding bass note

onready var sound_pluck = load("res://Sound/pluck.wav") # too naisy
onready var sound_harp = load("res://Sound/harp.wav")
onready var sound_mandolin = load("res://Sound/mandolin.wav") # too noisy
onready var sound_kalimba = load("res://Sound/kalimba.wav")
onready var sound_drum = load("res://Sound/drum.wav")
onready var sound_marimba = load("res://Sound/marimba.wav")

var sounds

var streams = []
var sharps = []

const volume = 1.0/64
#assume -40 dB is silence
const silence = 40

func addStream(data_address, sound, sensitivity = 1, volume = 1, scale = major):
	var stream = Panner.new(sound, scale, volume);
	add_child(stream)
	streams.append([stream, data_address, sensitivity])

func addSharp(data_address, sound, sensitivity = 1, volume = 1, scale = black):
	sharps.append([sound, data_address, sensitivity, scale, -10000, volume])

func _ready():
	# addStream(S_GROW, sound_cello, 4)
	# addStream(S_LIGHT, sound_cello)
	# addStream(S_SPROUT, sound_cello, 4) # very jittery
	# addStream(S_DIE, sound_cello, 2)

	# addStream(B_GROW, sound_glass, 4)
	# addStream(B_LIGHT, sound_glass)
	# addStream(B_SPROUT, sound_oboe, 4)
	# addStream(B_DIE, sound_oboe, 2)

	addStream(S_GROW, sound_clarinet, 6, -6)
	addStream(S_SPROUT, sound_digeridoo, 4, 1) # very jittery
	addStream(S_DIE, sound_cello, 4, 4, aminor)
	addSharp(S_LIGHT, sound_drum, 2, 40)

	# grow and die echo eachother's melodies, they should be 2 different tones
	# grow and sprout should be the same instrument, a duet in harmony
	# death is played quicker, thus needs a clear note
	# as does sprout
	# grow immediately echos sprout
	# sprout likes a pluck
	addStream(B_GROW, sound_trombone, 6)
	addStream(B_DIE, sound_glass, 2, 1, aminor)
	addStream(B_SPROUT, sound_glass, 2)
	addSharp(B_LIGHT, sound_kalimba, 2, 1)


func _process(delta):
	# model.getState()
	# ASP.stream = footstep
	# sound.play(0) #to play from the beginning of the file.
	pass

func pause(paused):
	for sound in streams:
		sound[0].pause(paused)
		#sound.stream_paused = paused

# Maps numbers evenly to a scale.
func stepScale(inp, scale):
	var fract = fposmod(inp, 1)
	var div = inp-fract
	var index = floor(fract * scale.size())
	var note = scale[index]+div
	var freq = pow(2, note) # 2 to the power of note
	return freq

# Exaggerate stereo
func superStereo(duo):
	var total = duo[0]+duo[1]
	if (total > 0): # testing exaggerated stero
		duo[0] = duo[0]*duo[0]*duo[0]/(total*total*total)
		duo[1] = duo[1]*duo[1]*duo[1]/(total*total*total)
	return duo

func play(st):
	# var birch_die_l = st[0];
	# var spruce_die_l = st[1];
	# var birch_light_l = st[2];
	# var spruce_light_l = st[3];
	# var birch_grow_l = st[4];
	# var spruce_grow_l = st[5];
	# var birch_sprout_l = st[6]
	# var spruce_sprout_l = st[7];

	# var birch_die_r = st[8];
	# var spruce_die_r = st[9];
	# var birch_light_r = st[10];
	# var spruce_light_r = st[11];
	# var birch_grow_r = st[12];
	# var spruce_grow_r = st[13];
	# var birch_sprout_r = st[14]
	# var spruce_sprout_r = st[15];

	# var birch_die = [st[0], st[8]];
	# var spruce_die = [st[1], st[9]];
	# var birch_light = [st[2], st[10]];
	# var spruce_light = [st[3], st[11]];
	# var birch_grow = [st[4], st[12]];
	# var spruce_grow = [st[5], st[13]];
	# var birch_sprout = [st[6], st[14]]
	# var spruce_sprout = [st[7], st[15]];

	for stream in streams:
		var address = stream[1]
		stream[0].playBoth([st[address[0]]*stream[2],st[address[1]]*stream[2]])
		# stream[0].playBoth([0,0])
	for stream in sharps:
		# TODO: DON"T PLAY A NOTE TWICE
		# [sound, data_address, sensitivity, scale]
		var address = stream[1]
		var sound = stream[0]
		var scale = stream[3]
		var volume = stream[5]
		var player = Panner.new(stream[0], stream[3], volume);
		add_child(player)
		player.stream_l.connect("finished", self, "remove", [player])
		player.stream_l.play(0)
		player.stream_r.play(0)
		player.stream_l.volume_db = 10
		# player.pause(false)
		# record last note
		var duo = [st[address[0]]*stream[2],st[address[1]]*stream[2]]
		# print("total is", duo[0] + duo[1], " scale is ", scale)
		var note = stepScale((duo[0]+duo[1])/200-1, scale)
		if stream[4] != note:
			# break
			# print("note is", note)
			duo = superStereo(duo)
			# player.playLeft(note, duo[0])
			player.playLeft(note, duo[0])
			player.playRight(note, duo[1])
			stream[4] = note
			#print("old fashioned note is", stream[4])
			# print("played")
func remove(player):
	player.queue_free()
