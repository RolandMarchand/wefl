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
# Singleton to store WAD data.
extends Node

signal data_ready

# Populated by reader.gd
var FILE: PoolByteArray = []
var HEADER: Dictionary = {}
var LUMPS: Array = []

var MAPS: Dictionary = {}

## Returns a dictionary of all data lumps for a specific maps
## Each dictionary entry is an array containing the beginning and the end of
## the data of each lump.
func _get_lump_data(from: int) -> Dictionary:
	var data_dict: Dictionary = {}

	for data in [
		"THINGS",
		"LINEDEFS",
		"SIDEDEFS",
		"VERTEXES",
		"SEGS",
		"SSECTORS",
		"NODES",
		"SECTORS",
		"REJECT",
		"BLOCKMAP",
		"BEHAVIOR"
	]:
		data_dict[data] = LUMPS[LUMPS.find(data, from) + 1]

	return data_dict

## Populates the MAPS dictionary with a dictionary from _get_lump_data for
## each MAP marker
func add_maps():
	var current_map: int
	var lump
	for pos in range(LUMPS.size()):
		lump = LUMPS[pos]

		if typeof(lump) == TYPE_STRING and lump.begins_with("MAP"):
			MAPS[lump] = _get_lump_data(pos)

	emit_signal("data_ready")

## Used by reader.gd
func add_bytes(bytes: PoolByteArray) -> void:
	print(bytes)
	FILE.append_array(bytes)
