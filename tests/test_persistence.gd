extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")

func run(tree: SceneTree, check: Callable) -> void:
	var store = Store.new()
	store.directory = "user://tests-persistence"
	clean(store)
	for scenario in ["standard", "degel2042"]:
		for difficulty in ["easy", "normal", "hard"]:
			for target_day in [0, 23, 33, 56, 500]:
				var model = World.new()
				model.start("boreale", -9223372036854775807, null, null, scenario, difficulty)
				for i in range(target_day):
					if model.purchase_reason("transmission").is_empty(): model.purchase("transmission")
					model.step()
				var encoded = store.encode(model, 7, 4)
				var loaded = store.decode(JSON.parse_string(JSON.stringify(encoded, "", true, true)))
				check.call(loaded.error.is_empty(), "Sauvegarde valide %s/%s/j%d" % [scenario, difficulty, model.day])
				if not loaded.error.is_empty(): continue
				check.call(loaded.selected == 7 and loaded.speed == 4 and loaded.world.rng.state == model.rng.state, "Interface et RNG 64 bits restaurés")
				check.call(loaded.world.regions == model.regions and loaded.world.active_events == model.active_events and loaded.world.phase == model.phase and loaded.world.journal == model.journal and loaded.world.cure == model.cure, "Monde et effets restitués exactement")
				for i in range(50):
					model.step()
					loaded.world.step()
				var future = store.encode(model)
				var restored_future = store.encode(loaded.world)
				future.erase("saved_at")
				restored_future.erase("saved_at")
				check.call(future == restored_future, "Suite de simulation identique après chargement")
	var model = World.new()
	model.start("boreale")
	for i in range(23): model.step()
	var valid = store.encode(model)
	for mutation in ["format", "content", "engine", "day", "points", "cure", "population", "detected", "purchased", "phase", "rng", "seed", "outcome", "selected", "speed", "journal", "events", "activated", "event_end", "event_id", "missing", "scenario"]:
		var bad = valid.duplicate(true)
		match mutation:
			"format": bad.format = 2
			"content": bad.content = "wrong"
			"engine": bad.engine = "unknown"
			"day": bad.day = -1
			"points": bad.points += 1
			"cure": bad.cure = INF
			"population": bad.regions[0].healthy += 1
			"detected": bad.regions[0].detected = "true"
			"purchased": bad.purchased = ["mobility"]
			"phase": bad.phase = "absent"
			"rng": bad.rng = "9223372036854775808"
			"seed": bad.seed = 2042
			"outcome": bad.outcome = "victory"
			"selected": bad.selected = "absent"
			"speed": bad.speed = 3
			"journal": bad.journal = [3]
			"events": bad.events = []
			"activated": bad.activated = []
			"event_end": bad.events[0].end_day += 1
			"event_id": bad.events[0].id = "absent"
			"missing": bad.erase("regions")
			"scenario": bad.scenario = "absent"
		check.call(not store.decode(bad).error.is_empty(), "Rejet d'une sauvegarde altérée : " + mutation)
	for value in [null, [], "", 42]: check.call(not store.decode(value).error.is_empty(), "Racine invalide rejetée")
	for bits in ["000000000000f87f", "000000000000f07f", "zzzzzzzzzzzzzzzz", PackedFloat64Array([101.0]).to_byte_array().hex_encode()]:
		var bad = valid.duplicate(true)
		bad.cure = bits
		check.call(not store.decode(bad).error.is_empty(), "Valeur binaire du remède invalide rejetée")
	for slot in Store.SLOTS:
		check.call(store.save_slot(slot, model).is_empty(), "Écriture " + slot)
		check.call(store.load_slot(slot).world.day == 23, "Lecture " + slot)
	model.step()
	check.call(store.save_slot("slot1", model).is_empty(), "Remplacement atomique d'un fichier existant")
	check.call(store.load_slot("slot1").world.day == 24, "Nouvelle version chargée")
	check.call(store._read(store._path("slot1") + ".bak").world.day == 23, "Version précédente conservée")
	store._write(store._path("slot1"), "{truncated")
	var backup = store.load_slot("slot1")
	check.call(backup.error.is_empty() and backup.has("warning") and backup.world.day == 23, "Repli sur copie après corruption")
	check.call(store.save_slot("slot1", model).is_empty() and store._read(store._path("slot1") + ".bak").world.day == 23, "Fichier corrompu ne remplace pas le secours valide")
	store._write(store._path("slot1"), "{}")
	check.call(store.load_slot("slot1").get("warning", "") != "", "En-tête manquant récupéré depuis le secours")
	DirAccess.remove_absolute(store._path("slot1"))
	check.call(store.load_slot("slot1").get("warning", "") != "", "Fichier principal absent récupéré depuis le secours")
	var incompatible = valid.duplicate(true)
	incompatible.format = 99
	var incompatible_text = JSON.stringify(incompatible)
	store._write(store._path("slot1"), incompatible_text)
	check.call(not store.load_slot("slot1").error.is_empty(), "Version future signalée sans repli silencieux")
	check.call(not store.save_slot("slot1", model).is_empty() and FileAccess.get_file_as_string(store._path("slot1")) == incompatible_text, "Version future préservée lors d'une écriture")
	check.call(not store.save_slot("../escape", model).is_empty() and not store.load_slot("../escape").error.is_empty(), "Noms d'emplacement limités")
	store._write(store._path("slot2"), "x".repeat(Store.MAX_BYTES + 1))
	check.call(not store.load_slot("slot2").error.is_empty(), "Taille maximale contrôlée")
	var blocked = Store.new()
	blocked.directory = store._path("slot3")
	check.call(not blocked.save_slot("slot1", model).is_empty(), "Échec de stockage signalé")
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	await tree.process_frame
	scene.save_store = store
	scene.autosave_enabled = false
	scene.set_process(false)
	scene.start_game()
	for i in range(33): scene.world.step()
	scene.speed = 4
	scene.selected = 9
	scene.open_saves()
	check.call(scene.screen == "saves" and scene.paused and scene.world.day == 33, "Écran de sauvegarde suspend le monde")
	scene.save_manual("slot3")
	scene.world.step()
	scene.load_saved("slot3")
	check.call(scene.screen == "game" and scene.paused and scene.world.day == 33 and scene.selected == 9 and scene.speed == 4 and scene.elapsed == 0, "Chargement réel du contrôleur en pause")
	var original = scene.world
	scene.load_saved("slot1")
	check.call(scene.world == original and scene.world.day == 33, "Échec de chargement conserve la partie en mémoire")
	scene.autosave_enabled = true
	scene.show_game()
	scene.paused = false
	for i in range(7): scene.advance_time(0.125)
	check.call(store.load_slot("auto").world.day == 40, "Sauvegarde automatique au dixième jour à vitesse ×4")
	scene.show_menu()
	check.call(store.load_slot("auto").world.day == scene.world.day, "Sauvegarde au retour au menu")
	var inputs = load("res://tests/input_journey.gd").new()
	await tree.process_frame
	await inputs.click(tree, button_named(scene, "Sauvegardes"))
	check.call(scene.screen == "saves", "Clic sur Sauvegardes ouvre les emplacements")
	await inputs.key(tree, KEY_ESCAPE)
	check.call(scene.screen == "menu", "Échap ferme les sauvegardes")
	scene.show_game()
	scene.open_saves()
	await tree.process_frame
	await inputs.click(tree, button_named(scene, "Enregistrer ici"))
	check.call(is_instance_valid(scene.pending_dialog) and scene.pending_dialog.visible, "Écrasement demande confirmation")
	check.call(scene.pending_dialog.title == "Confirmer l'action" and scene.pending_dialog.get_cancel_button().has_focus(), "Confirmation française avec focus sur Annuler")
	scene.pending_dialog.canceled.emit()
	await tree.process_frame
	check.call(scene.world == original and scene.screen == "saves", "Annuler conserve partie et écran")
	await inputs.key(tree, KEY_ESCAPE)
	check.call(scene.screen == "game" and scene.paused, "Échap revient à la partie en pause")
	scene.queue_free()
	await tree.process_frame
	clean(store)

func button_named(node: Node, text: String) -> Button:
	if node is Button and node.text == text: return node
	for child in node.get_children():
		var found = button_named(child, text)
		if found != null: return found
	return null

func clean(store: RefCounted) -> void:
	for slot in Store.SLOTS:
		for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
			var path = store._path(slot) + suffix
			if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
