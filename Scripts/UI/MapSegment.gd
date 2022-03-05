extends TextureRect
class_name MapSegment

export(String) var room_id : String
var discovered : bool = false
var current : bool = false
var completed : bool = false

func _ready():
	if self.room_id == "":
		self.room_id = self.name

func discover() -> void: 
	self.discovered = true
	self.visible = true
	self.modulate = Color("#93ca5d") if !self.current else Color("#7eff00")

func set_current(room : String) -> void:
	if room == self.room_id && !self.current:
		if !self.discovered:
			self.discover()
		self.current = true
		self.modulate = Color("#7eff00")
	elif room != self.room_id && self.current:
		self.current = false
		self.modulate = Color("#93ca5d") if !self.completed else Color("#96af7d")

func set_room_completed(room : String) -> void:
	if room == self.room_id && !self.completed:
		self.completed = true
		self.modulate = Color("#96af7d")

func set_room_discovered(room : String) -> void:
	if room == self.room_id && !self.discovered:
		self.discover()
