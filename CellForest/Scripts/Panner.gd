extends Node

# Dynamically creates two audiostreams to simulate panning.

var sound

const volume = 1.0/64
#assume -40 dB is silence
const silence = 40

var stream_l
var stream_r
var my_volume



var scale
#C, G.
# var scale = [0, 13/24, 21/43]
# major chord
# var scale = [0, 4.0/12, 7.0/12]
# minor chord
# var scale = [0, 3.0/12, 7.0/12]
# black keys on piano
# scale = [0, 2.0/12, 4.0/12, 7.0/12, 9.0/12]
# blues scale
# scale = [0, 3.0/12, 5.0/12, 6.0/12, 7.0/12, 10.0/12]

func _init(sound, sc, vol = 1):
	scale = sc
	my_volume = vol
	stream_l = AudioStreamPlayer.new()
	stream_r = AudioStreamPlayer.new()
	stream_l.bus = "Left"
	stream_r.bus = "Right"
	stream_l.stream = sound
	stream_r.stream = sound
	stream_l.stream_paused=true;
	stream_r.stream_paused=true;
	stream_l.volume_db = -100
	stream_r.volume_db = -100
	add_child(stream_l)
	add_child(stream_r)

func _ready():
	stream_l.play(0)
	stream_r.play(.5)

func pause(paused):
	stream_l.stream_paused = paused
	stream_r.stream_paused = paused


# Maps numbers evenly to a scale.
func stepScale(inp, scale):
	var fract = fposmod(inp, 1)
	var div = inp-fract
	var index = floor(fract * scale.size())
	var note = scale[index]+div
	var freq = pow(2, note) # 2 to the power of note
	return freq

# We assume variable is greater than 0

func playStream(player, pitch, vol):
	# print("playing!")
	# print("volume is ", volume)
	# print("player is ", player)
	# if vol > 0:
	player.stream_paused=false;
	player.pitch_scale=pitch
	player.volume_db = vol-40+2/pitch # play lower notes louder
	# player.volume_db = 10;
	# provides balance to the ears
	# else:
		# player.stream_paused=true;

func playBoth(duo, sc = scale):
	#print("playing")
	var total = duo[0]+duo[1]
	if (total > 0): # testing exaggerated stero
		duo[0] = duo[0]*duo[0]*duo[0]/(total*total*total)
		duo[1] = duo[1]*duo[1]*duo[1]/(total*total*total)
	# print("total is", total, "duo is", duo)
	# print("note is", note)
	if total > 20: # arbitrary threshold minimizes droning
		var note = stepScale(total/200 - 1, sc);
		playStream(stream_l, note, (duo[0]*my_volume*20))
		playStream(stream_r, note, (duo[1]*my_volume*20))
	else:
		stream_l.stream_paused=true;
		stream_r.stream_paused=true;
	# return note

func playLeft(note, vol):
	playStream(stream_l, note, vol*my_volume)

func playRight(note, vol):
	playStream(stream_r, note, vol*my_volume)
