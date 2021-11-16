extends MarginContainer

signal wad_recorded
signal wad_indexed

enum {FROM,TO}

onready var bar: ProgressBar = $VBoxContainer/ProgressBar
onready var label: Label = $VBoxContainer/Label

# Loads wad with multiple threads
var thread := Thread.new()
var mutex := Mutex.new()

var WAD: PoolByteArray = []
var wadinfo_t: Dictionary = {}
var filelump_t: Dictionary = {}

func _ready() -> void:
	thread.start(self, "_record_wad", null, Thread.PRIORITY_LOW)
	connect("wad_recorded", self, "_record_wadinfo_t")

func _physics_process(_delta):
	mutex.lock()
	# Updates bar value while loading wad every frame
	# instead of every byte for performances
	if  bar.value < bar.max_value and label.text == "Loading wad...":
		bar.value = float(WAD.size())
	mutex.unlock()

func _record_wad():
	var wad_file = File.new()
	wad_file.open("res://doom2.wad", File.READ)

	# Sets the loading screen
	mutex.lock()
	_set_loading_screen("Loading wad...", wad_file.get_len())
	mutex.unlock()

	# Loads every byte into WAD PoolByteArray
	while not wad_file.eof_reached():
		WAD.append(wad_file.get_8())

	wad_file.close()

	emit_signal("wad_recorded")

# wadinfo_t
# |position	|length	|name		|description
# |-------------+-------+---------------+-------------------------------
# |0x00		|4	|identification	|The ASCII characters "IWAD" or "PWAD"
# |0x04		|4	|numlumps	|An integer specifying the number of lumps in the WAD.
# |0x08		|4	|infotableofs	|An integer holding a pointer to the location of the directory.
func _record_wadinfo_t():
	wadinfo_t["identification"] = WAD.subarray(0, 3).get_string_from_ascii()
	wadinfo_t["numlumps"] = byte2int(WAD.subarray(4, 7))
	wadinfo_t["infotableofs"] = byte2int(WAD.subarray(8, 11))

	mutex.lock()
	_set_loading_screen("Loading lumps...", wadinfo_t["numlumps"])
	mutex.unlock()

	_record_filelump_t(wadinfo_t["infotableofs"])

# filelump_t
# |position	|length	|name		|description
# |-------------+-------+---------------+-------------------------------
# |0x00		|4	|filepos	|An integer holding a pointer to the start of the lump's data in the file.
# |0x04		|4	|size		|An integer representing the size of the lump in bytes.
# |0x08		|8	|name		|An ASCII string defining the lump's name. Only the characters A-Z (uppercase), 0-9, and [ ] - _ should be used in lump names (an exception has to be made for some of the Arch-Vile sprites, which use "\"). When a string is less than 8 bytes long, it should be null-padded to the eighth byte. Values exceeding 8 bytes are forbidden.
func _record_filelump_t(ptr: int):
	var lump_name := WAD.subarray(ptr + 8, ptr + 15).get_string_from_ascii()
	var from := byte2int(WAD.subarray(ptr, ptr + 3))
	var to := from + byte2int(WAD.subarray(ptr + 4, ptr + 7))

	wadinfo_t[lump_name] = [from, to]

	mutex.lock()
	bar.value += 1
	mutex.unlock()

	if ptr + 32 < WAD.size(): # If not out of bound
		_record_filelump_t(ptr + 16)
	else:
		print(wadinfo_t.keys()[0], wadinfo_t.keys()[1], wadinfo_t.keys()[2])

func _set_loading_screen(text: String, max_val: int, init_val: int = 0) -> void:
	label.text = text
	bar.max_value = max_val
	bar.value = init_val

func _exit_tree():
	thread.wait_to_finish()

func byte2int(bytes: PoolByteArray) -> int:
	var result := 0

	for i in range(bytes.size()):
		result += bytes[i] << (i * 8)

	return result
