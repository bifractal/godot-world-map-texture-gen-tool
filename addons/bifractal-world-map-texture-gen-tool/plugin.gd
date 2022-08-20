# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

tool
extends EditorPlugin

const GenerationProgressDialog = preload("ui/dialogs/GenerationProgressDialog.tscn")
const WorldMapTextureGenDialog = preload("ui/dialogs/WorldMapTextureGenDialog.tscn")
const WorldMapTextureGenButton = preload("ui/WorldMapTextureGenButton.tscn")

var editor_interface				: EditorInterface		= null
var generation_progress_dialog		: PopupDialog			= null
var world_map_texture_gen_dialog	: ConfirmationDialog	= null
var world_map_texture_gen_button	: Button				= null

# Enter Tree
func _enter_tree():
	editor_interface = get_editor_interface()
	var editor_theme = editor_interface.get_base_control().theme
	
	# Progress Dialog
	generation_progress_dialog = GenerationProgressDialog.instance()
	generation_progress_dialog.theme = editor_theme
	add_child(generation_progress_dialog)
	
	# Main Dialog
	world_map_texture_gen_dialog = WorldMapTextureGenDialog.instance()
	world_map_texture_gen_dialog.theme = editor_theme
	world_map_texture_gen_dialog.generation_progress_dialog = generation_progress_dialog
	add_child(world_map_texture_gen_dialog)
	
	# Toolbar Button
	world_map_texture_gen_button = WorldMapTextureGenButton.instance()
	world_map_texture_gen_button.theme = editor_theme
	world_map_texture_gen_button.connect("pressed", world_map_texture_gen_dialog, "popup_centered")
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, world_map_texture_gen_button)
	
	var edited_scene = editor_interface.get_tree().get_edited_scene_root()
	world_map_texture_gen_dialog.set_scene(edited_scene)
	
	connect("scene_changed", self, "_on_scene_changed")

# Exit Tree
func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, world_map_texture_gen_button)
	remove_child(world_map_texture_gen_dialog)
	remove_child(generation_progress_dialog)

# On Scene Changed
func _on_scene_changed(scene : Node):
	world_map_texture_gen_dialog.set_scene(scene)
