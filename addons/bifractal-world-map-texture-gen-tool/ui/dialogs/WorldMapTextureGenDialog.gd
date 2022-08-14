# MIT License
# Copyright (c) 2022 BIFRACTAL - Florian Roth

tool
extends ConfirmationDialog

# User Interface
var ui_map_name_input			: LineEdit		= null
var ui_world_size_input			: SpinBox		= null
var ui_camera_view_distance		: SpinBox		= null
var ui_texture_size_input		: OptionButton	= null
var ui_output_path_input		: LineEdit		= null
var ui_add_gitignore_checkbox	: CheckBox		= null
var ui_add_gdignore_checkbox	: CheckBox		= null

var ui_bottom_separator			: HSeparator	= null
var ui_warning_label			: Label			= null

# Nodes
var scene 						: Spatial	= null
var image_file_path 			: String	= ""
var viewport 					: Viewport	= null
var camera_timer 				: Timer		= null
var map_name					: String	= ""

# Settings
const SETTINGS_FILE = "user://bifractal-world-map-gen-settings.save"

var settings : Dictionary = {
	"world_size"			: 0,
	"camera_view_distance"	: 0,
	"texture_size_sq"		: 0,
	"output_path"			: "",
	"add_gitignore"			: false,
	"add_gdignore"			: false
}

# Ready
func _enter_tree():
	ui_map_name_input			= $MainLayout/FormLayout/MapNameInput
	ui_world_size_input			= $MainLayout/FormLayout/WorldSizeInput
	ui_camera_view_distance		= $MainLayout/FormLayout/CameraViewDistanceInput
	ui_texture_size_input		= $MainLayout/FormLayout/TextureSizeInput
	ui_output_path_input		= $MainLayout/FormLayout/OutputPathLayout/OutputPathInput
	ui_add_gitignore_checkbox	= $MainLayout/FormLayout/AddGitignoreCheckbox
	ui_add_gdignore_checkbox	= $MainLayout/FormLayout/AddGdignoreCheckbox
	
	ui_bottom_separator			= $MainLayout/BottomSeparator
	ui_warning_label			= $MainLayout/WarningLabel
	
	_load_settings()
	_toggle_warning_label()
	
	# Force Default Size
	_resize_dialog()

# Set Scene
func set_scene(scene : Node):
	self.scene = scene
	
	if (self.scene != null):
		map_name = self.scene.name
		ui_map_name_input.text = map_name

# Resize Dialog
func _resize_dialog():
	rect_size = Vector2(650.0, 520.0)

# Apply Settings From UI
func _apply_settings_from_ui():
	map_name = ui_map_name_input.text
	
	if (map_name == ""):
		map_name = scene.name
	
	map_name = map_name.replace(" ", "_")
	
	settings.world_size = ui_world_size_input.value
	settings.camera_view_distance = ui_camera_view_distance.value
	settings.texture_size_sq = ui_texture_size_input.text.to_int()
	
	# TODO Future Version ...
	#var generation_mode = $MainLayout/FormLayout/GenerationModeDropdown.selected
	
	settings.output_path = ui_output_path_input.text
	
	if (settings.output_path == ""):
		settings.output_path = "res://world_maps/"
	
	settings.add_gitignore = ui_add_gitignore_checkbox.pressed
	settings.add_gdignore = ui_add_gdignore_checkbox.pressed

# Apply UI From Settings
func _apply_ui_from_settings():
	
	# Use the scene name as map name.
	#ui_map_name_input.text = str(settings.map_name)
	
	ui_world_size_input.value			= int(settings.world_size)
	ui_camera_view_distance.value		= int(settings.camera_view_distance)
	
	# Find index for texture size string.
	for i in ui_texture_size_input.get_item_count():
		var item_text = ui_texture_size_input.get_item_text(i)
		
		if (item_text == str(settings.texture_size_sq)):
			ui_texture_size_input.selected = i
			break
	
	ui_output_path_input.text			= str(settings.output_path)
	ui_add_gitignore_checkbox.pressed	= bool(settings.add_gitignore)
	ui_add_gdignore_checkbox.pressed	= bool(settings.add_gdignore)

# Generate Map
func _generate_map():
	print("Generating world map texture for scene \"" + scene.name + "\" ...")
	
	# Open/Create Output Directory
	var output_dir = Directory.new()
	
	if (output_dir.open(settings.output_path) != OK):
		if (output_dir.make_dir(settings.output_path) != OK):
			push_error("Could not open or create ouput directory for world map texture generation.")
			return
	
	# Add .gitignore?
	if (settings.add_gitignore):
		var file_gitignore = File.new()
		var err = file_gitignore.open(settings.output_path + "/" + ".gitignore", File.WRITE)
		
		if (err == OK):
			file_gitignore.store_string("*.png\n");
			file_gitignore.close()
		else:
			var warning_msg = "Could not create .gitignore file inside world map texture output directory."
			warning_msg += " EC: [" + str(err) + "]."
			push_warning(warning_msg)
			
	# Add .gdignore?
	if (settings.add_gdignore):
		var file_gdignore = File.new()
		var err = file_gdignore.open(settings.output_path + "/" + ".gdignore", File.WRITE)
		
		if (err == OK):
			file_gdignore.close()
		else:
			var warning_msg = "Could not create .gitignore file inside world map texture output directory."
			warning_msg += " EC: [" + str(err) + "]."
			push_warning(warning_msg)
	
	# Create Viewport Node
	viewport = Viewport.new()
	viewport.name 						= "WORLD_MAP_GEN_VIEWPORT"
	viewport.size 						= Vector2(settings.texture_size_sq, settings.texture_size_sq)
	viewport.transparent_bg 			= true # TODO Make optional
	viewport.render_target_clear_mode	= Viewport.CLEAR_MODE_NEVER
	viewport.render_target_update_mode 	= Viewport.UPDATE_ALWAYS
	viewport.render_target_v_flip		= true
	viewport.msaa 						= Viewport.MSAA_8X
	viewport.fxaa						= true
	
	# TODO Include shadows?
	# TODO viewport.debug_draw = Viewport.DEBUG_DRAW_UNSHADED
	
	scene.add_child(viewport)
	viewport.set_owner(scene)
	
	# Create Camera Node
	var camera = Camera.new()
	camera.name 			= "WORLD_MAP_GEN_CAMERA"
	camera.projection 		= Camera.PROJECTION_ORTHOGONAL
	camera.size 			= settings.world_size
	camera.far 				= settings.camera_view_distance
	camera.translation.y 	= settings.world_size
	camera.rotation.x 		= deg2rad(-90.0)
	
	# TODO Apply Generation Mode (Future Version).
	
	viewport.add_child(camera)
	camera.set_owner(viewport)
	
	# Create/Start Camera Timer
	yield(VisualServer, "frame_post_draw")
	
	camera_timer = Timer.new()
	camera_timer.name 		= "WORLD_MAP_GEN_CAMERA_TIMER"
	camera_timer.one_shot 	= true
	camera_timer.wait_time 	= 0.5
	camera_timer.connect("timeout", self, "_on_camera_timer_timeout")
	
	scene.add_child(camera_timer)
	camera_timer.set_owner(scene)
	
	camera_timer.start()

# Store Settings
func _store_settings():
	var file = File.new()
	var err = file.open(SETTINGS_FILE, File.WRITE)
	
	if (err != OK):
		push_error("Could not store world map generator settings. EC: [" + str(err) + "].")
		return
	
	file.store_string(to_json(settings))
	file.close()

# Load Settings
func _load_settings():
	var file = File.new()
	
	# There are no settings available initially.
	if (file.open(SETTINGS_FILE, File.READ) != OK):
		#push_warning("Could not load world map generator settings.")
		return
	
	while (file.get_position() < file.get_len()):
		var line = file.get_line()
		settings = parse_json(line)
		
		if (typeof(settings) != TYPE_DICTIONARY):
			push_warning("Could not read world map generator settings file.")
		else:
			_apply_ui_from_settings()
	
	file.close()

# Reset Default Settings
func _reset_default_settings():
	
	# !!! Synchronize with UI !!!
	
	# Note: The map name is applied automatically from current scene.
	
	settings.world_size				= 1000
	settings.camera_view_distance	= 1000
	settings.texture_size_sq		= 2048
	settings.output_path			= "res://world_maps/"
	settings.add_gitignore			= true
	settings.add_gdignore			= true
	
	_store_settings()
	_apply_ui_from_settings()
	_toggle_warning_label()

# Toggle Warning Label
func _toggle_warning_label():
	var warning_visible = int(ui_texture_size_input.text) >= 4096
	ui_bottom_separator.visible = warning_visible
	ui_warning_label.visible = warning_visible
	_resize_dialog()

# On Confirmed
func _on_confirmed():
	if (scene == null or !(scene is Spatial)):
		push_warning("Could not generate world map texture from empty scene or non-Spatial scenes.")
		return
	
	_apply_settings_from_ui()
	_generate_map()
	_store_settings()

# On Camera Timer Timeout
func _on_camera_timer_timeout():
	image_file_path = settings.output_path + "/" + map_name + ".png"
	
	print("Saving world map texture to file \"" + image_file_path + "\" ...")
	
	var image = viewport.get_texture().get_data()
	image.convert(Image.FORMAT_RGB8) # TODO Configurable via UI?
	
	var err = image.save_png(image_file_path)
	
	if (err != OK):
		push_error("Could not save world map texture image. EC: [" + str(err) + "].")
	
	viewport.queue_free()
	camera_timer.queue_free()

# On Texture Size Changed
func _on_texture_size_changed(index):
	_toggle_warning_label()
