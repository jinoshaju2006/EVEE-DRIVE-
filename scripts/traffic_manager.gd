extends Node3D
class_name EVEETraffic

var traffic_cars: Array[Node3D] = []
var traffic_speeds: Array[float] = []
var traffic_directions: Array[float] = []
var traffic_lanes: Array[float] = [-2.5, 2.5]
var traffic_models: Array[PackedScene] = [
	preload("res://assets/vehicles/kenney/sedanSports.glb"),
	preload("res://assets/vehicles/kenney/race.glb"),
	preload("res://assets/vehicles/kenney/suv.glb"),
	preload("res://assets/vehicles/kenney/truck.glb"),
	preload("res://assets/vehicles/kenney/van.glb")
]

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
	var model_scene := traffic_models[index % traffic_models.size()]
	var model := model_scene.instantiate() as Node3D
	model.name = "LicensedTrafficModel"
	model.scale = Vector3(0.72, 0.72, 0.72)
	model.position.y = -0.38
	car.add_child(model)
	return car
