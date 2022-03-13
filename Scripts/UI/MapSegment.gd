extends Control
class_name MapSegment

export(String) var room_id : String
export(Color) onready var current_color : Color
export(Color) onready var empty_color : Color
export(Color) onready var completed_color : Color
var discovered : bool = false
var current : bool = false
var completed : bool = false

func _ready():
	if self.room_id == "":
		self.room_id = self.name

func discover() -> void: 
	self.discovered = true
	self.visible = true
	self.modulate = empty_color if !self.current else current_color

func set_current(room : String) -> void:
	if room == self.room_id && !self.current:
		if !self.discovered:
			self.discover()
		self.current = true
		self.modulate = current_color
	elif room != self.room_id && self.current:
		self.current = false
		self.modulate = empty_color if !self.completed else completed_color

func set_room_completed(room : String) -> void:
	if room == self.room_id && !self.completed:
		self.completed = true
		self.modulate = completed_color

func set_room_discovered(room : String) -> void:
	if room == self.room_id && !self.discovered:
		self.discover()
