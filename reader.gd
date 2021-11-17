# This file is part of Wefl.
#
# Wefl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Wefl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Wefl.  If not, see <https://www.gnu.org/licenses/>.
#
#
# Description:
# This file reads WAD files, and stores the header, dictionary and data
# into dictionaries.
# Might remove the GUI control later.
extends MarginContainer

onready var bar: ProgressBar = $VBoxContainer/ProgressBar
onready var label: Label = $VBoxContainer/Label

# Loads wad with multiple threads
var thread := Thread.new()
var mutex := Mutex.new()

var wad_config: ConfigFile = ConfigFile.new()

func _ready() -> void:
# warning-ignore:return_value_discarded
	thread.start(self, "_record_wad")

func _load_config():
# warning-ignore:return_value_discarded
	_set_loading_screen("Load config...", 1)

	wad_config.load("res://doom2.cfg")
	WAD.FILE = wad_config.get_value("doom2.wad", "wad_file")
	WAD.HEADER = wad_config.get_value("doom2.wad", "header")
	WAD.LUMPS = wad_config.get_value("doom2.wad", "lumps")

	_set_loading_screen("Config loaded!", 1, 1)

func _record_wad():
	if File.new().file_exists("res://doom2.cfg"):
		_load_config()
		return

	var wad_file = File.new()
	wad_file.open("res://doom2.wad", File.READ)

	# Sets the loading screen
	mutex.lock()
	_set_loading_screen("Loading wad...", wad_file.get_len())
	mutex.unlock()

	# Loads every byte into WAD.FILE PoolByteArray
	var tmp_byte_buffer: PoolByteArray = []
	while not wad_file.eof_reached():
		tmp_byte_buffer.append_array(wad_file.get_buffer(128))

		mutex.lock()
		bar.value += 128
		mutex.unlock()

	WAD.FILE = tmp_byte_buffer
	# warning-ignore:return_value_discarded
	tmp_byte_buffer.empty()

	wad_file.close()

	# Records header and stores pointer to lump dictionary
	var ptr_dict: int = _record_header()
	_record_lumps(ptr_dict)
	_save_records()

	mutex.lock()
	_set_loading_screen("Wad loaded!", 1, 1)
	mutex.unlock()


# wadinfo_t
# |position	|length	|name		|description
# |-------------+-------+---------------+-------------------------------
# |0x00		|4	|identification	|The ASCII characters "IWAD" or "PWAD"
# |0x04		|4	|numlumps	|An integer specifying the number of lumps in the WAD.
# |0x08		|4	|infotableofs	|An integer holding a pointer to the location of the directory.
## Records the WAD's header into WAD.HEADER
## Returns pointer to the beginning of the lump dictionary
func _record_header() -> int:
	WAD.HEADER["identification"] = WAD.FILE.subarray(0, 3).get_string_from_ascii()
	WAD.HEADER["numlumps"] = byte2int(WAD.FILE.subarray(4, 7))
	WAD.HEADER["infotableofs"] = byte2int(WAD.FILE.subarray(8, 11))

	mutex.lock()
	_set_loading_screen("Loading lumps...", WAD.HEADER["numlumps"])
	mutex.unlock()

	return WAD.HEADER["infotableofs"]

# filelump_t
# |position	|length	|name		|description
# |-------------+-------+---------------+-------------------------------
# |0x00		|4	|filepos	|An integer holding a pointer to the start of the lump's data in the file.
# |0x04		|4	|size		|An integer representing the size of the lump in bytes.
# |0x08		|8	|name		|An ASCII string defining the lump's name. Only the characters A-Z (uppercase), 0-9, and [ ] - _ should be used in lump names (an exception has to be made for some of the Arch-Vile sprites, which use "\"). When a string is less than 8 bytes long, it should be null-padded to the eighth byte. Values exceeding 8 bytes are forbidden.
## Records the WAD's dictionary into WAD.LUMPS
func _record_lumps(ptr: int):
	var lump_name := WAD.FILE.subarray(ptr + 8, ptr + 15).get_string_from_ascii()
	var from := byte2int(WAD.FILE.subarray(ptr, ptr + 3))
	var to := from + byte2int(WAD.FILE.subarray(ptr + 4, ptr + 7))

	WAD.LUMPS[lump_name] = [from, to]

	mutex.lock()
	bar.value += 1
	mutex.unlock()

	if ptr + 32 < WAD.FILE.size(): # If not out of bound
		_record_lumps(ptr + 16)

func _set_loading_screen(text: String, max_val: int, init_val: int = 0) -> void:
	label.text = text
	bar.max_value = max_val
	bar.value = init_val

func _save_records():
	if not File.new().file_exists("res://doom2.cfg"):
		wad_config.set_value("doom2.wad", "wad_file", WAD.FILE)
		wad_config.set_value("doom2.wad", "header", WAD.HEADER)
		wad_config.set_value("doom2.wad", "lumps", WAD.LUMPS)
		# warning-ignore:return_value_discarded
		wad_config.save("res://doom2.cfg")

func _exit_tree():
	thread.wait_to_finish()

## Converts an array of bytes into an integer
func byte2int(bytes: PoolByteArray) -> int:
	var result := 0

	for i in range(bytes.size()):
		result += bytes[i] << (i * 8)

	return result
