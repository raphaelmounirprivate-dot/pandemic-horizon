extends RefCounted
## Export smoke test (--smoke-test): drives the real controller with the exported resources.
const World = preload("res://scripts/simulation/world.gd")
const SaveStore = preload("res://scripts/persistence/save_store.gd")
const Incidents = preload("res://scripts/ui/incident_view.gd")
static func run(ui) -> bool:
	# Exercise the actual exported resources; no dependency on the tests folder.
	ui.start_game()
	if ui.screen != "game" or ui.world.totals().active != 200 or ui.world.regions.size() != 24 or ui.map_view.buttons.size() != 24:
		return false
	if ui.world.route_mode(["boreale", "centrale"]) != "sea" or not is_equal_approx(ui.world.transport_factor(["centrale", "meridien"]), 1.2):
		return false
	ui.world.points = 100
	if ui.world.purchase("mobility").is_empty():
		return false
	ui.buy_evolution("transmission")
	ui.buy_evolution("mobility")
	ui.buy_evolution("discretion")
	ui.toggle_pause()
	for target_day in [23, 26, 32, 44]:
		while ui.world.day < target_day and ui.screen == "game":
			ui.advance_time(0.5)
		var closed = not ui.world.route_is_open(["boreale", "centrale"])
		if ui.screen != "game" or closed != (target_day in [23, 26]):
			return false
	if not ui.world.active_events.any(func(e): return e.id == "research_boost") or ui.world.detected_count() == 0:
		return false
	if not is_equal_approx(ui.world.transport_factor(["centrale", "meridien"]), 0.72):
		return false
	for i in range(500):
		ui.advance_time(0.5)
	if ui.screen != "result" or ui.world.outcome != "victory":
		return false
	ui.start_game()
	ui.toggle_pause()
	for i in range(500):
		ui.advance_time(0.5)
	if ui.screen != "result" or ui.world.outcome != "defeat_cure":
		return false
	ui.scenario_id = "degel2042"
	ui.difficulty_id = "normal"
	ui.start_id = "boreale"
	ui.start_game()
	if ui.world.phase.id != "isolation" or ui.world.evolutions.size() != 9 or ui.world.route_is_open(["boreale", "orient"]):
		return false
	ui.toggle_pause()
	for target_day in [12, 28, 36, 39, 55]:
		while ui.world.day < target_day and ui.screen == "game":
			ui.advance_time(0.5)
		var expected_closed = target_day in [28, 36]
		if ui.screen != "game" or (not ui.world.route_is_open(["boreale", "centrale"])) != expected_closed:
			return false
	if ui.world.phase.id != "mobilization" or ui.world.phase.cure_multiplier != 1.35:
		return false
	ui.world.points = 100
	for id in ui.world.evolutions: ui.buy_evolution(id)
	if ui.world.purchased.size() != 7 or ui.world.specialization_id() != "land_network":
		return false
	ui.difficulty_id = "hard"
	ui.start_game()
	if ui.world.difficulty.cure_multiplier != 1.3:
		return false
	# Exercise persistence inside the standalone export, away from real player slots.
	var smoke_store = SaveStore.new()
	smoke_store.directory = "user://smoke-persistence"
	for slot in SaveStore.SLOTS:
		for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(smoke_store._path(slot) + suffix): DirAccess.remove_absolute(smoke_store._path(slot) + suffix)
	for i in range(33): ui.world.step()
	if not smoke_store.save_slot("slot1", ui.world).is_empty():
		return false
	var restored = smoke_store.load_slot("slot1")
	if not restored.error.is_empty():
		return false
	for i in range(20):
		ui.world.step()
		restored.world.step()
	if ui.world.regions != restored.world.regions or ui.world.cure != restored.world.cure or ui.world.rng.state != restored.world.rng.state:
		return false
	DirAccess.remove_absolute(smoke_store._path("slot1"))
	var player_world = ui.world
	ui.training_directory = "user://smoke-training"
	ui.start_tutorial()
	ui.toggle_pause()
	ui.advance_time(0.5)
	ui.next_lesson()
	ui.select_region(2)
	ui.next_lesson()
	ui.buy_evolution("transmission")
	ui.next_lesson()
	ui.select_region(0)
	ui.next_lesson()
	ui.toggle_pause()
	ui.advance_time(20)
	ui.toggle_pause()
	ui.advance_time(20)
	ui.next_lesson()
	ui.open_saves()
	ui.save_manual("slot1")
	ui.load_saved("slot1")
	if ui.tutorial == null or not ui.tutorial.ready or ui.world.day != 32:
		return false
	ui.next_lesson()
	if ui.tutorial != null or ui.world != player_world or not ui.paused:
		return false
	ui.open_help()
	if ui.screen != "help" or ui.help_text.text.is_empty():
		return false
	ui.close_help()
	ui.show_settings()
	ui.show_menu()
	if ui.screen != "menu":
		return false
	var optional_world = World.new()
	if not optional_world.start_with({"start": "boreale", "objective": "first_relays"}).is_empty():
		return false
	for i in range(60):
		for id in ["transmission", "mobility", "discretion"]:
			if id not in optional_world.purchased:
				optional_world.purchase(id)
				break
		optional_world.step()
	var optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if optional_world.objective.status != "completed" or optional_world.objective.resolved_day != 49 or not optional_loaded.error.is_empty() or optional_loaded.world.objective != optional_world.objective:
		return false
	optional_world.start_with({"start": "boreale", "objective": "first_relays"})
	for i in range(60): optional_world.step()
	if optional_world.objective.status != "failed" or optional_world.objective.resolved_day != 50:
		return false
	optional_world.start_with({"start": "boreale", "scenario": "degel2042", "objective": "arctic_relays"})
	for i in range(55):
		for id in ["transmission","mobility","discretion"]:
			if id not in optional_world.purchased:
				optional_world.purchase(id)
				break
		optional_world.step()
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if optional_world.objective.status != "completed" or not optional_loaded.error.is_empty() or optional_loaded.world.objective != optional_world.objective:
		return false
	optional_world.start_with({"start": "boreale", "scenario": "degel2042", "decision": true})
	for i in range(28): optional_world.step()
	if not World.Decisions.choose(optional_world,"support").is_empty():
		return false
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or optional_loaded.world.points != 20:
		return false
	for i in range(13): optional_loaded.world.step()
	if optional_loaded.world.decision.status != "expired":
		return false
	optional_world.start_with({"start": "boreale", "scenario": "degel2042", "decision": true})
	optional_world.decision_profile = "0.11"
	optional_world.decision_rules = World.Decisions.legacy_definition()
	for i in range(28): optional_world.step()
	if not World.Decisions.choose(optional_world,"support").is_empty() or optional_world.points != 17:
		return false
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or optional_loaded.world.decision_profile != "0.11" or World.Decisions.option("support",optional_loaded.world).cost != 6:
		return false
	if not optional_world.start_with({"start": "boreale", "scenario": "degel2042", "objective": "arctic_relays", "decision": true, "expanded": true}).is_empty():
		return false
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or not optional_loaded.world.expanded_content or optional_loaded.world.evolutions.size() != 21:
		return false
	ui.advanced_mode = true
	ui.scenario_id = "degel2042"
	ui.start_game()
	ui.reduced_motion = true
	ui.reading_large = true
	ui.paused = false
	ui.advance_time(0.5)
	if ui.world.day != 1 or ui.map_view.motion_enabled or ui.feedback.cues.size() != 4:
		return false
	ui.open_overview()
	ui.open_help()
	if ui.help_text.get_theme_font_size("normal_font_size") != 24:
		return false
	if not optional_world.start_with({"start": "centrale", "seed": 777, "scenario": "fragile2042", "expanded": true, "crises": true}).is_empty():
		return false
	for day in range(40): optional_world.step()
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or not optional_loaded.world.crises_enabled or optional_loaded.world.event_definitions != optional_world.event_definitions:
		return false
	ui.world = optional_loaded.world
	ui.show_game()
	if ui.incident_button == null or not "mondiaux" in ui.map_legend.text or not Incidents.entries(ui.world).all(func(e): return e.start_day <= ui.world.day):
		return false
	if not optional_world.start_with({"start": "centrale", "scenario": "fragile2042", "expanded": true, "crises": true, "reactive": true}).is_empty():
		return false
	for day in range(55):
		for id in ["transmission","mobility","discretion"]:
			if id not in optional_world.purchased:
				optional_world.purchase(id)
				break
		if World.Tactics.pending(optional_world): World.Tactics.choose(optional_world,"endure")
		optional_world.step()
	optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
	if not optional_loaded.error.is_empty() or not optional_loaded.world.tactics_enabled or optional_loaded.world.tactics != optional_world.tactics:
		return false
	ui.world = optional_loaded.world
	ui.show_game()
	if not "Double relais" in ui.objective_details.text:
		return false
	# Both strategy profiles must be packaged: frozen 0.25 (format 8) and current 0.26 (format 9).
	for profile in [World.Strategy.PROFILE, World.Strategy.CURRENT]:
		if not optional_world.start_with({"start": "boreale", "agent": "pulse", "strategy": profile}).is_empty():
			return false
		for day in range(24):
			if World.Strategy.pending(optional_world): World.Strategy.choose(optional_world, World.Strategy.choices(optional_world)[0].id)
			optional_world.step()
		optional_loaded = smoke_store.decode(smoke_store.encode(optional_world))
		if not optional_loaded.error.is_empty() or smoke_store.encode(optional_loaded.world).format != World.Strategy.FORMATS[profile] or optional_loaded.world.strategy != optional_world.strategy:
			return false
	ui.world = optional_loaded.world
	ui.show_game()
	if World.Strategy.compact_line(ui.world).is_empty() or World.Strategy.choices(ui.world).size() != 3:
		return false
	return true
