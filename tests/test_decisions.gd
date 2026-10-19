extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const Decisions = preload("res://scripts/gameplay/decisions.gd")

func model(enabled: bool = true) -> RefCounted:
	var world = World.new()
	world.start("boreale",2042,null,null,"degel2042","normal",null,null,"arctic_relays",enabled)
	return world

func advance(world: RefCounted, day: int) -> void:
	while world.day < day and world.outcome.is_empty(): world.step()

func buy(world: RefCounted) -> void:
	for id in ["transmission","mobility","discretion"]:
		if id not in world.purchased:
			world.purchase(id)
			break

func snapshot(world: RefCounted, historical: bool = false) -> Dictionary:
	var result = Store.new().encode(world)
	result.erase("saved_at")
	if historical:
		result.erase("history")
		result.erase("purchase_history")
	return result

func run(tree: SceneTree, check: Callable) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/decisions.json"))
	check.call(Decisions.validate(data).is_empty(),"Catalogue de décisions valide")
	for mutation in ["version","scenario","window","duplicate","cost","fraction","duration","factor","neutral","text"]:
		var bad = data.duplicate(true)
		match mutation:
			"version": bad.schema_version = 8
			"scenario": bad.decision.scenario = "standard"
			"window": bad.decision.expires_day = 28
			"duplicate": bad.decision.choices[1].id = "support"
			"cost": bad.decision.choices[0].cost = -1
			"fraction": bad.decision.choices[0].cost = 1.5
			"duration": bad.decision.choices[0].duration = 0
			"factor": bad.decision.choices[0].sea = INF
			"neutral": bad.decision.choices[2].cost = 1
			"text": bad.decision.choices[0].description = ""
		check.call(not Decisions.validate(bad).is_empty(),"Catalogue incohérent rejeté : " + mutation)
	var copy = Decisions.definition()
	copy.choices[0].cost = 99
	check.call(Decisions.option("support").cost == 3,"Définition protégée des mutations externes")
	var world = model()
	check.call(not World.new().start("boreale",2042,null,null,"standard","normal",null,null,"",true).is_empty(),"Événement réservé à Dégel")
	check.call(not Decisions.choose(world,"support").is_empty(),"Pas de choix avant le déclenchement")
	advance(world,27)
	check.call(world.decision.status == "scheduled","Décision encore planifiée au J27")
	world.step()
	check.call(Decisions.pending(world) and world.day == 28,"Décision ouverte exactement au J28")
	for id in ["support","limit","observe"]:
		world = model()
		advance(world,28)
		var points = world.points
		check.call(Decisions.choose(world,id).is_empty(),"Choix accepté : " + id)
		check.call(world.points == points - Decisions.option(id).cost,"Débit exact : " + id)
		check.call(not Decisions.choose(world,id).is_empty() and world.points == points - Decisions.option(id).cost,"Choix irréversible et sans double débit")
		check.call(Decisions.modifier(world,"transport_multiplier","sea") == 1.0,"Effet différé au lendemain")
		world.step()
		check.call(is_equal_approx(Decisions.modifier(world,"transport_multiplier","sea"),Decisions.option(id).sea),"Facteur maritime exact : " + id)
		check.call(is_equal_approx(Decisions.modifier(world,"cure_multiplier","global"),Decisions.option(id).cure),"Facteur remède exact : " + id)
		check.call(Decisions.modifier(world,"transport_multiplier","air") == 1.0,"Transport aérien inchangé")
		advance(world,34)
		check.call(is_equal_approx(world.event_modifier("transport_multiplier","sea"),0.5 * Decisions.option(id).sea),"Cumul multiplicatif du ralentissement maritime")
		check.call(not world.route_is_open(["boreale","orient"]) and not world.route_is_open(["boreale","centrale"]),"Choix incapable de rouvrir les routes fermées")
		advance(world,36)
		check.call(world.route_is_open(["boreale","orient"]) and not world.route_is_open(["boreale","centrale"]),"Fermeture cumulée prioritaire après la tempête")
		advance(world,40)
		check.call(Decisions.modifier(world,"transport_multiplier","sea") == Decisions.option(id).sea,"Dernier jour inclus J40")
		world.step()
		check.call(Decisions.modifier(world,"transport_multiplier","sea") == 1.0 and world.decision.status == ("resolved" if id == "observe" else "expired"),"Expiration au J41")
		var journal_size = world.journal.size()
		Decisions.update(world)
		check.call(world.journal.size() == journal_size,"Expiration annoncée une seule fois")
	world = model()
	advance(world,28)
	buy(world)
	buy(world)
	var before = snapshot(world)
	check.call(not Decisions.choose(world,"support").is_empty() and snapshot(world) == before,"Points insuffisants : aucun changement")
	check.call(not Decisions.choose(world,"unknown").is_empty(),"Choix inconnu refusé")
	check.call(not Decisions.choose(world,"support","timeout").is_empty(),"Automatisme payant refusé")
	check.call(not Decisions.choose(world,"observe","timeout").is_empty(),"Expiration prématurée refusée")
	advance(world,31)
	check.call(world.decision.choice == "observe" and world.decision.reason == "timeout","J31 : choix neutre automatique")
	check.call(not Decisions.choose(world,"limit").is_empty(),"Décision tardive refusée")
	world = model()
	advance(world,30)
	check.call(Decisions.choose(world,"limit").is_empty(),"Choix accepté au dernier jour J30")
	advance(world,42)
	check.call(world.decision.status == "active" and Decisions.modifier(world,"cure_multiplier","global") == 0.85,"Choix tardif actif jusqu'au J42 inclus")
	world.step()
	check.call(world.decision.status == "expired","Choix tardif expire au J43")
	var neutral = model()
	var disabled = model(false)
	for i in range(75):
		neutral.step()
		disabled.step()
	check.call(neutral.regions == disabled.regions and neutral.rng.state == disabled.rng.state and neutral.cure == disabled.cure and neutral.points == disabled.points and neutral.objective == disabled.objective,"Choix neutre automatique conserve la trajectoire sans événement")
	for end_day in [10,28]:
		world = model()
		advance(world,end_day)
		world.cure = 100
		world.resolve_outcome()
		Decisions.update(world)
		check.call(Decisions.valid_state(world.decision,world) and world.decision.status == ("cancelled" if end_day < 28 else "resolved"),"Fin de partie résout la décision sans coût")
	var store = Store.new()
	for id in ["support","limit","observe","timeout"]:
		for day in [0,27,28,29,30,31,34,40,41,50]:
			world = model()
			advance(world,mini(day,28))
			if day >= 28 and id != "timeout": Decisions.choose(world,id)
			advance(world,day)
			var decoded = store.decode(JSON.parse_string(JSON.stringify(store.encode(world),"",true,true)))
			check.call(decoded.error.is_empty(),"Sauvegarde décision : %s J%d" % [id,day])
			if not decoded.error.is_empty(): continue
			check.call(decoded.world.decision == world.decision,"Décision et dates exactes après lecture")
			for i in range(20):
				world.step()
				decoded.world.step()
			check.call(snapshot(world) == snapshot(decoded.world),"Reprise exacte sur vingt jours, coût et expiration inclus")
	world = model()
	advance(world,28)
	Decisions.choose(world,"support")
	var valid = store.encode(world)
	for mutation in ["missing","choice","status","future","early","points","reason","expired","legacy"]:
		var bad = valid.duplicate(true)
		match mutation:
			"missing": bad.erase("decision")
			"choice": bad.decision.choice = "unknown"
			"status": bad.decision.status = "resolved"
			"future": bad.decision.day = 29
			"early": bad.decision.day = 27
			"points": bad.points += 6
			"reason": bad.decision.reason = "timeout"
			"expired": bad.decision.status = "expired"
			"legacy": bad.format = 2; bad.content = Store.LEGACY_10_HASH
		check.call(not store.decode(bad).error.is_empty(),"Décision sauvegardée incohérente rejetée : " + mutation)
	store.directory = "user://tests-decisions-legacy"
	var files = load("res://tests/test_persistence.gd").new()
	files.clean(store)
	for name in ["arctic-pending","arctic-completed","arctic-failed","standard"]:
		var text = FileAccess.get_file_as_string("res://tests/fixtures/save-0.10-%s.json" % name)
		var loaded = store.decode(JSON.parse_string(text))
		check.call(loaded.error.is_empty() and loaded.has("warning"),"Vraie sauvegarde 0.10 acceptée : " + name)
		if not loaded.error.is_empty(): continue
		check.call(loaded.world.decision.is_empty(),"Aucune décision rétroactive")
		for i in range(30):
			if name != "arctic-failed": buy(loaded.world)
			loaded.world.step()
		var reference = store.decode(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/future-0.10-%s.json" % name)))
		check.call(reference.error.is_empty(),"Référence future 0.10 acceptée")
		if reference.error.is_empty(): check.call(snapshot(loaded.world,true) == snapshot(reference.world,true),"Trente vraies journées 0.10 conservées : " + name)
		DirAccess.make_dir_recursive_absolute(store.directory)
		store._write(store._path("slot1"),text)
		var resumed = store.load_slot("slot1")
		check.call(resumed.error.is_empty() and FileAccess.get_file_as_string(store._path("slot1")) == text,"Lecture 0.10 sans réécriture")
		check.call(store.save_slot("slot1",resumed.world).is_empty() and FileAccess.get_file_as_string(store._path("slot1") + ".bak") == text,"Premier secours conserve le texte 0.10 original")
	files.clean(store)
	var inputs = load("res://tests/input_journey.gd").new()
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	scene.save_store.directory = "user://tests-decisions-ui"
	files.clean(scene.save_store)
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080)]:
		tree.root.size = dimensions
		scene.scenario_id = "degel2042"
		scene.decision_enabled = false
		scene.show_new_game(2)
		await tree.process_frame
		await tree.process_frame
		check.call(not scene.decision_choice.button_pressed,"Décision désactivée par défaut au menu")
		check.call(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(scene.decision_choice.get_global_rect()),"Activation entièrement visible")
		scene.decision_choice.grab_focus()
		await inputs.key(tree,KEY_SPACE)
		check.call(scene.decision_enabled,"Activation au clavier")
		scene.start_game()
		advance(scene.world,27)
		scene.paused = false
		scene.advance_time(20)
		await tree.process_frame
		await tree.process_frame
		check.call(scene.screen == "game" and scene.paused and scene.world.day == 28,"Ouverture automatique arrête un grand delta au J28")
		check.call("Reprendre" in scene.get_viewport().gui_get_focus_owner().text,"Focus initial sans dépense accidentelle")
		for button in scene.decision_buttons.values(): check.call(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(button.get_global_rect()),"Choix visible sans défilement")
		scene.show_game()
		check.call(scene.screen == "game" and scene.paused and Decisions.pending(scene.world),"Réafficher le jeu conserve la décision en attente et la pause")
		await inputs.key(tree,KEY_F2)
		check.call(scene.screen == "game","F2 rouvre la décision")
		await inputs.key(tree,KEY_F1)
		check.call(scene.screen == "help","Aide accessible depuis la décision")
		await inputs.key(tree,KEY_F1)
		check.call(scene.screen == "game" and Decisions.pending(scene.world),"Retour de l'aide conserve le choix en attente")
		check.call(scene.save_store.save_slot("slot1",scene.world).is_empty(),"Décision en attente enregistrée")
		scene.load_saved("slot1")
		check.call(scene.screen == "game" and scene.paused and Decisions.pending(scene.world) and scene.decision_enabled,"Chargement en attente reprend en pause sans choix automatique")
		await inputs.key(tree,KEY_F2)
		await inputs.click(tree,scene.decision_buttons.support)
		check.call(scene.screen == "game" and scene.paused and scene.world.decision.choice == "support" and scene.world.points == 20,"Choix souris applique une seule dépense")
		check.call(scene.save_store.save_slot("slot1",scene.world).is_empty(),"Choix payant enregistré")
		scene.load_saved("slot1")
		check.call(scene.paused and scene.world.points == 20 and scene.world.decision.choice == "support","Chargement du choix payé sans nouveau débit")
		scene.start_tutorial()
		check.call(scene.world.decision.is_empty(),"Tutoriel isolé sans décision")
		scene.finish_tutorial()
		check.call(scene.world.decision.choice == "support" and scene.decision_enabled,"Retour du tutoriel conserve le choix")
		scene.restart_game()
		check.call(scene.world.decision.status == "scheduled" and scene.world.day == 0,"Rejouer conserve l'activation et réinitialise le choix")
		advance(scene.world,28)
		buy(scene.world)
		buy(scene.world)
		scene.show_decision()
		await tree.process_frame
		await tree.process_frame
		scene.decision_buttons.support.grab_focus()
		await inputs.key(tree,KEY_ENTER)
		check.call(scene.screen == "game" and "insuffisants" in scene.decision_notice.text,"Refus clavier avec raison visible")
		scene.decision_buttons.limit.grab_focus()
		await inputs.key(tree,KEY_ENTER)
		check.call(scene.screen == "game" and scene.world.decision.choice == "limit","Choix gratuit au clavier")
		scene.scenario_id = "standard"
		scene.show_new_game(2)
		check.call(not scene.decision_enabled and not scene.decision_choice.visible,"Standard retire l'activation Dégel")
	scene.queue_free()
	files.clean(scene.save_store)
	await tree.process_frame
	tree.root.size = Vector2i(1280,720)
