extends RefCounted
## Inline choices share the existing decision area; colour never carries the state alone.
static func build(ui, parent: Control) -> void:
	var strategy = ui.World.Strategy
	var status = ui._label(strategy.summary(ui.world), 13, ui.ACCENT)
	status.tooltip_text = strategy.rules_of(ui.world).agents[ui.world.strategy.agent].description
	if not ui.world.strategy.choices.is_empty():
		var latest = ui.world.strategy.choices[-1]
		status.tooltip_text += "\nDernier choix J%d : %s" % [latest.day, strategy.option(latest.choice, ui.world, latest).description]
	parent.add_child(status)
	if not strategy.pending(ui.world):
		var running = strategy.compact_line(ui.world)
		if not running.is_empty():
			var line = ui._label(running, 13, ui.ACCENT)
			line.tooltip_text = "\n".join(strategy.active_lines(ui.world))
			parent.add_child(line)
		return
	var situation = strategy.situation_text(ui.world)
	if not situation.is_empty():
		var context = ui._label("Situation : " + situation, 13, ui.MUTED)
		context.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		parent.add_child(context)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	for choice in strategy.choices(ui.world):
		var column = VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(column)
		var id = choice.id
		var button = ui._button("%s · %d pts" % [choice.name, choice.cost], func():
			var error = strategy.choose(ui.world, id)
			if error.is_empty():
				ui.feedback.play_cue("purchase")
				ui.autosave()
				ui.show_game()
			else:
				ui.decision_notice.text = error
				ui.decision_notice.show()
		, column)
		button.disabled = ui.world.points < choice.cost
		button.add_theme_font_size_override("font_size", 13)
		button.tooltip_text = choice.description
		ui.decision_buttons[id] = button
		var detail = ui._label(choice.description + (" Points insuffisants." if button.disabled else ""), 13, ui.MUTED)
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(detail)
	ui.decision_notice = ui._label("", 13, ui.AMBER)
	ui.decision_notice.hide()
	parent.add_child(ui.decision_notice)
