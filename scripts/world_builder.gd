extends RefCounted
class_name EVEEWorldBuilder

static func build(parent: Node3D) -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.64, 0.72, 0.84)
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.28
	env_node.environment = env
	parent.add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 90.0
	parent.add_child(sun)

	var ground := StaticBody3D.new()
	ground.name = "WorldGround"
	var ground_mesh := MeshInstance3D.new()
	var ground_plane := PlaneMesh.new()
	ground_plane.size = Vector2(1800.0, 1800.0)
	ground_mesh.mesh = ground_plane
	ground_mesh.material_override = _material(Color(0.13, 0.20, 0.16), 0.98)
	ground.add_child(ground_mesh)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(1800.0, 0.3, 1800.0)
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.15
	ground.add_child(ground_collision)
	parent.add_child(ground)

	var road_body := StaticBody3D.new()
	road_body.name = "MainRoad"
	var road_mesh := MeshInstance3D.new()
	var road_box := BoxMesh.new()
	road_box.size = Vector3(13.0, 0.12, 1200.0)
	road_mesh.mesh = road_box
	road_mesh.position.y = 0.03
	road_mesh.material_override = _material(Color(0.065, 0.075, 0.09), 0.94)
	road_body.add_child(road_mesh)
	var road_collision := CollisionShape3D.new()
	var road_shape := BoxShape3D.new()
	road_shape.size = Vector3(13.0, 0.3, 1200.0)
	road_collision.shape = road_shape
	road_collision.position.y = -0.05
	road_body.add_child(road_collision)
	parent.add_child(road_body)

	_add_road_markings(parent)
	_add_city_blocks(parent)
	_add_trees(parent)
	_add_street_lights(parent)

static func _material(color: Color, roughness: float = 0.8, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

static func _add_road_markings(parent: Node3D) -> void:
	var white := _material(Color(0.86, 0.87, 0.82), 0.9)
	var yellow := _material(Color(0.95, 0.68, 0.12), 0.85)
	for z in range(-590, 600, 12):
		var dash := MeshInstance3D.new()
		var dash_mesh := BoxMesh.new()
		dash_mesh.size = Vector3(0.16, 0.025, 5.5)
		dash.mesh = dash_mesh
		dash.position = Vector3(0.0, 0.105, float(z))
		dash.material_override = yellow
		parent.add_child(dash)
	for side in [-1.0, 1.0]:
		var edge := MeshInstance3D.new()
		var edge_mesh := BoxMesh.new()
		edge_mesh.size = Vector3(0.12, 0.025, 1200.0)
		edge.mesh = edge_mesh
		edge.position = Vector3(side * 5.95, 0.105, 0.0)
		edge.material_override = white
		parent.add_child(edge)

static func _add_city_blocks(parent: Node3D) -> void:
	var palette := [
		Color(0.34, 0.39, 0.46), Color(0.48, 0.43, 0.37),
		Color(0.28, 0.34, 0.39), Color(0.52, 0.53, 0.50)
	]
	for side in [-1.0, 1.0]:
		for i in range(18):
			var z := -520.0 + float(i) * 62.0
			var width := 13.0 + float((i * 7) % 8)
			var height := 12.0 + float((i * 13) % 34)
			var depth := 22.0 + float((i * 5) % 15)
			var building := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(width, height, depth)
			building.mesh = box
			building.position = Vector3(side * (18.0 + width * 0.5), height * 0.5, z)
			building.material_override = _material(palette[i % palette.size()], 0.72, 0.08)
			parent.add_child(building)

			var roof := MeshInstance3D.new()
			var roof_box := BoxMesh.new()
			roof_box.size = Vector3(width + 0.6, 0.45, depth + 0.6)
			roof.mesh = roof_box
			roof.position = building.position + Vector3(0.0, height * 0.5 + 0.2, 0.0)
			roof.material_override = _material(Color(0.12, 0.14, 0.18), 0.8)
			parent.add_child(roof)

static func _add_trees(parent: Node3D) -> void:
	var trunk_mat := _material(Color(0.25, 0.15, 0.09), 0.95)
	var leaf_mat := _material(Color(0.10, 0.28, 0.16), 0.9)
	for side in [-1.0, 1.0]:
		for i in range(30):
			var z := -570.0 + float(i) * 38.0
			var x := side * (10.5 + float((i % 3) * 1.5))
			var trunk := MeshInstance3D.new()
			var trunk_mesh := CylinderMesh.new()
			trunk_mesh.top_radius = 0.22
			trunk_mesh.bottom_radius = 0.34
			trunk_mesh.height = 3.0
			trunk.mesh = trunk_mesh
			trunk.position = Vector3(x, 1.5, z)
			trunk.material_override = trunk_mat
			parent.add_child(trunk)
			var crown := MeshInstance3D.new()
			var crown_mesh := SphereMesh.new()
			crown_mesh.radius = 1.7
			crown_mesh.height = 3.4
			crown.mesh = crown_mesh
			crown.position = Vector3(x, 3.8, z)
			crown.material_override = leaf_mat
			parent.add_child(crown)

static func _add_street_lights(parent: Node3D) -> void:
	var pole_mat := _material(Color(0.17, 0.19, 0.22), 0.55, 0.65)
	for side in [-1.0, 1.0]:
		for z in range(-540, 560, 90):
			var pole := MeshInstance3D.new()
			var pole_mesh := CylinderMesh.new()
			pole_mesh.top_radius = 0.07
			pole_mesh.bottom_radius = 0.11
			pole_mesh.height = 7.0
			pole.mesh = pole_mesh
			pole.position = Vector3(side * 8.2, 3.5, float(z))
			pole.material_override = pole_mat
			parent.add_child(pole)
			var arm := MeshInstance3D.new()
			var arm_mesh := BoxMesh.new()
			arm_mesh.size = Vector3(1.7, 0.09, 0.12)
			arm.mesh = arm_mesh
			arm.position = Vector3(side * 7.45, 6.8, float(z))
			arm.material_override = pole_mat
			parent.add_child(arm)
