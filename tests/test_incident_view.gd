extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const View = preload("res://scripts/ui/incident_view.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func snapshot(world) -> Dictionary:
	var data = Store.new().encode(world)
	data.erase("saved_at")
	return data
func run(tree,check) -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	var input = load("res://tests/input_journey.gd").new()
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		tree.root.size = dimensions
		for kind in ["none","storm","earthquake","communications"]:
			scene.crises_mode = true
			scene.advanced_mode = true
			scene.scenario_id = "degel2042"
			scene.objective_id = "arctic_relays"
			scene.decision_enabled = true
			scene.start_game()
			var desired = {}
			if kind != "none":
				desired = scene.world.event_definitions.filter(func(e): return e.get("template") == kind)[0]
				for day in range(desired.start_day): scene.world.step()
			scene.show_game()
			await tree.process_frame
			await tree.process_frame
			var before = snapshot(scene.world)
			var encoded_before = Store.new().encode(scene.world)
			var entries = View.entries(scene.world)
			var counts = View.counts(scene.world)
			check.call(counts.global == entries.filter(func(e): return e.scope == "global").size() and counts.local+counts.global == entries.size(),"Comptages local/mondial exacts")
			check.call(entries.all(func(e): return e.start_day <= scene.world.day),"Aucun incident futur révélé")
			check.call(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(scene.incident_button.get_global_rect()) and Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(scene.pause_button.get_global_rect()),"Localisation et pause visibles avec24 compétences")
			if kind == "none":
				check.call(entries.is_empty() and scene.incident_button.disabled and not scene.map_view.focus_next_incident(),"Aucun repère ni commande active avant un incident")
				var future = scene.world.event_definitions.filter(func(e): return e.get("source") == "crisis")[0]
				check.call(not scene.map_view.focus_incident(future.id),"Localisation d'un futur incident refusée")
			else:
				var current = entries.filter(func(e): return e.id == desired.id)[0]
				check.call(current.text.contains("fin J%d" % (desired.start_day+desired.duration)),"Fin exclusive et durée visibles")
				if current.scope == "global":
					check.call("Monde" in current.text and not scene.map_view.focus_incident(current.id),"Effet mondial explicitement non localisable")
				else:
					check.call(scene.map_view.focus_incident(current.id),"Incident actif localisable")
					check.call(Rect2(Vector2.ZERO,scene.map_view.size).has_point(scene.map_view.incident_position(current)),"Repère ciblé visible après zoom")
					check.call(scene.map_view._get_tooltip(scene.map_view.incident_position(current)) == current.text,"Infobulle du repère complète")
					await input.key(tree,KEY_F4)
					check.call(not scene.map_view.focused_incident.is_empty(),"F4 localise un incident actif")
					if kind == "earthquake":
						var index = scene.world.regions.find_custom(func(r): return r.id == desired.target)
						check.call(desired.name in scene.map_view.buttons[index].tooltip_text,"Région atteinte : incident dans l'infobulle")
					if kind == "storm":
						scene.map_view.focus_incident(current.id)
						var point = scene.map_view.global_position+scene.map_view.incident_position(current)
						for pressed in [true,false]:
							var event = InputEventMouseButton.new()
							event.position = point
							event.global_position = point
							event.button_index = MOUSE_BUTTON_LEFT
							event.pressed = pressed
							tree.root.push_input(event,true)
							await tree.process_frame
						check.call(scene.map_view.focused_incident == current.id,"Clic moteur sur repère maritime")
					scene.open_overview()
					check.call(scene.screen == "overview", "Consultation des effets mondiaux accessible")
					scene.close_overview()
					check.call(not scene.map_view.focused_incident.is_empty(),"Repère ciblé conservé au retour de Monde")
				for day in range(desired.duration): scene.world.step()
				scene._refresh()
				check.call(not View.entries(scene.world).any(func(e): return e.id == desired.id),"Repère expiré supprimé")
				# Compare the exact post-expiration state through a fresh reconstruction.
				var expected = Store.new().decode(encoded_before)
				for day in range(desired.duration): expected.world.step()
				before = snapshot(expected.world)
			check.call(snapshot(scene.world) == before,"Repères, F4 et consultation sans mutation des règles/RNG")
			var loaded = Store.new().decode(Store.new().encode(scene.world))
			check.call(loaded.error.is_empty() and View.entries(loaded.world) == View.entries(scene.world),"Repères actifs exacts après reprise")
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
