extends RefCounted
## End-of-game summary: outcome banner, four result cards, the game curve and key moments
## read from the journal (observation only). The full journal stays in Monde [F3].
const StatCard = preload("res://scripts/ui/stat_card.gd")
const Chart = preload("res://scripts/ui/history_chart.gd")
const MAX_MOMENTS = 10
const MAX_PURCHASES = 6

static func build(ui) -> void:
	ui.screen = "result"
	ui.paused = true
	var world = ui.world
	var victory = world.outcome == "victory"
	ui._reset_screen("Victoire" if victory else "Défaite", "%s · %s · Graine %d" % [world.scenario.name, world.difficulty.name, world.rng.seed])
	ui.body.add_child(banner(ui, victory))
	var cards = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 16)
	ui.body.add_child(cards)
	ui.result_cards.clear()
	var day_card = StatCard.new()
	day_card.show_stat("Fin de partie", "Jour %d" % world.day, "%s · %s" % [world.scenario.name, world.difficulty.name])
	var touched_card = StatCard.new()
	touched_card.show_stat("Population touchée", "%.1f %%" % (world.coverage() * 100), "Objectif : 90 % (repère blanc)")
	touched_card.show_meter(world.coverage(), Color("ff766d"), 0.9)
	var cure_card = StatCard.new()
	cure_card.show_stat("Remède", "%.1f %%" % world.cure, "Défaite s'il atteint 100 %")
	cure_card.show_meter(world.cure / 100.0, Color("69d6bd"))
	var score_card = StatCard.new()
	score_card.show_stat("Score", "%d" % world.score(), "max(0, couverture × 10 000 − jours × 10) ×%.2f" % float(world.difficulty.get("score_multiplier", 1.0)))
	for item in [["day", day_card], ["touched", touched_card], ["cure", cure_card], ["score", score_card]]:
		cards.add_child(item[1])
		ui.result_cards[item[0]] = item[1]
	var extra: Array[String] = []
	if world.tactics_enabled and not world.tactics.goal.is_empty(): extra.append(ui.World.Tactics.goal_summary(world))
	if not world.objective.is_empty(): extra.append("Objectif facultatif · " + ui.World.Objectives.summary(world))
	if not world.decision.is_empty(): extra.append(ui.World.Decisions.summary(world))
	if not extra.is_empty():
		var goals = ui._label("\n".join(extra), 15, ui.MUTED)
		goals.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ui.body.add_child(goals)
	var middle = HBoxContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_theme_constant_override("separation", 24)
	ui.body.add_child(middle)
	var chart_column = VBoxContainer.new()
	chart_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.add_child(chart_column)
	chart_column.add_child(ui._label("COURBE DE LA PARTIE", 15, ui.MUTED))
	var chart = Chart.new()
	chart.world = world
	chart.target_line = true
	chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chart.custom_minimum_size.y = 150
	chart_column.add_child(chart)
	ui.history_chart = chart
	var moments_column = VBoxContainer.new()
	moments_column.custom_minimum_size.x = 440 if ui.get_viewport_rect().size.x < 1600 else 560
	moments_column.add_theme_constant_override("separation", 2)
	middle.add_child(moments_column)
	moments_column.add_child(ui._label("MOMENTS CLÉS", 15, ui.MUTED))
	ui.result_moments = ui._label("\n".join(key_moments(world)), 20 if ui.reading_large else 15)
	ui.result_moments.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.result_moments.clip_text = true
	ui.result_moments.size_flags_vertical = Control.SIZE_EXPAND_FILL
	moments_column.add_child(ui.result_moments)
	moments_column.add_child(ui._label("Journal complet : Monde [F3]", 14, ui.MUTED))
	var actions = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	ui.body.add_child(actions)
	var restart = ui._button("Rejouer avec les mêmes choix", ui.restart_game, actions)
	restart.custom_minimum_size.y = 56
	restart.add_theme_font_size_override("font_size", 20)
	ui._button("Nouvelle partie", func(): ui.show_new_game(1), actions)
	ui._button("Monde [F3]", ui.open_overview, actions)
	ui._button("Sauvegardes", ui.open_saves, actions)
	ui._button("Menu", ui.show_menu, actions)
	ui._button("Aide [F1]", ui.open_help, actions)
	restart.grab_focus()

## Outcome stated in words and with a drawn symbol, not by colour alone.
static func banner(ui, victory: bool) -> Control:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var mark = Control.new()
	mark.custom_minimum_size = Vector2(36, 36)
	var color = Color("69d6bd") if victory else Color("ff766d")
	mark.draw.connect(func():
		mark.draw_arc(Vector2(18, 18), 16, 0, TAU, 32, color, 3, true)
		if victory: mark.draw_polyline(PackedVector2Array([Vector2(10, 18), Vector2(16, 24), Vector2(27, 11)]), color, 3, true)
		else:
			mark.draw_line(Vector2(11, 11), Vector2(25, 25), color, 3, true)
			mark.draw_line(Vector2(25, 11), Vector2(11, 25), color, 3, true))
	row.add_child(mark)
	var text = "Victoire : NACRE a touché 90 % de la population avant le remède." if victory else ("Défaite · " + ui.world.outcome_text().trim_prefix("Défaite : "))
	var label = ui._label(text, 20, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	return row

## Turning points of the game, in journal order, at most MAX_MOMENTS lines.
static func key_moments(world: RefCounted) -> Array[String]:
	var lines: Array[String] = []
	var purchases = 0
	var detections = 0
	var reached: Array = []
	var objective_name = world.Objectives.definition(world.objective.id).get("name", "") if not world.objective.is_empty() else ""
	for entry in world.journal.slice(0, world.journal.size() - 1):
		var day = entry.get_slice(" · ", 0)
		var text = entry.substr(day.length() + 3) if " · " in entry else entry
		if day == "Jour 0": continue
		var keep = false
		if text.begins_with("Évolution acquise"):
			purchases += 1
			keep = purchases <= MAX_PURCHASES
		elif text.begins_with("Détection dans la région"):
			detections += 1
			keep = detections == 1
		elif text.begins_with("Premiers cas dans la région"):
			# A region can fall back to zero active cases and be reached again: count it once.
			var region = text.trim_prefix("Premiers cas dans la région ").trim_suffix(".")
			keep = reached.is_empty()
			if region not in reached: reached.append(region)
		else:
			keep = text.begins_with("Phase ") or text.begins_with("Décision :") or text.begins_with("Crise :") or text.begins_with("Double relais") or (not objective_name.is_empty() and text.begins_with(objective_name))
		if keep:
			var short = text.split(" ; ")[0].split(". ")[0].trim_suffix(".")
			if short.begins_with("Phase "): short = short.split(" · ")[0]
			lines.append("%s · %s" % [day.replace("Jour ", "J"), short])
	var totals: Array[String] = []
	if purchases > MAX_PURCHASES: totals.append("%d compétences achetées au total" % purchases)
	if detections > 1: totals.append("%d régions détectées" % detections)
	if reached.size() > 1:
		var origin = world.region_name(world.start_region_id)
		if origin not in reached: reached.append(origin)
		totals.append("%d régions atteintes sur %d" % [reached.size(), world.regions.size()])
	var room = MAX_MOMENTS - 1 - (1 if not totals.is_empty() else 0)
	if lines.size() > room: lines = lines.slice(0, room)
	if not totals.is_empty(): lines.append(" · ".join(totals))
	if not world.journal.is_empty(): lines.append(world.journal[-1].replace("Jour ", "J"))
	return lines
