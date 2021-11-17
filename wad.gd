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

var FILE: PoolByteArray = []
var HEADER: Dictionary = {}
var LUMPS: Dictionary = {}

func add_bytes(bytes: PoolByteArray) -> void:
	print(bytes)
	FILE.append_array(bytes)
