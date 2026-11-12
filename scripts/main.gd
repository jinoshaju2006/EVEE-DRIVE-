extends Node3D

const VehicleController = preload("res://scripts/vehicle_controller.gd")
const MobileControls = preload("res://scripts/mobile_controls.gd")
const EngineAudio = preload("res://scripts/engine_audio.gd")
const SettingsManager = preload("res://scripts/settings_manager.gd")
const WorldBuilder = preload("res://scripts/world_builder.gd")
const TrafficManager = preload("res://scripts/traffic_manager.gd")
const OffroadChallenge = preload("res://scripts/offroad_challenge.gd")

var vehicle: CharacterBody3D
var follow_camera: Camera3D
var cockpit_camera: Camera3D
var use_cockpit := false
var speed_label: Label
var settings: Node
var engine_audio: Node
var settings_panel: PanelContainer
var traffic_manager: Node3D
var road_visual_parts: Array[Node3D] = []
var road_wheels: Array[MeshInstance3D] = []
var jeep_wheels: Array[MeshInstance3D] = []
var garage_panel: PanelContainer
var jeep_visual: Node3D
var jeep_selected := false
var street_paint_material: StandardMaterial3D
var jeep_paint_material: StandardMaterial3D
var selected_paint_color := "PURPLE"
var garage_camera_angle := 0.0
var offroad_challenge: Node
var challenge_label: Label

func _ready() -> void:
	settings = SettingsManager.new()
	add_child(settings)
	_create_world()
	_create_traffic()
	_create_offroad_challenge()
	_create_vehicle()
	_create_cameras()
	_create_audio()
	_create_hud()

func _create_world() -> void:
	WorldBuilder.build(self)

func _create_traffic() -> void:
	traffic_manager = TrafficManager.new()
	traffic_manager.name = "AmbientTraffic"
	add_child(traffic_manager)

func _create_offroad_challenge() -> void:
	offroad_challenge = OffroadChallenge.new()
	offroad_challenge.name = "OffroadHillClimbChallenge"
	add_child(offroad_challenge)
	offroad_challenge.progress_changed.connect(_on_challenge_progress)

func _create_vehicle() -> void:
	vehicle = CharacterBody3D.new()
	vehicle.name = "PlayerVehicle"
	vehicle.position = Vector3(0.0, 1.0, 0.0)
	vehicle.set_script(VehicleController)

	var body_mesh := MeshInstance3D.new()
	var body := BoxMesh.new()
	body.size = Vector3(2.0, 0.65, 4.2)
	body_mesh.mesh = body
	street_paint_material = StandardMaterial3D.new()
	street_paint_material.albedo_color = Color(0.22, 0.08, 0.42)
	street_paint_material.metallic = 0.72
	street_paint_material.roughness = 0.24
	body_mesh.material_override = street_paint_material
	road_visual_parts.append(body_mesh)
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
	road_visual_parts.append(cabin_mesh)
	cabin_mesh.position = Vector3(0.0, 0.82, -0.15)
	vehicle.add_child(cabin_mesh)

	# Four low-poly tire meshes and simple front/rear lighting for the prototype car.
	var tire_material := StandardMaterial3D.new()
	tire_material.albedo_color = Color(0.018, 0.02, 0.024)
	tire_material.roughness = 0.92
	for x in [-1.02, 1.02]:
		for z in [-1.35, 1.35]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.47
			wheel_mesh.bottom_radius = 0.47
			wheel_mesh.height = 0.34
			wheel.mesh = wheel_mesh
			wheel.material_override = tire_material
			road_visual_parts.append(wheel)
			road_wheels.append(wheel)
			wheel.rotation.z = PI / 2.0
			wheel.position = Vector3(x, -0.12, z)
			vehicle.add_child(wheel)

	for x in [-0.68, 0.68]:
		var headlight := OmniLight3D.new()
		headlight.light_color = Color(0.72, 0.84, 1.0)
		headlight.light_energy = 1.6
		road_visual_parts.append(headlight)
		headlight.omni_range = 10.0
		headlight.position = Vector3(x, 0.35, -2.08)
		vehicle.add_child(headlight)

		var taillight := MeshInstance3D.new()
		var tail_mesh := BoxMesh.new()
		tail_mesh.size = Vector3(0.42, 0.12, 0.06)
		taillight.mesh = tail_mesh
		var tail_material := StandardMaterial3D.new()
		tail_material.albedo_color = Color(0.85, 0.025, 0.018)
		tail_material.emission_enabled = true
		tail_material.emission = Color(0.75, 0.015, 0.008)
		taillight.material_override = tail_material
		road_visual_parts.append(taillight)
		taillight.position = Vector3(x, 0.35, 2.12)
		vehicle.add_child(taillight)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 1.0, 4.2)
	collision.shape = shape
	collision.position.y = 0.35
	vehicle.add_child(collision)
	add_child(vehicle)
	_create_jeep_visual()

func _create_jeep_visual() -> void:
	jeep_visual = Node3D.new()
	jeep_visual.name = "OffroadJeepVisual"
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(2.15, 0.82, 4.0)
	body.mesh = body_mesh
	jeep_paint_material = StandardMaterial3D.new()
	jeep_paint_material.albedo_color = Color(0.24, 0.32, 0.18)
	jeep_paint_material.metallic = 0.25
	jeep_paint_material.roughness = 0.62
	body.material_override = jeep_paint_material
	body.position.y = 0.48
	jeep_visual.add_child(body)

	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.72, 0.95, 1.95)
	cabin.mesh = cabin_mesh
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.025, 0.055, 0.07)
	glass.metallic = 0.2
	glass.roughness = 0.2
	cabin.material_override = glass
	cabin.position = Vector3(0.0, 1.32, -0.05)
	jeep_visual.add_child(cabin)

	var bumper := MeshInstance3D.new()
	var bumper_mesh := BoxMesh.new()
	bumper_mesh.size = Vector3(2.3, 0.22, 0.22)
	bumper.mesh = bumper_mesh
	bumper.position = Vector3(0.0, 0.22, -2.08)
	jeep_visual.add_child(bumper)

	var tire_mat := StandardMaterial3D.new()
	tire_mat.albedo_color = Color(0.015, 0.018, 0.02)
	tire_mat.roughness = 1.0
	for x in [-1.12, 1.12]:
		for z in [-1.35, 1.35]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.62
			wheel_mesh.bottom_radius = 0.62
			wheel_mesh.height = 0.42
			wheel.mesh = wheel_mesh
			wheel.material_override = tire_mat
			jeep_wheels.append(wheel)
			wheel.rotation.z = PI / 2.0
			wheel.position = Vector3(x, -0.05, z)
			jeep_visual.add_child(wheel)

	var spare := MeshInstance3D.new()
	var spare_mesh := CylinderMesh.new()
	spare_mesh.top_radius = 0.48
	spare_mesh.bottom_radius = 0.48
	spare_mesh.height = 0.24
	spare.mesh = spare_mesh
	spare.material_override = tire_mat
	spare.position = Vector3(0.0, 0.58, 2.08)
	jeep_visual.add_child(spare)
	jeep_visual.visible = false
	vehicle.add_child(jeep_visual)

func _set_vehicle_mode(offroad: bool) -> void:
	jeep_selected = offroad
	for part in road_visual_parts:
		part.visible = not offroad
	jeep_visual.visible = offroad
	if vehicle.has_method("set_offroad_mode"):
		vehicle.call("set_offroad_mode", offroad)

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
	var spin := float(vehicle.get("forward_speed")) * delta / (0.47 if not jeep_selected else 0.62)
	for wheel in road_wheels:
		wheel.rotate_object_local(Vector3.RIGHT, spin)
	for wheel in jeep_wheels:
		wheel.rotate_object_local(Vector3.RIGHT, spin)

	if garage_panel != null and garage_panel.visible:
		cockpit_camera.current = false
		follow_camera.current = true
		garage_camera_angle += delta * 0.28
		var preview_offset := Vector3(sin(garage_camera_angle) * 7.5, 3.0, cos(garage_camera_angle) * 7.5)
		var preview_target := vehicle.global_position + preview_offset
		follow_camera.global_position = follow_camera.global_position.lerp(preview_target, min(delta * 3.5, 1.0))
		follow_camera.look_at(vehicle.global_position + Vector3(0.0, 0.65, 0.0), Vector3.UP)
	elif use_cockpit:
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

	var reset_button := Button.new()
	reset_button.text = "RESET CAR"
	reset_button.custom_minimum_size = Vector2(140.0, 58.0)
	reset_button.pressed.connect(_reset_vehicle)
	top.add_child(reset_button)

	var garage_button := Button.new()
	garage_button.text = "GARAGE"
	garage_button.custom_minimum_size = Vector2(130.0, 58.0)
	garage_button.pressed.connect(_toggle_garage)
	top.add_child(garage_button)

	var challenge_button := Button.new()
	challenge_button.text = "HILL CLIMB"
	challenge_button.custom_minimum_size = Vector2(150.0, 58.0)
	challenge_button.pressed.connect(_start_hill_climb)
	top.add_child(challenge_button)

	var camera_button := Button.new()
	camera_button.text = "CAMERA"
	camera_button.custom_minimum_size = Vector2(140.0, 58.0)
	camera_button.pressed.connect(_toggle_camera)
	top.add_child(camera_button)

	challenge_label = Label.new()
	challenge_label.text = "OFF-ROAD CHALLENGE READY"
	challenge_label.position = Vector2(24.0, 132.0)
	challenge_label.add_theme_font_size_override("font_size", 20)
	challenge_label.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
	layer.add_child(challenge_label)

	_create_touch_controls(layer)
	_create_settings_panel(layer)
	_create_garage_panel(layer)

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
	quality.select(maxi(0, ["Low", "Medium", "High", "Ultra"].find(settings.quality)))
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
	fps.select(maxi(0, [30, 60, 90, 120, 144].find(settings.target_fps)))
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


func _create_garage_panel(layer: CanvasLayer) -> void:
	garage_panel = PanelContainer.new()
	garage_panel.visible = false
	garage_panel.set_anchors_preset(Control.PRESET_CENTER)
	garage_panel.offset_left = -220.0
	garage_panel.offset_right = 220.0
	garage_panel.offset_top = -205.0
	garage_panel.offset_bottom = 205.0
	layer.add_child(garage_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	garage_panel.add_child(layout)

	var heading := Label.new()
	heading.text = "EVEE GARAGE"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 26)
	layout.add_child(heading)

	var car_button := Button.new()
	car_button.text = "STREET CAR  •  ROAD SETUP"
	car_button.custom_minimum_size = Vector2(360.0, 64.0)
	car_button.pressed.connect(func(): _select_garage_vehicle(false))
	layout.add_child(car_button)

	var jeep_button := Button.new()
	jeep_button.text = "TRAIL JEEP  •  OFF-ROAD SETUP"
	jeep_button.custom_minimum_size = Vector2(360.0, 64.0)
	jeep_button.pressed.connect(func(): _select_garage_vehicle(true))
	layout.add_child(jeep_button)

	var paint_heading := Label.new()
	paint_heading.text = "PAINT COLOUR"
	paint_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(paint_heading)

	var paint_row := HBoxContainer.new()
	paint_row.alignment = BoxContainer.ALIGNMENT_CENTER
	for paint_name in ["PURPLE", "BLACK", "WHITE", "RED"]:
		var paint_button := Button.new()
		paint_button.text = paint_name
		paint_button.custom_minimum_size = Vector2(88.0, 52.0)
		paint_button.pressed.connect(_apply_vehicle_paint.bind(paint_name))
		paint_row.add_child(paint_button)
	layout.add_child(paint_row)

	var close_button := Button.new()
	close_button.text = "CLOSE GARAGE"
	close_button.pressed.connect(_toggle_garage)
	layout.add_child(close_button)

func _toggle_garage() -> void:
	garage_panel.visible = not garage_panel.visible
	if garage_panel.visible:
		settings_panel.visible = false
		garage_camera_angle = 0.0
	_update_vehicle_pause_state()

func _update_vehicle_pause_state() -> void:
	if is_instance_valid(vehicle):
		var ui_is_open := (is_instance_valid(garage_panel) and garage_panel.visible) or (is_instance_valid(settings_panel) and settings_panel.visible)
		vehicle.set_physics_process(not ui_is_open)

func _apply_vehicle_paint(paint_name: String) -> void:
	var paint_colors := {
		"PURPLE": Color(0.22, 0.08, 0.42),
		"BLACK": Color(0.025, 0.03, 0.04),
		"WHITE": Color(0.82, 0.85, 0.88),
		"RED": Color(0.62, 0.035, 0.025)
	}
	if not paint_colors.has(paint_name):
		return
	selected_paint_color = paint_name
	street_paint_material.albedo_color = paint_colors[paint_name]
	jeep_paint_material.albedo_color = paint_colors[paint_name]

func _select_garage_vehicle(offroad: bool) -> void:
	_set_vehicle_mode(offroad)
	garage_panel.visible = false
	_update_vehicle_pause_state()
	if is_instance_valid(challenge_label):
		challenge_label.text = "TRAIL JEEP SELECTED" if offroad else "STREET CAR SELECTED"

func _reset_vehicle() -> void:
	if is_instance_valid(vehicle) and vehicle.has_method("_reset_vehicle"):
		vehicle.call("_reset_vehicle")

func _toggle_vehicle() -> void:
	_set_vehicle_mode(not jeep_selected)

func _start_hill_climb() -> void:
	_set_vehicle_mode(true)
	offroad_challenge.start_challenge()

func _on_challenge_progress(message: String) -> void:
	if is_instance_valid(challenge_label):
		challenge_label.text = message

func _toggle_camera() -> void:
	use_cockpit = not use_cockpit

func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
	if settings_panel.visible:
		garage_panel.visible = false
	_update_vehicle_pause_state()
