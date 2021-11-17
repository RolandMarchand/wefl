extends Node2D

enum {FROM, TO}

func _ready():
	yield(WAD, "data_ready")
	print(_get_things("MAP01"))

## Takes a map as a string, either in MAPxy or ExMy format.
## Returns an array of all THINGS of the map.
## Each thing is represented by a dictionary of its proprieties, x position,
## y position, the angle, the type and the flags.
func _get_things(map: String) -> Array:
	var things_data: Array = WAD.MAPS["MAP01"]["THINGS"]
	var things_count = (things_data[TO] - things_data[FROM]) / 10 # A thing is always 10 bytes
	var things_array: Array = []

	if map.begins_with("M"):
		for i in range(things_count):
			var pos = things_data[0] + (i * 10) # A thing is always 10 bytes long

			var things_buffer: Dictionary = {
				# Each thing is a <short>, 2 bytes long
				"x": _short(WAD.FILE.subarray(pos, pos + 1)),
				"y": _short(WAD.FILE.subarray(pos + 2, pos + 3)),
				"angle": _short(WAD.FILE.subarray(pos + 4, pos + 5)),
				"type": _short(WAD.FILE.subarray(pos + 6, pos + 7)),
				"flags": _short(WAD.FILE.subarray(pos + 8, pos + 9))
			}

			things_array.append(things_buffer)
	else: # ExMy label, to be implemented
		pass

	return things_array


## Returns a short from a set of two bytes
func _short(bytes: PoolByteArray) -> int:
	var sum: int = (bytes[1] << 8) + bytes[0]

	if 1<<15 & sum: # If the short is negative
		return (sum - 32768) * -1 # Flips last bit on set of two bytes
	else:
		return sum
