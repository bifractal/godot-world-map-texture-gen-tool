# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

tool
extends PopupDialog

# User Interface
var ui_message_label	: Label			= null
var ui_finish_label		: Label			= null
var ui_progress_bar		: ProgressBar	= null
var ui_ok_button		: Button		= null

enum UI_MODE {
	InProgress,
	Finished
}

# Enter Tree
func _enter_tree():
	ui_message_label	= $MainLayout/MessageLabel
	ui_finish_label		= $MainLayout/FinishLabel
	ui_progress_bar		= $MainLayout/ProgressBar
	ui_ok_button		= $MainLayout/OKButton
	
	rect_size = Vector2(400.0, 130.0)
	
	_update_ui(UI_MODE.InProgress)

# Set Progress
func set_progress(value: int):
	ui_progress_bar.value = clamp(value, 0, 100)
	
	if (value >= 100):
		_update_ui(UI_MODE.Finished)
	else:
		_update_ui(UI_MODE.InProgress)

# Update UI
func _update_ui(mode):
	
	# In Progress
	if (mode == UI_MODE.InProgress):
		ui_message_label.show()
		ui_finish_label.hide()
		ui_progress_bar.show()
		ui_ok_button.hide()
		return
	
	# Finished
	if (mode == UI_MODE.Finished):
		ui_message_label.hide()
		ui_finish_label.show()
		ui_progress_bar.hide()
		ui_ok_button.show()
