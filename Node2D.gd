extends Node2D

enum {FROM, TO}

func _ready():
	yield(WAD, "data_ready")
	print(_get_sectors("MAP01"))

## Takes a map as a string, either in MAPxy or ExMy format.
## Returns an array of all THINGS of the map.
## Each thing is represented by a dictionary of its proprieties, x position,
## y position, the angle, the type and the flags.
##
## TODO, check input validity
func _get_things(map: String) -> Array:
	# A thing is always 10 bytes long
	var LENGTH := 10
	# Array of int, indicating the location of the data in the WAD
	var things_data_ptr: Array = WAD.MAPS[map]["THINGS"]
	# A thing is always 10 bytes
	var things_count = (things_data_ptr[TO] - things_data_ptr[FROM]) / LENGTH
	# To be returned
	var things_array: Array = []

	if map.begins_with("M"): # MAPxy label
		for i in range(things_count):
			# A thing is always 10 bytes long
			var current_thing = things_data_ptr[0] + (i * LENGTH)

			var things_buffer: Dictionary = {
				# Each field is a <short>, 2 bytes long
				"x": _short(
					WAD.FILE.subarray(
						current_thing, current_thing + 1)),
				"y": _short(
					WAD.FILE.subarray(
						current_thing + 2, current_thing + 3)),
				"angle": _short(
					WAD.FILE.subarray(
						current_thing + 4, current_thing + 5)),
				"type": _short(
					WAD.FILE.subarray(
						current_thing + 6, current_thing + 7)),
				"flags": _short(
					WAD.FILE.subarray(
						current_thing + 8, current_thing + 9))
			}

			things_array.append(things_buffer)
	else: # ExMy label, to be implemented
		pass

	return things_array

## TODO, check input validity
func _get_lindefs(map: String) -> Array:
	# A linedef is always 14 bytes long
	var LENGTH := 14
	# Array of int, indicating the location of the data in the WAD
	var linedefs_data_ptr: Array = WAD.MAPS[map]["LINEDEFS"]
	var linedefs_count = (linedefs_data_ptr[TO] - linedefs_data_ptr[FROM]) / LENGTH
	# To be returned
	var linedefs_array: Array = []

	if map.begins_with("M"): # MAPxy label
		for i in range(linedefs_count):
			var current_linedef = linedefs_data_ptr[0] + (i * LENGTH)

			var linedef_buffer: Dictionary = {
				# Each field is a <short>, 2 bytes long
				"vertex_1": _short(
					WAD.FILE.subarray(
						current_linedef, current_linedef + 1)),
				"vertex_2": _short(
					WAD.FILE.subarray(
						current_linedef + 2, current_linedef + 3)),
				"flags": _short(
					WAD.FILE.subarray(
						current_linedef + 4, current_linedef + 5)),
				"special_type": _short(
					WAD.FILE.subarray(
						current_linedef + 6, current_linedef + 7)),
				"sector_tag": _short(
					WAD.FILE.subarray(
						current_linedef + 8, current_linedef + 9)),
				"front_sidedef": _short(
					WAD.FILE.subarray(
						current_linedef + 10, current_linedef + 11)),
				"back_sidedef": _short(
					WAD.FILE.subarray(
						current_linedef + 12, current_linedef + 13)),
			}

			linedefs_array.append(linedef_buffer)
	else: # ExMy label, to be implemented
		pass

	return linedefs_array

## TODO, check input validity
func _get_sidedefs(map: String) -> Array:
	# A sidedef is always 30 bytes long
	var LENGTH := 30
	# Array of int, indicating the location of the data in the WAD
	var sidedefs_data_ptr: Array = WAD.MAPS[map]["SIDEDEFS"]
	var sidedefs_count = (sidedefs_data_ptr[TO] - sidedefs_data_ptr[FROM]) / LENGTH
	# To be returned
	var sidedefs_array: Array = []

	if map.begins_with("M"): # MAPxy label
		for i in range(sidedefs_count):
			var current_sidedef = sidedefs_data_ptr[0] + (i * LENGTH)

			var sidedefs_buffer: Dictionary = {
				# Each sidedef's record is 30 bytes,
				# comprising 2 <short> fields,
				# then 3 <8-byte string> fields,
				# then a final <short> field
				"x_offset": _short(
					WAD.FILE.subarray(
						current_sidedef, current_sidedef + 1)),
				"y_offset": _short(
					WAD.FILE.subarray(
						current_sidedef + 2, current_sidedef + 3)),
				"upper_texture": WAD.FILE.subarray(
						current_sidedef + 4, current_sidedef + 11
						).get_string_from_ascii(),
				"lower_texture": WAD.FILE.subarray(
						current_sidedef + 12, current_sidedef + 19
						).get_string_from_ascii(),
				"middle_texture": WAD.FILE.subarray(
						current_sidedef + 20, current_sidedef + 27
						).get_string_from_ascii(),
				"front_sidedef": _short(
					WAD.FILE.subarray(
						current_sidedef + 28, current_sidedef + 29)),
			}

			sidedefs_array.append(sidedefs_buffer)
	else: # ExMy label, to be implemented
		pass

	return sidedefs_array

## TODO, check input validity
func _get_vertexes(map: String) -> Array:
	# A vertex is always 4 bytes long
	var LENGTH := 4
	# Array of int, indicating the location of the data in the WAD
	var vertexes_data_ptr: Array = WAD.MAPS[map]["VERTEXES"]
	var vertexes_count = (vertexes_data_ptr[TO] - vertexes_data_ptr[FROM]) / LENGTH
	# To be returned
	var vertexes_array: Array = []

	if map.begins_with("M"): # MAPxy label
		for i in range(vertexes_count):
			var current_vertex = vertexes_data_ptr[0] + (i * LENGTH)

			var vertex_buffer: Dictionary = {
				# Each field is a <short>, 2 bytes long
				"x_coord": _short(
					WAD.FILE.subarray(
						current_vertex, current_vertex + 1)),
				"y_coord": _short(
					WAD.FILE.subarray(
						current_vertex + 2, current_vertex + 3)),
			}

			vertexes_array.append(vertex_buffer)
	else: # ExMy label, to be implemented
		pass

	return vertexes_array

## TODO, check input validity
func _get_sectors(map: String) -> Array:
	# A sector is always 26 bytes long
	var LENGTH := 26
	# Array of int, indicating the location of the data in the WAD
	var sectors_data_ptr: Array = WAD.MAPS[map]["SECTORS"]
	var sectors_count = (sectors_data_ptr[TO] - sectors_data_ptr[FROM]) / LENGTH
	# To be returned
	var sectors_array: Array = []

	if map.begins_with("M"): # MAPxy label
		for i in range(sectors_count):
			var current_sector = sectors_data_ptr[0] + (i * LENGTH)

			var sector_buffer: Dictionary = {
				# Each sector's record is 26 bytes,
				# comprising 2 <short> fields,
				# then 2 <8-byte string> fields,
				# then 3 <short> fields
				"floor_height": _short(
					WAD.FILE.subarray(
						current_sector, current_sector + 1)),
				"ceiling_height": _short(
					WAD.FILE.subarray(
						current_sector + 2, current_sector + 3)),
				"floor_texture": WAD.FILE.subarray(
						current_sector + 4, current_sector + 11
						).get_string_from_ascii(),
				"ceiling_texture": WAD.FILE.subarray(
						current_sector + 12, current_sector + 19
						).get_string_from_ascii(),
				"lightlevel": _short(
					WAD.FILE.subarray(
						current_sector + 20, current_sector + 21)),
				"special_sector": _short(
					WAD.FILE.subarray(
						current_sector + 22, current_sector + 23)),
				"tag": _short(
					WAD.FILE.subarray(
						current_sector + 24, current_sector + 25)),
			}

			sectors_array.append(sector_buffer)
	else: # ExMy label, to be implemented
		pass

	return sectors_array

## Returns a pseudo-short from a set of two bytes
func _short(bytes: PoolByteArray) -> int:
	bytes = _check_short_input(bytes)

	var sum: int = (bytes[1] << 8) + bytes[0]

	if 1<<15 & sum: # If the short is negative
		if sum == 0xffff:
			return 0xffff
		return (sum - 0x8000) * -1 # Flips last bit on set of two bytes
	return sum

## Checks validity of input and returns the correct array
func _check_short_input(input: PoolByteArray) -> PoolByteArray:
	match input.size():
		0: # Fills the array
			input.append_array([0,0])
		1:
			input.push_back(0) # PoolByteArray can't push_front
			input.invert()
		2: # Correct
			pass
		_: # Array too long
			assert("_short input too long. Must be a set of two bytes.")

	return input
