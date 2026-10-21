extends Node
# Original synthetic cues. No sampled or third-party audio, no simulation RNG.
var enabled = false
var volume = 0.35
var ambient: AudioStreamPlayer
var player: AudioStreamPlayer
var last_cue = -1000
var cues: Dictionary = {}
func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	for cue in ["purchase","alert","outcome","decision"]:
		var stream = AudioStreamWAV.new()
		stream.format = AudioStreamWAV.FORMAT_8_BITS
		stream.mix_rate = 22050
		var data = PackedByteArray()
		data.resize(3308)
		var frequency = {"purchase":660.0,"alert":440.0,"outcome":550.0,"decision":330.0}[cue]
		for i in range(data.size()):
			var progress = float(i)/data.size()
			var envelope = sin(PI*progress)*0.22
			data[i] = int(128+127*envelope*(sin(TAU*frequency*i/22050.0) * 0.75 + sin(TAU*(frequency*1.5)*i/22050.0) * 0.25))
		stream.data = data
		cues[cue] = stream
	ambient = AudioStreamPlayer.new()
	add_child(ambient)
	var bed = AudioStreamWAV.new()
	bed.format = AudioStreamWAV.FORMAT_8_BITS
	bed.mix_rate = 22050
	bed.loop_mode = AudioStreamWAV.LOOP_FORWARD
	var samples = PackedByteArray()
	samples.resize(22050 * 4)
	for i in range(samples.size()):
		var seconds = float(i) / 22050.0
		var wave = (sin(TAU * 110.0 * seconds) + 0.5 * sin(TAU * 165.0 * seconds)) * (0.75 + 0.25 * cos(TAU * seconds / 4.0))
		samples[i] = int(128 + 127 * 0.08 * wave)
	bed.data = samples
	bed.loop_end = samples.size()
	ambient.stream = bed
func play_cue(cue: String) -> void:
	if not enabled or volume <= 0 or not cues.has(cue) or Time.get_ticks_msec()-last_cue < 200: return
	last_cue = Time.get_ticks_msec()
	player.volume_db = linear_to_db(clampf(volume,0.001,1.0))
	player.stream = cues[cue]
	player.play()
func set_ambience(active: bool, tension: float) -> void:
	if not is_instance_valid(ambient): return
	if not enabled or volume <= 0 or not active:
		ambient.stop()
		return
	ambient.volume_db = linear_to_db(maxf(0.001, volume * 0.25))
	ambient.pitch_scale = 1.0 + clampf(tension, 0.0, 1.0) * 0.12
	if not ambient.playing: ambient.play()

func configure(active: bool, level: float) -> void:
	enabled = active
	volume = clampf(level,0,1)
	if is_instance_valid(ambient) and (not enabled or volume == 0): ambient.stop()
	if is_instance_valid(player) and (not enabled or volume == 0): player.stop()
