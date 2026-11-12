extends Node3D

const VehicleController = preload("res://scripts/vehicle_controller.gd")

var vehicle: CharacterBody3D
var follow_camera: Camera3D
var cockpit_camera: Camera3D
var use_cockpit := false

func _ready() -> void:
	_create_world()
	_create_vehicle()
	_create_cameras()
	_create_hud()

func _create_world() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.68, 0.78)
	environment.ambient_light_energy = 0.8
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.shadow_enabled = true
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

	# Simple test-road strip for the first driving milestone.
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

func _process(delta: float) -> void:
	if not is_instance_valid(vehicle):
		return
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
	add_child(layer)
	var panel := HBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -100.0
	panel.offset_bottom = -20.0
	panel.offset_left = 20.0
	panel.offset_right = -20.0
	panel.alignment = BoxContainer.ALIGNMENT_END
	layer.add_child(panel)

	var camera_button := Button.new()
	camera_button.text = "CAMERA"
	camera_button.custom_minimum_size = Vector2(150.0, 64.0)
	camera_button.pressed.connect(_toggle_camera)
	panel.add_child(camera_button)

	var hint := Label.new()
	hint.text = "WASD / Arrow keys to drive • Space for handbrake"
	hint.position = Vector2(24.0, 24.0)
	layer.add_child(hint)

func _toggle_camera() -> void:
	use_cockpit = not use_cockpit
