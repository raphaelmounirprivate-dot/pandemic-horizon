extends RefCounted
## Navigation and purchases around the Évolution screen. Selecting a skill only reads
## its card; world.purchase() is called solely by the explicit Évoluer action.
const EvolutionView = preload("res://scripts/ui/evolution_view.gd")

static func buy(ui, id: String) -> void:
	if ui.tutorial != null and (ui.tutorial.stage != 2 or id != "transmission"): return
	var error = ui.world.purchase(id)
	if error.is_empty(): ui.feedback.play_cue("purchase")
	if ui.tutorial != null and error.is_empty(): ui.tutorial.ready = true
	if ui.screen == "evolution":
		EvolutionView.refresh(ui)
		ui.status_label.text = error if not error.is_empty() else "%s acquise. Points restants : %d." % [ui.world.evolutions[id].name, ui.world.points]
		if error.is_empty() and ui.tutorial != null: ui.evolution_back.grab_focus()
		return
	ui._refresh()
	if not error.is_empty(): ui.status_label.text = error

static func select(ui, id: String) -> void:
	if not ui.world.evolutions.has(id): return
	ui.selected_evolution = id
	if ui.screen != "evolution": return
	if EvolutionView.family_of(ui,id) != ui.evolution_family:
		show_family(ui, EvolutionView.family_of(ui,id))
		return
	if ui.tutorial == null: ui.status_label.text = ""
	EvolutionView.refresh(ui)

## Purchase reason including the tutorial restriction (only Diffusion in exercise 3).
static func purchase_reason(ui, id: String) -> String:
	var reason = ui.world.purchase_reason(id)
	if ui.tutorial != null and id not in ui.world.purchased and (ui.tutorial.stage != 2 or id != "transmission"):
		return "Hors exercice" + (" · " + reason if not reason.is_empty() else "")
	return reason

## Opens the Évolution screen, optionally on the tab of a given skill. The game pauses
## and returns to its previous pause state when the screen is closed.
static func open(ui, id: String = "") -> void:
	if ui.world.regions.is_empty() or not ui.world.outcome.is_empty(): return
	if ui.screen == "evolution":
		if id.is_empty(): close(ui)
		else: select(ui, id)
		return
	if ui.screen != "game": return
	ui.evolution_return_paused = ui.paused
	if not id.is_empty() and ui.world.evolutions.has(id):
		ui.selected_evolution = id
		ui.evolution_family = EvolutionView.family_of(ui,id)
	ui.show_evolution()
	if ui.evolution_buttons.has(ui.selected_evolution): ui.evolution_buttons[ui.selected_evolution].grab_focus()

static func show_family(ui, family_id: String) -> void:
	ui.evolution_family = family_id
	if EvolutionView.family_of(ui,ui.selected_evolution) != family_id: ui.selected_evolution = ""
	ui.show_evolution()
	if ui.evolution_buttons.has(ui.selected_evolution): ui.evolution_buttons[ui.selected_evolution].grab_focus()

static func close(ui) -> void:
	if ui.screen != "evolution": return
	ui.show_game()
	ui.paused = ui.evolution_return_paused if ui.tutorial == null else true
	ui._refresh()
	# In the tutorial, show_game() already focused Continuer once the exercise succeeded.
	if ui.tutorial == null or not ui.tutorial.ready: ui.evolution_open_button.grab_focus()
