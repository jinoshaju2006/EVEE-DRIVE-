extends Node3D
class_name EVEEOffroadChallenge

signal progress_changed(message: String)

var checkpoint_positions: Array[Vector3] = [
	Vector3(25.0, 1.0, -16.0),
	Vector3(55.0, 1.0, -47.0),
	Vector3(105.0, 1.0, -34.0),
	Vector3(132.0, 1.0, 8.0),
	Vector3(91.0, 1.0, 43.0),
	Vector3(42.0, 1.0, 14.0)
]
var checkpoint_areas: Array[Area3D] = []
var checkpoint_gates: Array[Node3D] = []
var next_checkpoint := 0
var elapsed := 0.0
var challenge_active := false

func _ready() -> void:
	for i in range(checkpoint_positions.size()):
		_create_checkpoint(i)

func _process(delta: float) -> void:
	if challenge_active:
		elapsed += delta

func start_challenge() -> void:
	next_checkpoint = 0
	elapsed = 0.0
	challenge_active = true
	_update_gate_visibility()
	progress_changed.emit("HILL CLIMB  •  CHECKPOINT 1/%d" % checkpoint_positions.size())

func _create_checkpoint(index: int) -> void:
	var gate := Node3D.new()
	gate.name = "CheckpointGate_%02d" % index
	gate.position = checkpoint_positions[index]
	add_child(gate)
	checkpoint_gates.append(gate)

	var post_material := StandardMaterial3D.new()
	post_material.albedo_color = Color(0.12, 0.78, 0.92)
	post_material.emission_enabled = true
	post_material.emission = Color(0.04, 0.35, 0.5)

	for side in [-1.0, 1.0]:
		var post := MeshInstance3D.new()
		var post_mesh := CylinderMesh.new()
		post_mesh.top_radius = 0.16
		post_mesh.bottom_radius = 0.16
		post_mesh.height = 3.6
		post.mesh = post_mesh
		post.position = Vector3(side * 4.0, 1.8, 0.0)
		post.material_override = post_material
		gate.add_child(post)

	var bar := MeshInstance3D.new()
	var bar_mesh := BoxMesh.new()
	bar_mesh.size = Vector3(8.2, 0.18, 0.18)
	bar.mesh = bar_mesh
	bar.position = Vector3(0.0, 3.55, 0.0)
	bar.material_override = post_material
	gate.add_child(bar)

	var area := Area3D.new()
	area.name = "CheckpointTrigger_%02d" % index
	area.position = checkpoint_positions[index]
	var trigger := CollisionShape3D.new()
	var trigger_shape := BoxShape3D.new()
	trigger_shape.size = Vector3(9.0, 4.0, 3.0)
	trigger.shape = trigger_shape
	area.add_child(trigger)
	area.body_entered.connect(_on_checkpoint_body_entered.bind(index))
	add_child(area)
	checkpoint_areas.append(area)

func _on_checkpoint_body_entered(body: Node3D, index: int) -> void:
	if not challenge_active or body.name != "PlayerVehicle" or index != next_checkpoint:
		return
	next_checkpoint += 1
	if next_checkpoint >= checkpoint_positions.size():
		challenge_active = false
		progress_changed.emit("HILL CLIMB COMPLETE  •  %.1f SEC" % elapsed)
	else:
		_update_gate_visibility()
		progress_changed.emit("HILL CLIMB  •  CHECKPOINT %d/%d" % [next_checkpoint + 1, checkpoint_positions.size()])

func _update_gate_visibility() -> void:
	for i in range(checkpoint_gates.size()):
		checkpoint_gates[i].visible = i == next_checkpoint
