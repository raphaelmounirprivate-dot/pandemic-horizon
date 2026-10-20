extends RefCounted
## Guided tutorial session: the player's game, choices and save store are set aside on
## entry and restored unchanged on exit; training uses its own save directory.
const World = preload("res://scripts/simulation/world.gd")
const SaveStore = preload("res://scripts/persistence/save_store.gd")
const Tutorial = preload("res://scripts/ui/tutorial.gd")

static func start(ui) -> void:
	if ui.tutorial != null: return
	ui.tutorial_session = {"world": ui.world, "selected": ui.selected, "speed": ui.speed, "save_store": ui.save_store,
		"save_notice": ui.save_notice, "saves_return": ui.saves_return, "screen": ui.screen,
		"start_id": ui.start_id, "scenario_id": ui.scenario_id, "difficulty_id": ui.difficulty_id, "objective_id":ui.objective_id,"decision_enabled":ui.decision_enabled}
	ui.world = World.new()
	var error = ui.world.start_with({"start": "boreale"})
	if not error.is_empty():
		ui.world = ui.tutorial_session.world
		ui.tutorial_session.clear()
		ui.save_notice = error
		ui.show_menu()
		return
	ui.tutorial = Tutorial.new()
	ui.save_store = SaveStore.new()
	ui.save_store.directory = ui.training_directory
	# Only the fixed training files are recycled; player slots are never touched.
	for slot in SaveStore.SLOTS:
		for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
			var path = ui.save_store._path(slot) + suffix
			if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	ui.selected = 0
	ui.speed = 1
	ui.paused = true
	ui.elapsed = 0.0
	ui.save_notice = "Entraînement séparé · vos parties et sauvegardes sont conservées."
	ui.show_game()

## Puts the player's session back and returns the screen to show.
static func restore(ui) -> String:
	var session: Dictionary = ui.tutorial_session
	var target: String = session.screen
	ui.world = session.world
	ui.selected = session.selected
	ui.speed = session.speed
	ui.save_store = session.save_store
	ui.save_notice = session.save_notice
	ui.saves_return = session.saves_return
	ui.start_id = session.start_id
	ui.scenario_id = session.scenario_id
	ui.difficulty_id = session.difficulty_id
	ui.objective_id = session.objective_id
	ui.decision_enabled = session.decision_enabled
	ui.tutorial = null
	session.clear()
	ui.paused = true
	ui.elapsed = 0.0
	ui.screen = target
	return target
