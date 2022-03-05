tool
extends Container

signal slider_value_changed(value)

export(String) var slider_label_text : String = "Label"
onready var slider_label : Label = $Label
onready var slider : HSlider = $HSlider
export(Vector2) var label_rect_size : Vector2

var focused_color : Color = Color("#ffffff")
var unfocused_color : Color = Color("#cde9ff")

func _ready():
	slider_label.text = slider_label_text
	if label_rect_size:
		slider_label.rect_min_size = label_rect_size

func _process(delta):
	if Engine.editor_hint:
		if !slider_label:
			slider_label = $Label
		if label_rect_size:
			slider_label.rect_min_size = label_rect_size
		slider_label.text = slider_label_text

func _on_HSlider_value_changed(value : float):
	emit_signal("slider_value_changed", value)

func _on_HSlider_mouse_entered():
	slider.grab_focus()

func _on_HSlider_focus_entered():
	slider_label.add_color_override("font_color", focused_color)

func _on_HSlider_focus_exited():
	slider_label.add_color_override("font_color", unfocused_color)

func _on_Slider_mouse_entered():
	slider.grab_focus()
