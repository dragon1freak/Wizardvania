extends Button

var button_text : String
onready var right_arrow : Label = $RightArrow
onready var left_arrow : Label = $LeftArrow

var rollover = preload("res://Sounds/rollover2.ogg")

func _ready():
	self.button_text = self.text
	hide_arrow()

func show_arrow() -> void:
#	self.text = ">" + self.button_text + "<"
	right_arrow.visible = true
	left_arrow.visible = true

func hide_arrow() -> void:
#	self.text = self.button_text
	right_arrow.visible = false
	left_arrow.visible = false

func _on_MenuButton_focus_entered():
	self.show_arrow()
#	SoundManager.play_sound(rollover)

func _on_MenuButton_focus_exited():
	self.hide_arrow()

func _on_MenuButton_mouse_entered():
	grab_focus()
