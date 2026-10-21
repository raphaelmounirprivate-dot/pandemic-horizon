extends RefCounted
## Game screen: map, sidebar, inline logistic choice or crisis response, status line and
## controls. refresh() only reads the model; it never advances or mutates the world.
const MapView = preload("res://scripts/ui/region_map.gd")
const Incidents = preload("res://scripts/ui/incident_view.gd")

static func build(ui) -> void:
	var world = ui.world
	var tutorial = ui.tutorial
	ui.screen = "game"
	ui._reset_screen("Tutoriel guidé" if tutorial != null else "Pandemic Horizon", "Entraînement séparé · Six exercices" if tutorial != null else "%s · %s · Objectif : 90 %% avant le remède" % [world.scenario.name,world.difficulty.name])
	var body: VBoxContainer = ui.body
	body.get_child(0).get_child(0).add_theme_font_size_override("font_size",22)
	ui.metrics = ui._label("",20,ui.ACCENT)
	body.add_child(ui.metrics)
	ui.objective_details = ui._label("",13,ui.MUTED)
	ui.objective_details.visible = not world.objective.is_empty() or (world.tactics_enabled and not world.tactics.goal.is_empty())
	body.add_child(ui.objective_details)
	var content = HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(content)
	var map_column = VBoxContainer.new()
	map_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(map_column)
	ui.map_view = MapView.new()
	ui.map_view.setup(world)
	ui.map_view.selected = ui.selected
	ui.map_view.region_selected.connect(ui.select_region)
	map_column.add_child(ui.map_view)
	ui.map_view.restore_camera(ui.map_camera)
	ui.reset_map_camera = false
	ui.map_legend = ui._label("",13,ui.MUTED)
	ui.map_legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_column.add_child(ui.map_legend)
	ui.decision_area = VBoxContainer.new()
	ui.decision_signature = ""
	map_column.add_child(ui.decision_area)
	build_decision(ui, ui.decision_area)
	ui.effects_label = RichTextLabel.new()
	ui.effects_label.custom_minimum_size.y = 48
	ui.effects_label.visible = not ui.World.Decisions.pending(world) and not ui.World.Tactics.pending(world) and not ui.World.Strategy.pending(world)
	ui.effects_label.add_theme_font_size_override("normal_font_size",13)
	ui.effects_label.add_theme_color_override("default_color",ui.AMBER)
	map_column.add_child(ui.effects_label)
	var sidebar = VBoxContainer.new()
	sidebar.custom_minimum_size.x = 380
	sidebar.add_theme_constant_override("separation",2)
	content.add_child(sidebar)
	ui.region_details = ui._label("",14)
	sidebar.add_child(ui.region_details)
	ui.transport_details = ui._label("",13,ui.MUTED)
	sidebar.add_child(ui.transport_details)
	ui.evolution_open_button = ui._button("", ui.open_evolution, sidebar)
	ui.evolution_open_button.custom_minimum_size.y = 64
	ui.evolution_open_button.add_theme_font_size_override("font_size",22)
	ui.evolution_summary = ui._label("",14,ui.MUTED)
	ui.evolution_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sidebar.add_child(ui.evolution_summary)
	ui.status_label = ui._label("",14,ui.MUTED)
	body.add_child(ui.status_label)
	ui.journal_label = ui._label("",14,ui.MUTED)
	ui.journal_label.custom_minimum_size.y = 22 if tutorial == null else 44
	if tutorial == null:
		ui.journal_label.mouse_filter = Control.MOUSE_FILTER_STOP
		ui.journal_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		ui.journal_label.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: ui.open_overview())
	body.add_child(ui.journal_label)
	var controls = HBoxContainer.new()
	body.add_child(controls)
	ui.pause_button = ui._button("", ui.toggle_pause, controls)
	var initial_focus: Button = ui.pause_button
	for value in [1, 2, 4]:
		ui._button("×%d" % value, func():
			ui.speed = value
			ui._refresh()
		, controls)
	if tutorial == null:
		ui._button("Recommencer", ui.restart_game, controls)
		ui._button("Menu", ui.show_menu, controls)
		ui._button("Sauvegardes", ui.open_saves, controls)
		ui._button("Monde [F3]",ui.open_overview,controls)
		ui.incident_button = ui._button("Local [F4]",func(): ui.map_view.focus_next_incident(),controls) if world.crises_enabled else null
	else:
		if tutorial.stage == 5: initial_focus = ui._button("Sauvegardes d'essai", ui.open_saves, controls)
		ui.tutorial_next = ui._button("Terminer" if tutorial.stage == 5 else "Continuer", ui.next_lesson, controls)
		ui._button("Quitter l'entraînement", ui.finish_tutorial, controls)
		if tutorial.stage == 1: initial_focus = ui.map_view.buttons[2]
		elif tutorial.stage == 2: initial_focus = ui.evolution_open_button
		elif tutorial.stage == 3: initial_focus = ui.map_view.buttons[0]
		if tutorial.ready: initial_focus = ui.tutorial_next
	ui._button("Aide [F1]", ui.open_help, controls)
	refresh(ui)
	initial_focus.grab_focus()

## Logistic decision (classic profile) or crisis response (reactive profile) under the map.
static func build_decision(ui, parent: Control) -> void:
	var world = ui.world
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	ui.decision_signature = decision_signature(world)
	ui.decision_buttons.clear()
	ui.decision_notice = null
	if not world.strategy.is_empty():
		load("res://scripts/ui/strategy_view.gd").build(ui, parent)
		return
	if ui.World.Tactics.pending(world) or (world.tactics_enabled and not world.tactics.response.is_empty() and not ui.World.Decisions.pending(world)):
		load("res://scripts/ui/crisis_response_view.gd").build(ui,parent)
		return
	if world.decision.is_empty(): return
	ui.decision_notice = ui._label("",13,ui.AMBER)
	ui.decision_notice.visible = false
	var title = ui.World.Decisions.summary(world)
	if world.decision_profile == "0.11": title += " · Tarif historique 6 pts"
	parent.add_child(ui._label(title,13,ui.AMBER))
	if ui.World.Decisions.pending(world):
		var choices = HBoxContainer.new()
		choices.add_theme_constant_override("separation",8)
		parent.add_child(choices)
		for choice in ui.World.Decisions.definition(world).choices:
			var id = choice.id
			var column = VBoxContainer.new()
			column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			choices.add_child(column)
			var button = ui._button("%s · %d pts" % [choice.name,choice.cost],func():
				var error = ui.World.Decisions.choose(ui.world,id)
				if error.is_empty():
					ui.feedback.play_cue("purchase")
					ui.autosave()
					ui.show_game()
				else:
					ui.decision_notice.text = error
					ui.decision_notice.show()
			,column)
			button.add_theme_font_size_override("font_size",13)
			ui.decision_buttons[id] = button
			var detail = ui._label(("Sans ajout d'effet" if id == "observe" else "Mer ×%.2f · remède ×%.2f\n12 jours dès demain" % [choice.sea,choice.cure])+"\n"+ui.World.Decisions.reason(world,id),13,ui.MUTED)
			detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			column.add_child(detail)
		parent.add_child(ui._label("Choix irréversible · Sans choix : maintien gratuit au J31 · Les fermetures restent prioritaires",12,ui.AMBER))
	parent.add_child(ui.decision_notice)

static func decision_signature(world) -> String:
	return JSON.stringify(world.decision)+JSON.stringify(world.tactics)+JSON.stringify(world.strategy)+str(world.points)+str(world.day if not world.strategy.is_empty() else 0)

static func refresh(ui) -> void:
	if ui.screen != "game":
		return
	var world = ui.world
	var tutorial = ui.tutorial
	if ui.decision_signature != decision_signature(world): build_decision(ui, ui.decision_area)
	ui.effects_label.visible = not ui.World.Decisions.pending(world) and not ui.World.Tactics.pending(world) and not ui.World.Strategy.pending(world)
	ui.metrics.text = "Jour %d     Touchés : %.1f %%     Remède : %.1f %%     Points : %d     Détectées : %d/%d" % [world.day, world.coverage() * 100, world.cure, world.points, world.detected_count(), world.regions.size()]
	ui.objective_details.text = ui.World.Tactics.goal_summary(world) if world.tactics_enabled and not world.tactics.goal.is_empty() else ui.World.Objectives.summary(world)
	var region = world.regions[ui.selected]
	ui.region_details.text = "%s · Population : %d\nSains : %d · Actifs : %d · Retirés : %d\n%s" % [region.name, region.population, region.healthy, region.active, region.removed, "Détectée" if region.detected else "Non détectée"]
	if world.scenario.id != "standard":
		ui.region_details.text += " · Climat local ×%.2f" % world.climate_factor(region.id)
	ui.transport_details.text = world.transport_summary(region.id)
	if not world.strategy.is_empty():
		ui.region_details.text += "\nAgent : croissance ×%.2f · réseau ×%.2f" % [world.Strategy.growth(world, region), world.Strategy.exchange(world, region)]
	var available = world.evolutions.keys().filter(func(id): return ui.purchase_reason_for(id).is_empty())
	ui.evolution_open_button.text = "Évolution [E] · %d pts" % world.points
	var owned: Array[String] = []
	for group in ui.EvolutionView.families(ui):
		owned.append("%s %d/%d" % [group.name, group.skills.filter(func(id): return id in world.purchased).size(), group.skills.size()])
	var specialization = world.specialization_id()
	ui.evolution_summary.text = "%s\n%s%s" % [" · ".join(owned), ("Aucune compétence achetable" if available.is_empty() else "%d achetable%s maintenant" % [available.size(), "s" if available.size() > 1 else ""]), "" if specialization.is_empty() else " · Spécialisation : " + world.evolutions[specialization].name]
	ui.pause_button.text = "Reprendre [Espace]" if ui.paused else "Pause [Espace]"
	ui.status_label.text = ("En pause" if ui.paused else "Simulation en cours") + " · Vitesse ×%d" % ui.speed
	if not ui.save_notice.is_empty(): ui.status_label.text += " · " + ui.save_notice
	if not world.strategy.is_empty(): ui.status_label.text += " · 1 jour = 6 s à ×1"
	ui.status_label.clip_text = true
	ui.journal_label.text = "Actu · " + world.journal[-1] if not world.journal.is_empty() else ""
	ui.journal_label.tooltip_text = "Actualités [F3]\n" + "\n".join(world.journal.slice(maxi(0,world.journal.size()-5)))
	ui.journal_label.clip_text = true
	if tutorial != null:
		ui.status_label.text = "Étape %d / 6 · %s · %s" % [tutorial.stage + 1, ui.Tutorial.TITLES[tutorial.stage], "Action réussie : continuez." if tutorial.ready else "À vous de jouer"]
		ui.journal_label.text = tutorial.instruction(world.day)
		ui.journal_label.clip_text = false
		ui.journal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var just_completed = tutorial.ready and ui.tutorial_next.disabled
		ui.tutorial_next.disabled = not tutorial.ready
		if just_completed: ui.tutorial_next.grab_focus()
		ui.pause_button.disabled = not tutorial.can_run()
	var counts = Incidents.counts(world)
	ui.map_legend.text = "Rouge : touchés · Véhicules : échanges du jour · 24 régions fictives"
	if world.crises_enabled:
		ui.map_legend.text = "Aléas locaux : %d · mondiaux : %d · F4 : localiser" % [counts.local,counts.global]
		ui.incident_button.disabled = counts.local == 0
		ui.incident_button.tooltip_text = "Localiser l'aléa local suivant : repère, région ou liaison. Les effets mondiaux restent dans Monde [F3]."
	var lines = Incidents.active_lines(world)
	var climate = "Phase %s · %.0f °C fictifs · Remède de phase ×%.2f\n" % [world.phase.name, world.phase.temperature, world.phase.cure_multiplier] if world.scenario.id != "standard" else ""
	ui.effects_label.text = climate + "Événements actifs\n" + ("Aucun effet temporaire." if lines.is_empty() else "\n".join(lines))
	ui.map_view.refresh()
	ui.map_view.motion_enabled = not ui.reduced_motion and not ui.paused and world.outcome.is_empty()
