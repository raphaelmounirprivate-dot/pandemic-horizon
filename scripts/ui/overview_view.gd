extends RefCounted
static func build(ui) -> void:
	ui.screen = "overview"
	ui.paused = true
	ui.elapsed = 0.0
	ui._reset_screen("Monde · Actualités et bilan","%s · %s · Jour %d · %s" % [ui.world.scenario.name,ui.world.difficulty.name,ui.world.day,ui.world.outcome_text()])
	var totals = ui.world.totals()
	if ui.world.tactics_enabled and not ui.world.tactics.goal.is_empty(): ui.body.add_child(ui._label(ui.World.Tactics.goal_summary(ui.world),13,ui.MUTED))
	ui.body.add_child(ui._label("Sains : %d · Actifs : %d · Retirés : %d · Touchés : %.1f %% · Remède : %.1f %%" % [totals.healthy,totals.active,totals.removed,ui.world.coverage()*100,ui.world.cure],16))
	if not ui.world.objective.is_empty():
		var objective_line = ui._label("Objectif facultatif · "+ui.world.Objectives.summary(ui.world),13,ui.MUTED)
		objective_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ui.body.add_child(objective_line)
	ui.history_chart = load("res://scripts/ui/history_chart.gd").new()
	ui.history_chart.world = ui.world
	ui.history_chart.custom_minimum_size.y = 190
	ui.body.add_child(ui.history_chart)
	var columns = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation",16)
	ui.body.add_child(columns)
	var purchase_lines: Array[String] = []
	for purchase in ui.world.purchase_history: purchase_lines.append("J%d · %s · %d pts" % [purchase.day,ui.world.evolutions[purchase.id].name,purchase.cost])
	if purchase_lines.is_empty(): purchase_lines.append("Aucun achat daté enregistré.")
	if ui.world.purchase_history.size() < ui.world.purchased.size(): purchase_lines.append("Dates antérieures absentes de cette sauvegarde.")
	var effects: Array[String] = ui.Incidents.active_lines(ui.world)
	if ui.world.tactics_enabled and not ui.world.tactics.response.is_empty(): effects.append(ui.World.Tactics.summary(ui.world))
	if effects.is_empty(): effects.append("Aucun effet temporaire.")
	if not ui.world.decision.is_empty() and ui.world.Decisions.summary(ui.world) not in effects: effects.append(ui.world.Decisions.summary(ui.world))
	for section in [{"title":"Achats datés","text":"\n".join(purchase_lines)},{"title":"Effets en cours","text":"\n".join(effects)},{"title":"Actualités · plus récentes en haut","text":"\n".join(ui.reversed_news())}]:
		var column = VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		columns.add_child(column)
		column.add_child(ui._label(section.title,16,ui.ACCENT))
		var content = RichTextLabel.new()
		content.custom_minimum_size.y = 130
		content.size_flags_vertical = Control.SIZE_EXPAND_FILL
		content.focus_mode = Control.FOCUS_ALL
		content.add_theme_font_size_override("normal_font_size",18 if ui.reading_large else 14)
		content.text = section.text
		column.add_child(content)
	var controls = HBoxContainer.new()
	ui.body.add_child(controls)
	var back = ui._button("Retour [F3]",ui.close_overview,controls)
	ui._button("Aide [F1]",ui.open_help,controls)
	back.grab_focus()
