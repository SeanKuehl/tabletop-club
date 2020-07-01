# open-tabletop
# Copyright (c) 2020 drwhut
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node

const VALID_TEXTURE_EXTENSIONS = ["png"]

# NOTE: Pieces are stored similarly to the directory structures, but all piece
# types are direct children of the game, i.e. "OpenTabletop/dice/d6" in the
# game directory is _db["OpenTabletop"]["d6"] here.
var _db = {}

func get_db() -> Dictionary:
	return _db

func import_all() -> void:
	import_game_dir("res://OpenTabletop")
	
	# TODO: Check directories in the user:// directory!

func import_game_dir(dir_path: String) -> void:
	var dir = Directory.new()
	
	if dir.open(dir_path) == OK:
		
		var game_name = dir.get_current_dir().get_file()
		
		_db[game_name] = {}
		
		if dir.dir_exists("dice"):
			dir.change_dir("dice")
			
			_add_dir_if_exists(dir, game_name, "d4", "res://Pieces/Dice/d4.tscn")
			_add_dir_if_exists(dir, game_name, "d6", "res://Pieces/Dice/d6.tscn")
			_add_dir_if_exists(dir, game_name, "d8", "res://Pieces/Dice/d8.tscn")
			
			dir.change_dir("..")
	else:
		push_error("Cannot scan " + dir_path + " to import assets!")

func _add_dir_if_exists(current_dir: Directory, game_name: String, dir: String,
	model: String) -> void:
	
	if current_dir.dir_exists(dir):
		current_dir.change_dir(dir)
		
		var array = []
	
		current_dir.list_dir_begin(true, true)
		
		var file = current_dir.get_next()
		while file:
			if VALID_TEXTURE_EXTENSIONS.has(file.get_extension()):
				_add_entry_to_array(array, current_dir, file, model)
				
			file = current_dir.get_next()
		
		_db[game_name][dir] = array
		
		current_dir.change_dir("..")

func _add_entry_to_array(array: Array, dir: Directory, file: String,
	model_path: String) -> void:
	
	var name = file.substr(0, file.length() - file.get_extension().length() - 1)
	var texture_path = dir.get_current_dir() + "/" + file
	
	array.push_back(PieceDBEntry.new(name, model_path, texture_path))