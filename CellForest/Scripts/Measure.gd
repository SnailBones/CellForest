# extends Performance
extends Control

# class member variables go here, for example:
var start_time = 0
var total_run_time = 0
var time_since_update = 0
var count = 0
const UPDATE_WAIT = 1000
var highest = 0
var lowest = INF
var last_update_time =  OS.get_ticks_msec()
var nickname

func _init(n= "T"):
	nickname = n

func start():
	start_time = OS.get_ticks_msec()

func stop():
	count += 1
	var stop = OS.get_ticks_msec ( )
	var time = stop - start_time
	total_run_time += time
	time_since_update = stop-last_update_time
	if (time > highest):
		highest = time
	elif (time < lowest):
		lowest = time
	if (time_since_update >= UPDATE_WAIT):
		update()

func update():
	last_update_time = OS.get_ticks_msec()
	var avg = total_run_time/count
	print(nickname, ": Highest is", highest, " Lowest is", lowest, " Mean is ", avg, "ms")
	print (nickname, ":FPS is", count*1000/time_since_update, " (", count, " updates in ", time_since_update/1000.0," s) ")
	print (nickname, ": Proportion of time is ", total_run_time*100/time_since_update, "%")
	time_since_update = 0
	highest = 0
	lowest = INF
	count = 0
	total_run_time = 0