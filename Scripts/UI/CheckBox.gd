tool
extends Container

signal check_value_changed(value)

export(String) var check_label_text : String = "Label"
onready var check_label : Label = $Label
onready var check_box : CheckBox = $CheckBox

var focused_color : Color = Color("#ffffff")
var unfocused_color : Color = Color("#cde9ff")

func _ready():
	check_label.text = check_label_text

func _process(delta):
	if Engine.editor_hint:
		if !check_label:
			check_label = $Label
		check_label.text = check_label_text

func _on_CheckBox_toggled(button_pressed : bool):
	emit_signal("check_value_changed", button_pressed)

func _on_CheckBox_mouse_entered():
	check_box.grab_focus()

func _on_CheckBox_focus_exited():
	check_label.add_color_override("font_color", unfocused_color)

func _on_CheckBox_focus_entered():
	check_label.add_color_override("font_color", focused_color)

func _on_CustomCheck_focus_entered():
	check_box.grab_focus()
	check_label.add_color_override("font_color", focused_color)

func _on_CustomCheck_focus_exited():
	check_label.add_color_override("font_color", unfocused_color)

func _on_CustomCheck_mouse_entered():
	check_box.grab_focus()

func _on_CustomCheck_gui_input(event):
	if event is InputEventMouseButton && event.button_index == 1 && !event.pressed:
		check_box.pressed = !check_box.pressed
