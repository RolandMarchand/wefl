extends Node2D


func _ready():
	yield(WAD, "data_ready")
	var data: Array = WAD.MAPS["MAP01"]["THINGS"]
	var thing_count = (data[1] - data[0]) / 10 # A thing is always 10 bytes

	for i in range(thing_count):
		var pos = data[0] + (i * 10)
		var x = _short(WAD.FILE.subarray(pos, pos + 1))
		var y = _short(WAD.FILE.subarray(pos + 2, pos + 3))
		var angle = _short(WAD.FILE.subarray(pos + 4, pos + 5))
		var type = _short(WAD.FILE.subarray(pos + 6, pos + 7))
		var flags = _short(WAD.FILE.subarray(pos + 8, pos + 9))

		create_thing(x, y, angle)



## Returns a short from a set of two bytes
func _short(bytes: PoolByteArray) -> int:
	var sum: int = (bytes[1] << 8) + bytes[0]

	if 1<<15 & sum: # If the short is negative
		return (sum - 32768) * -1 # Flips last bit on set of two bytes
	else:
		return sum

func create_thing(x, y, angle):
	var ray := RayCast2D.new()
	add_child(ray)
	ray.position = Vector2(x, y)
	ray.rotation_degrees = angle
