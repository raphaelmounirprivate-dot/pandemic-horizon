extends RefCounted
static func build(ui, parent: Control) -> void:
	var tactics = ui.World.Tactics
	parent.add_child(ui._label(tactics.summary(ui.world),13,ui.AMBER))
	if not tactics.pending(ui.world): return
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation",8)
	parent.add_child(row)
	for choice in tactics.rules().response.choices:
		var id = choice.id
		var column = VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(column)
		var button = ui._button("%s · %d pts" % [choice.name,choice.cost],func():
			var error = tactics.choose(ui.world,id)
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
		var detail = ui._label("Air ×%.2f · remède ×%.2f\n%s\n%s" % [choice.air,choice.cure,"Sans ajout d'effet" if id == "endure" else "6 jours dès demain",tactics.reason(ui.world,id)],13,ui.MUTED)
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(detail)
	parent.add_child(ui._label("Choix irréversible · Sans choix : subir gratuitement · Les routes fermées restent fermées",12,ui.AMBER))
	ui.decision_notice = ui._label("",13,ui.AMBER)
	ui.decision_notice.visible = false
	parent.add_child(ui.decision_notice)
