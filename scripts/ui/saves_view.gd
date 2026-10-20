extends RefCounted
const SaveStore = preload("res://scripts/persistence/save_store.gd")
static func build(ui) -> void:
	ui.paused = true
	ui.elapsed = 0.0
	ui.screen = "saves"
	ui._reset_screen("Sauvegardes d'entraînement" if ui.tutorial != null else "Sauvegardes", "Fichiers d'essai séparés : aucune sauvegarde du joueur n'est modifiée." if ui.tutorial != null else "Sauvegardes 0.12 · Parties 0.7 à 0.11 compatibles · Tarif 0.11 conservé.")
	ui.body.add_child(ui._label("Enregistrez dans un emplacement manuel, puis chargez-le pour terminer l'exercice." if ui.tutorial != null else "Le chargement remplace la partie en mémoire et reprend en pause.\nL'automatique est actualisée tous les 10 jours, au menu et à la fermeture.", 18, ui.MUTED))
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	ui.body.add_child(scroll)
	var rows = VBoxContainer.new()
	var training_action: Button
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 20)
	scroll.add_child(rows)
	for slot in SaveStore.SLOTS:
		var result = ui.save_store.load_slot(slot)
		var group = VBoxContainer.new()
		rows.add_child(group)
		var name_text = "Automatique" if slot == "auto" else "Emplacement " + slot.trim_prefix("slot")
		var summary = result.error
		if result.error.is_empty():
			summary = "%s · %s · Jour %d · %s" % [result.world.scenario.name, result.world.difficulty.name, result.world.day, result.saved_at.replace("T", " à ")]
			if result.get("backup", false): summary += " · Copie de secours"
			elif result.has("warning"): summary += " · Ancienne partie compatible"
		var label = ui._label(name_text + " — " + summary, 18)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		group.add_child(label)
		var actions = HBoxContainer.new()
		group.add_child(actions)
		if slot != "auto":
			var save_button = ui._button("Enregistrer ici", func():
				if FileAccess.file_exists(ui.save_store._path(slot)) or FileAccess.file_exists(ui.save_store._path(slot) + ".bak"):
					ui.confirm_action("Remplacer " + name_text.to_lower() + " par la partie en mémoire ?", func(): ui.save_manual(slot))
				else: ui.save_manual(slot)
			, actions)
			save_button.disabled = ui.world.regions.is_empty()
			if ui.tutorial != null and ui.tutorial.saved_slot.is_empty() and training_action == null: training_action = save_button
		var load_button = ui._button("Charger", func():
			if not ui.world.regions.is_empty():
				ui.confirm_action("Charger " + name_text.to_lower() + " et remplacer la partie en mémoire ?", func(): ui.load_saved(slot))
			else: ui.load_saved(slot)
		, actions)
		load_button.disabled = not result.error.is_empty()
		if ui.tutorial != null and ui.tutorial.saved_slot == slot: training_action = load_button
	var notice = ui._label(ui.save_notice if not ui.save_notice.is_empty() else "Une copie de la sauvegarde précédente est conservée après chaque remplacement.", 16, ui.AMBER)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.body.add_child(notice)
	ui._button("Retour", ui.close_saves, ui.body).grab_focus()
	if training_action != null: training_action.grab_focus()

static func save_manual(ui, slot: String) -> void:
	var error = ui.save_store.save_slot(slot, ui.world, ui.selected, ui.speed)
	if error.is_empty() and ui.tutorial != null and ui.tutorial.stage == 5: ui.tutorial.saved_slot = slot
	ui.save_notice = "Partie enregistrée dans l'emplacement %s." % slot.trim_prefix("slot") if error.is_empty() else error
	build(ui)

## Replaces the game in memory only after a complete, valid read; the game resumes paused.
static func load_slot(ui, slot: String) -> void:
	var result = ui.save_store.load_slot(slot)
	if not result.error.is_empty():
		ui.save_notice = result.error + " La partie en mémoire est conservée."
		build(ui)
		return
	var world = result.world
	ui.world = world
	ui.reset_map_camera = true
	if ui.tutorial != null and ui.tutorial.stage == 5 and ui.tutorial.saved_slot == slot: ui.tutorial.ready = true
	ui.selected = result.selected
	ui.speed = result.speed
	ui.start_id = world.start_region_id
	ui.scenario_id = world.scenario.id
	ui.difficulty_id = world.difficulty.id
	# The tutorial keeps the player's menu choices aside; only a real game updates them.
	if ui.tutorial == null:
		ui.objective_id = world.objective.get("id", "")
		ui.decision_enabled = not world.decision.is_empty()
		ui.advanced_mode = world.expanded_content
		ui.crises_mode = world.crises_enabled
		ui.reactive_mode = world.tactics_enabled
		ui.simulation_seed = world.rng.seed
	ui.paused = true
	ui.elapsed = 0.0
	ui.save_notice = result.get("warning", "Partie chargée en pause.")
	if world.outcome.is_empty(): ui.show_game()
	else: ui.show_result()
