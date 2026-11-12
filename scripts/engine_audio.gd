extends Node
class_name EVEEEngineAudio

var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var stream: AudioStreamGenerator
var phase := 0.0
var engine_load := 0.0
var sample_rate := 22050.0

func _ready() -> void:
	player = AudioStreamPlayer.new()
	stream = AudioStreamGenerator.new()
	stream.mix_rate = int(sample_rate)
	stream.buffer_length = 0.18
	player.stream = stream
	player.volume_db = -12.0
	add_child(player)
	player.play()
	playback = player.get_stream_playback() as AudioStreamGeneratorPlayback

func set_load(value: float) -> void:
	engine_load = clampf(value, 0.0, 1.0)

func _process(_delta: float) -> void:
	if playback == null:
		return
	var frames := playback.get_frames_available()
	var base_frequency := lerpf(48.0, 115.0, engine_load)
	for i in range(mini(frames, 1024)):
		var fundamental := sin(phase)
		var second_harmonic := sin(phase * 2.0) * 0.34
		var third_harmonic := sin(phase * 3.0) * 0.13
		var sample := (fundamental + second_harmonic + third_harmonic) * 0.10
		playback.push_frame(Vector2(sample, sample))
		phase += TAU * base_frequency / sample_rate
		if phase > TAU:
			phase = fmod(phase, TAU)
