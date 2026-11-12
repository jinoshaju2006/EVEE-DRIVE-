extends Node
class_name EVEESettings

const SAVE_PATH := "user://evee_drive_settings.cfg"

var quality := "High"
var target_fps := 60
var render_scale := 1.0
var master_volume := 0.8
var vsync_enabled := true

func _ready() -> void:
	load_settings()
	apply_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	quality = str(config.get_value("graphics", "quality", quality))
	target_fps = int(config.get_value("graphics", "target_fps", target_fps))
	render_scale = float(config.get_value("graphics", "render_scale", render_scale))
	master_volume = float(config.get_value("audio", "master_volume", master_volume))
	vsync_enabled = bool(config.get_value("graphics", "vsync", vsync_enabled))

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("graphics", "quality", quality)
	config.set_value("graphics", "target_fps", target_fps)
	config.set_value("graphics", "render_scale", render_scale)
	config.set_value("graphics", "vsync", vsync_enabled)
	config.set_value("audio", "master_volume", master_volume)
	config.save(SAVE_PATH)

func apply_settings() -> void:
	Engine.max_fps = target_fps
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_volume_linear(bus, master_volume)

	var viewport := get_viewport()
	match quality:
		"Low":
			render_scale = 0.70
			viewport.msaa_3d = Viewport.MSAA_DISABLED
		"Medium":
			render_scale = 0.85
			viewport.msaa_3d = Viewport.MSAA_2X
		"High":
			render_scale = 1.0
			viewport.msaa_3d = Viewport.MSAA_2X
		"Ultra":
			render_scale = 1.0
			viewport.msaa_3d = Viewport.MSAA_4X
		_:
			render_scale = 1.0
			viewport.msaa_3d = Viewport.MSAA_2X
	viewport.scaling_3d_scale = render_scale
