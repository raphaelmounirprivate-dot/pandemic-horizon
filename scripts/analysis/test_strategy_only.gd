extends SceneTree
var failures = 0
var checks = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: " + label)
func run() -> void:
	await load("res://tests/test_strategy.gd").new().run(self, check)
	# Let the audio server release stopped playback before tearing down the test process.
	await create_timer(0.1).timeout
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
