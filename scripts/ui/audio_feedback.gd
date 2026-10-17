extends Node
# Original synthetic cues. No sampled or third-party audio, no simulation RNG.
var enabled = false
var volume = 0.35
var player: AudioStreamPlayer
var last_cue = -1000
var cues: Dictionary = {}
func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	for cue in ["purchase","alert","outcome"]:
		var stream = AudioStreamWAV.new()
		stream.format = AudioStreamWAV.FORMAT_8_BITS
		stream.mix_rate = 22050
		var data = PackedByteArray()
		data.resize(3308)
		var frequency = {"purchase":660.0,"alert":440.0,"outcome":550.0}[cue]
		for i in range(data.size()):
			var progress = float(i)/data.size()
			var envelope = sin(PI*progress)*0.22
			data[i] = int(128+127*envelope*sin(TAU*frequency*i/22050.0))
		stream.data = data
		cues[cue] = stream
func play_cue(cue: String) -> void:
	if not enabled or volume <= 0 or not cues.has(cue) or Time.get_ticks_msec()-last_cue < 200: return
	last_cue = Time.get_ticks_msec()
	player.volume_db = linear_to_db(clampf(volume,0.001,1.0))
	player.stream = cues[cue]
	player.play()
func configure(active: bool, level: float) -> void:
	enabled = active
	volume = clampf(level,0,1)
	if is_instance_valid(player) and (not enabled or volume == 0): player.stop()
