extends RefCounted
## Dedicated "Évolution" screen: one tab per family, prerequisite tree, sheet and explicit purchase.
## The game stays paused here; selecting never spends points.
const TreeView = preload("res://scripts/ui/skill_tree_view.gd")
const NodeButton = preload("res://scripts/ui/evolution_node.gd")
const Symbol = preload("res://scripts/ui/family_symbol.gd")

## Families shown as tabs, in catalog order; skills without metadata get their own tab.
static func families(ui) -> Array:
	var result: Array = []
	var listed: Array = []
	for group in ui.Skills.catalog():
		var ids = group.skills.filter(func(id): return ui.world.evolutions.has(id))
		listed.append_array(ids)
		if not ids.is_empty(): result.append({"id": group.id, "name": group.name, "skills": ids})
	var others = ui.world.evolutions.keys().filter(func(id): return id not in listed)
	if not others.is_empty(): result.append({"id": "others", "name": "Autres", "skills": others})
	return result

static func family_of(ui, id: String) -> String:
	for group in families(ui):
		if id in group.skills: return group.id
	return ""

static func build(ui) -> void:
	ui.screen = "evolution"
	ui.paused = true
	ui.elapsed = 0.0
	var groups = families(ui)
	if not groups.any(func(g): return g.id == ui.evolution_family): ui.evolution_family = groups[0].id
	if family_of(ui, ui.selected_evolution) != ui.evolution_family:
		ui.selected_evolution = groups.filter(func(g): return g.id == ui.evolution_family)[0].skills[0]
	ui._reset_screen("Évolution", "")
	ui.evolution_subtitle = ui.body.get_child(1)
	points_badge(ui, ui.body.get_child(0))
	var tabs = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	ui.body.add_child(tabs)
	ui.evolution_tabs.clear()
	for group in groups:
		var tab = Button.new()
		tab.toggle_mode = true
		tab.button_pressed = group.id == ui.evolution_family
		tab.custom_minimum_size = Vector2(220, 56)
		tab.alignment = HORIZONTAL_ALIGNMENT_LEFT
		tab.add_theme_font_size_override("font_size", 17)
		var active = group.id == ui.evolution_family
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			tab.add_theme_stylebox_override(state, tab_style(state, active))
		tab.tooltip_text = ("Onglet actif · " if active else "Afficher la famille ") + group.name
		var icon = Symbol.new()
		icon.family_id = group.id
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2(10, 16)
		icon.size = Vector2(24, 24)
		tab.add_child(icon)
		var family_id = group.id
		tab.pressed.connect(func(): ui.show_evolution_family(family_id))
		tabs.add_child(tab)
		ui.evolution_tabs[group.id] = tab
	var content = HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 24)
	ui.body.add_child(content)
	var tree = TreeView.new()
	tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(tree)
	var current = groups.filter(func(g): return g.id == ui.evolution_family)[0]
	tree.setup(ui.world, current.skills)
	ui.evolution_tree = tree
	for id in current.skills:
		var button = NodeButton.new()
		button.evolution_id = id
		button.family_id = current.id
		button.focus_entered.connect(func(): ui.select_evolution(id))
		button.pressed.connect(func():
			ui.select_evolution(id)
			if not ui.evolution_purchase.disabled: ui.evolution_purchase.grab_focus())
		tree.add_node(id, button)
		ui.evolution_buttons[id] = button
		ui.evolution_reasons[id] = button.state_label
	var sheet = VBoxContainer.new()
	sheet.custom_minimum_size.x = 300 if ui.get_viewport_rect().size.x < 1600 else 480
	sheet.add_theme_constant_override("separation", 4)
	content.add_child(sheet)
	ui.evolution_title = ui._label("", 24)
	ui.evolution_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sheet.add_child(ui.evolution_title)
	ui.evolution_detail = ui._label("", 15, ui.MUTED)
	ui.evolution_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sheet.add_child(ui.evolution_detail)
	ui.specialization_details = ui._label("", 14, ui.AMBER)
	ui.specialization_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sheet.add_child(ui.specialization_details)
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sheet.add_child(spacer)
	ui.status_label = ui._label("", 15, ui.AMBER)
	ui.status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sheet.add_child(ui.status_label)
	if ui.tutorial != null: ui.status_label.text = ui.tutorial.instruction(ui.world.day)
	ui.evolution_purchase = ui._button("", func(): ui.buy_evolution(ui.selected_evolution), sheet)
	ui.evolution_purchase.custom_minimum_size.y = 56
	ui.evolution_purchase.add_theme_font_size_override("font_size", 20)
	var footer = HBoxContainer.new()
	ui.body.add_child(footer)
	ui.evolution_back = ui._button("Retour à la carte [Échap]", ui.close_evolution, footer)
	ui.evolution_back.custom_minimum_size.x = 320
	var hint = ui._label("E : ouvrir ou fermer · Tab : parcourir · Entrée : choisir · La partie reste en pause ici", 15, ui.MUTED)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(hint)
	refresh(ui)
	tree.call_deferred("place_nodes")

static func refresh(ui) -> void:
	var world = ui.world
	ui.evolution_subtitle.text = "%s · Jour %d · %s" % [world.scenario.name, world.day, summary(ui)]
	ui.evolution_points.text = str(world.points)
	ui.evolution_points_next.text = "point%s disponible%s\n+%d au J%d" % ["s" if world.points > 1 else "", "s" if world.points > 1 else "", world.POINT_GAIN, world.next_points_day()]
	for group in families(ui):
		var owned = group.skills.filter(func(id): return id in world.purchased).size()
		var buyable = group.skills.filter(func(id): return id not in world.purchased and ui.purchase_reason_for(id).is_empty()).size()
		ui.evolution_tabs[group.id].text = "%s · %d/%d\n%s" % [group.name, owned, group.skills.size(), "Aucune achetable" if buyable == 0 else "+ %d achetable%s" % [buyable, "s" if buyable > 1 else ""]]
	for id in ui.evolution_buttons:
		var skill = world.evolutions[id]
		var acquired = id in world.purchased
		var reason = ui.purchase_reason_for(id)
		var button = ui.evolution_buttons[id]
		button.acquired = acquired
		button.selected_node = id == ui.selected_evolution
		button.blocked = not reason.is_empty() and not acquired
		button.available = reason.is_empty() and not acquired
		button.disabled = ui.tutorial != null and (ui.tutorial.stage != 2 or id != "transmission")
		button.tooltip_text = skill.name + "\n" + skill.effect
		button.show_state(skill.name, ui.Skills.short_effect(skill), "" if acquired else "%d pts" % skill.cost, state_text(acquired, reason, skill.cost - world.points), acquired or reason.is_empty())
	var id = ui.selected_evolution
	var chosen = world.evolutions[id]
	var full_reason = "Acquise" if id in world.purchased else ui.purchase_reason_for(id)
	ui.evolution_title.text = chosen.name
	ui.evolution_detail.text = sheet_text(ui, id, full_reason)
	ui.specialization_details.text = specialization_text(ui, id)
	ui.evolution_purchase.text = "Acquise" if id in world.purchased else "Évoluer · %d pts" % chosen.cost
	ui.evolution_purchase.disabled = not ui.purchase_reason_for(id).is_empty() or id in world.purchased
	ui.evolution_tree.queue_redraw()

static func state_text(acquired: bool, reason: String, missing: int) -> String:
	if acquired: return "Acquise"
	if reason.is_empty(): return "Disponible"
	if reason.begins_with("Hors exercice"): return "Prérequis (exercice)" if "Prérequis" in reason else "Hors exercice"
	if reason.begins_with("Prérequis"): return "Prérequis"
	if reason.begins_with("Incompatible"): return "Incompatible"
	if reason.begins_with("Points"): return "Manque %d pt%s" % [missing, "s" if missing > 1 else ""]
	return reason

static func tab_style(state: String, active: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("254954") if active or state in ["hover", "pressed"] else Color("16333e")
	style.set_corner_radius_all(6)
	style.content_margin_left = 44
	style.content_margin_right = 16
	# The active tab is underlined, not only lighter.
	if active:
		style.border_color = Color("69d6bd")
		style.border_width_bottom = 4
	if state == "focus":
		style.bg_color = Color.TRANSPARENT
		style.border_color = Color("69d6bd")
		style.set_border_width_all(2)
	return style

static func sheet_text(ui, id: String, reason: String) -> String:
	var world = ui.world
	var skill = world.evolutions[id]
	var group = ui.Skills.family(id)
	var state = "Acquise" if id in world.purchased else ("Disponible · sélectionner ne dépense rien, Évoluer achète" if reason.is_empty() else reason.trim_suffix("."))
	if reason.begins_with("Points"): state = "Points insuffisants · %d requis, %d disponibles" % [skill.cost, world.points]
	var lines: Array[String] = ["%s · %d points" % [group.get("name", "Compétence"), skill.cost], "État : " + state, "EFFET", skill.effect, "AVANT → APRÈS (hors climat et aléas)"]
	lines.append_array(ui.Skills.comparison(world, id).split(" · "))
	lines.append("PRÉREQUIS")
	if skill.requires.is_empty(): lines.append("Aucun")
	for required in skill.requires:
		lines.append("%s : %s" % [world.evolutions[required].name, "acquise" if required in world.purchased else "manquante"])
	return "\n".join(lines)

static func specialization_text(ui, id: String) -> String:
	var world = ui.world
	var excluded = world.evolutions[id].get("excludes", [])
	if excluded.is_empty(): return ""
	var names = excluded.map(func(other): return world.evolutions[other].name)
	var chosen = world.specialization_id()
	if not chosen.is_empty(): return "Spécialisation choisie : %s. Une seule est possible par partie." % world.evolutions[chosen].name
	return "Une seule spécialisation par partie : choisir celle-ci exclut %s." % " et ".join(names)

static func summary(ui) -> String:
	var available = ui.world.evolutions.keys().filter(func(id): return ui.purchase_reason_for(id).is_empty()).size()
	if available == 0: return "Aucune compétence achetable maintenant"
	return "%d compétence%s achetable%s maintenant : contour épais et marque +" % [available, "s" if available > 1 else "", "s" if available > 1 else ""]

## Points shown large in the title row, with the date of the next gain.
static func points_badge(ui, heading: HBoxContainer) -> void:
	var panel = PanelContainer.new()
	panel.name = "points_badge"
	var style = StyleBoxFlat.new()
	style.bg_color = Color("16333e")
	style.border_color = ui.ACCENT
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	panel.add_theme_stylebox_override("panel", style)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	ui.evolution_points = ui._label("", 28, ui.ACCENT)
	ui.evolution_points.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(ui.evolution_points)
	ui.evolution_points_next = ui._label("", 14)
	ui.evolution_points_next.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(ui.evolution_points_next)
	# Keep the version label last, at the far right.
	heading.add_child(panel)
	heading.move_child(panel, heading.get_child_count() - 2)
