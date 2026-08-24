extends Node

# Displaying seconds with leading 0 if less than 10
func _float_into_data_min_sec(time : float) -> String:
	return str(int(time / 60)) + ":" + \
		(str(int(time) % 60) if int(time) % 60 > 9 else "0" + str(int(time) % 60))
