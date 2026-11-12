extends Node3D
class_name EVEETraffic

var traffic_cars: Array[Node3D] = []
var traffic_speeds: Array[float] = []
var traffic_directions: Array[float] = []
var traffic_lanes: Array[float] = [-2.5, 2.5]

func _ready() -> void:
	for i in range(8):
		var lane_index := i % 2
		var sequence_index := floori(float(i) / 2.0)
		var direction := 1.0 if lane_index == 0 else -1.0
		var car := _make_car(i)
		car.position = Vector3(
			traffic_lanes[lane_index],
			0.65,
			-80.0 - float(sequence_index) * 140.0 if direction > 0.0 else 80.0 + float(sequence_index) * 140.0
		)
		car.rotation.y = PI if direction > 0.0 else 0.0
		add_child(car)
		traffic_cars.append(car)
		traffic_speeds.append(8.0 + float(i % 3) * 2.0)
		traffic_directions.append(direction)

func _process(delta: float) -> void:
	for i in range(traffic_cars.size()):
		var car := traffic_cars[i]
		var direction := traffic_directions[i]
		car.position.z += traffic_speeds[i] * direction * delta
		if direction > 0.0 and car.position.z > 610.0:
			car.position.z = -610.0 - float(i) * 12.0
		elif direction < 0.0 and car.position.z < -610.0:
			car.position.z = 610.0 + float(i) * 12.0

func _make_car(index: int) -> Node3D:
	var car := Node3D.new()
	car.name = "TrafficVehicle_%02d" % index
	var colors := [Color(0.72, 0.16, 0.12), Color(0.12, 0.28, 0.68), Color(0.68, 0.68, 0.64), Color(0.10, 0.12, 0.15)]
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.8, 0.55, 3.7)
	body.mesh = body_mesh
	var paint := StandardMaterial3D.new()
	paint.albedo_color = colors[index % colors.size()]
	paint.metallic = 0.45
	paint.roughness = 0.32
	body.material_override = paint
	body.position.y = 0.0
	car.add_child(body)
	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.45, 0.55, 1.65)
	cabin.mesh = cabin_mesh
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.025, 0.055, 0.08)
	glass.roughness = 0.18
	cabin.material_override = glass
	cabin.position = Vector3(0.0, 0.52, 0.05)
	car.add_child(cabin)
	return car
