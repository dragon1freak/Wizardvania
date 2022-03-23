extends Node

onready var view_box : ViewportContainer = $Box
onready var viewport : Viewport = $Box/Viewport
onready var screen_res = get_viewport().size

var scaling : Vector2 = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	scaling = screen_res / viewport.size
	view_box.rect_scale = scaling
