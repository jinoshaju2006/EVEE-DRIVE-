extends Node3D

const VehicleController = preload("res://scripts/vehicle_controller.gd")
const MobileControls = preload("res://scripts/mobile_controls.gd")
const EngineAudio = preload("res://scripts/engine_audio.gd")
const SettingsManager = preload("res://scripts/settings_manager.gd")

var vehicle: CharacterBody3D
var follow_camera: Camera3D
var cockpit_camera: Camera3D
var use_cockpit := false
var speed_label: Label
var settings: Node
var engine_audio: Node
var settings_panel: PanelContainer

func _ready() -> void:
	settings = SettingsManager.new()
	add_child(settings)
	_create_world()
	_create_vehicle()
	_create_cameras()
	_create_audio()
	_create_hud()

func _create_world() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.68, 0.78)
	environment.ambient_light_energy = 0.8
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = true
	environment.glow_intensity = 0.35
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 100.0
	add_child(sun)

	var ground := StaticBody3D.new()
	ground.name = "Ground"
	var ground_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(500.0, 500.0)
	ground_mesh.mesh = plane
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.12, 0.19, 0.16)
	ground_material.roughness = 1.0
	ground_mesh.material_override = ground_material
	ground.add_child(ground_mesh)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(500.0, 0.2, 500.0)
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.1
	ground.add_child(ground_collision)
	add_child(ground)

	var road := MeshInstance3D.new()
	var road_mesh := BoxMesh.new()
	road_mesh.size = Vector3(12.0, 0.08, 240.0)
	road.mesh = road_mesh
	road.position = Vector3(0.0, 0.02, -40.0)
	var road_material := StandardMaterial3D.new()
	road_material.albedo_color = Color(0.075, 0.085, 0.10)
	road_material.roughness = 0.95
	road.material_override = road_material
	add_child(road)

	# Road edge markers make the first test track easier to read.
	for side in [-1.0, 1.0]:
		for z in range(-150, 90, 12):
			var marker := MeshInstance3D.new()
			var marker_mesh := BoxMesh.new()
			marker_mesh.size = Vector3(0.18, 0.12, 3.0)
			marker.mesh = marker_mesh
			marker.position = Vector3(side * 5.65, 0.12, float(z))
			var marker_material := StandardMaterial3D.new()
			marker_material.albedo_color = Color(0.82, 0.82, 0.78)
			marker.material_override = marker_material
			add_child(marker)

func _create_vehicle() -> void:
	vehicle = CharacterBody3D.new()
	vehicle.name = "PlayerVehicle"
	vehicle.position = Vector3(0.0, 1.0, 0.0)
	vehicle.set_script(VehicleController)

	var body_mesh := MeshInstance3D.new()
	var body := BoxMesh.new()
	body.size = Vector3(2.0, 0.65, 4.2)
	body_mesh.mesh = body
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color(0.22, 0.08, 0.42)
	paint.metallic = 0.72
	paint.roughness = 0.24
	body_mesh.material_override = paint
	body_mesh.position.y = 0.25
	vehicle.add_child(body_mesh)

	var cabin_mesh := MeshInstance3D.new()
	var cabin := BoxMesh.new()
	cabin.size = Vector3(1.55, 0.62, 1.85)
	cabin_mesh.mesh = cabin
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.035, 0.07, 0.10)
	glass.metallic = 0.35
	glass.roughness = 0.18
	cabin_mesh.material_override = glass
	cabin_mesh.position = Vector3(0.0, 0.82, -0.15)
	vehicle.add_child(cabin_mesh)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 1.0, 4.2)
	collision.shape = shape
	collision.position.y = 0.35
	vehicle.add_child(collision)
	add_child(vehicle)

func _create_cameras() -> void:
	follow_camera = Camera3D.new()
	follow_camera.name = "ThirdPersonCamera"
	follow_camera.current = true
	follow_camera.fov = 72.0
	add_child(follow_camera)

	cockpit_camera = Camera3D.new()
	cockpit_camera.name = "CockpitCamera"
	cockpit_camera.fov = 82.0
	cockpit_camera.position = Vector3(0.0, 1.35, -0.35)
	vehicle.add_child(cockpit_camera)

func _create_audio() -> void:
	engine_audio = EngineAudio.new()
	add_child(engine_audio)

func _process(delta: float) -> void:
	if not is_instance_valid(vehicle):
		return
	var speed := absf(vehicle.velocity.length()) * 3.6
	speed_label.text = "%03d km/h" % int(speed)
	engine_audio.set_load(clampf(speed / 120.0, 0.0, 1.0))

	if use_cockpit:
		follow_camera.current = false
		cockpit_camera.current = true
	else:
		cockpit_camera.current = false
		follow_camera.current = true
		var target := vehicle.global_position + Vector3(0.0, 3.2, 7.5).rotated(Vector3.UP, vehicle.rotation.y)
		follow_camera.global_position = follow_camera.global_position.lerp(target, min(delta * 5.0, 1.0))
		follow_camera.look_at(vehicle.global_position + Vector3(0.0, 0.8, 0.0), Vector3.UP)

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)

	var top := HBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 24.0
	top.offset_top = 18.0
	top.offset_right = -24.0
	top.offset_bottom = 82.0
	layer.add_child(top)

	speed_label = Label.new()
	speed_label.text = "000 km/h"
	speed_label.add_theme_font_size_override("font_size", 30)
	speed_label.add_theme_color_override("font_color", Color.WHITE)
	top.add_child(speed_label)
	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(top_spacer)

	var settings_button := Button.new()
	settings_button.text = "SETTINGS"
	settings_button.custom_minimum_size = Vector2(150.0, 58.0)
	settings_button.pressed.connect(_toggle_settings)
	top.add_child(settings_button)

	var camera_button := Button.new()
	camera_button.text = "CAMERA"
	camera_button.custom_minimum_size = Vector2(140.0, 58.0)
	camera_button.pressed.connect(_toggle_camera)
	top.add_child(camera_button)

	_create_touch_controls(layer)
	_create_settings_panel(layer)

	var hint := Label.new()
	hint.text = "WASD / Arrow keys to drive • Space for handbrake"
	hint.position = Vector2(24.0, 92.0)
	hint.add_theme_color_override("font_color", Color(0.9, 0.92, 1.0, 0.8))
	layer.add_child(hint)

func _create_touch_controls(layer: CanvasLayer) -> void:
	var steering := HBoxContainer.new()
	steering.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	steering.offset_left = 24.0
	steering.offset_bottom = -24.0
	steering.add_child(MobileControls.make_hold_button("◀", "steer_left", Vector2(94.0, 88.0)))
	steering.add_child(MobileControls.make_hold_button("▶", "steer_right", Vector2(94.0, 88.0)))
	layer.add_child(steering)

	var pedals := VBoxContainer.new()
	pedals.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	pedals.offset_right = -24.0
	pedals.offset_bottom = -24.0
	pedals.add_child(MobileControls.make_hold_button("ACCEL", "accelerate", Vector2(132.0, 82.0)))
	pedals.add_child(MobileControls.make_hold_button("BRAKE", "brake", Vector2(132.0, 76.0)))
	layer.add_child(pedals)

	var handbrake_button := MobileControls.make_hold_button("HANDBRAKE", "handbrake", Vector2(132.0, 58.0))
	handbrake_button.anchor_left = 1.0
	handbrake_button.anchor_right = 1.0
	handbrake_button.anchor_top = 1.0
	handbrake_button.anchor_bottom = 1.0
	handbrake_button.offset_left = -170.0
	handbrake_button.offset_right = -24.0
	handbrake_button.offset_top = -240.0
	handbrake_button.offset_bottom = -176.0
	layer.add_child(handbrake_button)

func _create_settings_panel(layer: CanvasLayer) -> void:
	settings_panel = PanelContainer.new()
	settings_panel.visible = false
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.offset_left = -250.0
	settings_panel.offset_right = 250.0
	settings_panel.offset_top = -220.0
	settings_panel.offset_bottom = 220.0
	layer.add_child(settings_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	settings_panel.add_child(layout)

	var heading := Label.new()
	heading.text = "GRAPHICS & AUDIO"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 24)
	layout.add_child(heading)

	var quality_label := Label.new()
	quality_label.text = "Graphics quality"
	layout.add_child(quality_label)
	var quality := OptionButton.new()
	for item in ["Low", "Medium", "High", "Ultra"]:
		quality.add_item(item)
	quality.select(2)
	quality.item_selected.connect(func(index: int):
		settings.quality = quality.get_item_text(index)
		settings.apply_settings()
		settings.save_settings()
	)
	layout.add_child(quality)

	var fps_label := Label.new()
	fps_label.text = "Frame-rate target"
	layout.add_child(fps_label)
	var fps := OptionButton.new()
	for rate in [30, 60, 90, 120, 144]:
		fps.add_item("%d FPS" % rate)
	fps.select(1)
	fps.item_selected.connect(func(index: int):
		settings.target_fps = [30, 60, 90, 120, 144][index]
		settings.apply_settings()
		settings.save_settings()
	)
	layout.add_child(fps)

	var volume_label := Label.new()
	volume_label.text = "Master volume"
	layout.add_child(volume_label)
	var volume := HSlider.new()
	volume.min_value = 0.0
	volume.max_value = 1.0
	volume.step = 0.05
	volume.value = settings.master_volume
	volume.value_changed.connect(func(value: float):
		settings.master_volume = value
		settings.apply_settings()
		settings.save_settings()
	)
	layout.add_child(volume)

	var vsync := CheckBox.new()
	vsync.text = "Vertical sync"
	vsync.button_pressed = settings.vsync_enabled
	vsync.toggled.connect(func(enabled: bool):
		settings.vsync_enabled = enabled
		settings.apply_settings()
		settings.save_settings()
	)
	layout.add_child(vsync)

	var close_button := Button.new()
	close_button.text = "RESUME DRIVING"
	close_button.pressed.connect(_toggle_settings)
	layout.add_child(close_button)

func _toggle_camera() -> void:
	use_cockpit = not use_cockpit

func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
