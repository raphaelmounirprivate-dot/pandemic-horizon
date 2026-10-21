extends RefCounted
## Game time: pause, speed and fixed half-second days. Only the controller's clock
## state changes here; every rule change goes through world.step().
const World = preload("res://scripts/simulation/world.gd")
const DAY_SECONDS = 0.5
const MAX_STEPS_PER_FRAME = 16

static func toggle_pause(ui) -> void:
	if ui.tutorial != null and not ui.tutorial.can_run(): return
	ui.paused = not ui.paused
	ui.elapsed = 0.0
	ui._refresh()

static func set_speed(ui, value: int) -> void:
	ui.speed = value
	ui._refresh()

static func advance(ui, delta: float) -> void:
	if ui.tutorial != null and not ui.tutorial.can_run(): return
	if ui.screen != "game" or ui.paused or not ui.world.outcome.is_empty():
		return
	ui.elapsed += delta * ui.speed
	# Bound work per frame while preserving the accumulated time.
	var steps = 0
	while ui.elapsed >= DAY_SECONDS and steps < MAX_STEPS_PER_FRAME:
		ui.elapsed -= DAY_SECONDS
		var detected_before = ui.world.detected_count()
		ui.world.step()
		if ui.world.detected_count() > detected_before: ui.feedback.play_cue("alert")
		if ui.world.day % 10 == 0 or not ui.world.outcome.is_empty(): ui.autosave()
		steps += 1
		if ui.tutorial != null and ui.tutorial.after_step(ui.world):
			ui.paused = true
			ui.elapsed = 0.0
			break
		if not ui.world.outcome.is_empty():
			ui.paused = true
			ui.feedback.play_cue("outcome")
			ui.show_result()
			return
		if (World.Decisions.pending(ui.world) and ui.world.day == World.Decisions.definition().start_day) or (World.Tactics.pending(ui.world) and ui.world.tactics.response.opened == ui.world.day):
			ui.show_decision()
			return
	ui._refresh()
