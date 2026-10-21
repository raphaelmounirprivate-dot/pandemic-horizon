extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const Explanation = preload("res://scripts/ui/result_explanation.gd")
const LayoutCheck = preload("res://tests/test_result_view.gd")

func stable(world) -> Dictionary:
	var state = Store.new().encode(world)
	state.erase("saved_at")
	return state

func run(tree: SceneTree, check: Callable) -> void:
	var rules = World.Strategy.rules()
	check.call(World.Strategy.validate(rules).is_empty(), "Profil stratégique valide")
	for key in ["window", "interval", "day_seconds", "agents", "choices"]:
		var bad = rules.duplicate(true)
		bad.erase(key)
		check.call(not World.Strategy.validate(bad).is_empty(), "Profil incomplet refusé : " + key)
	var store = Store.new()
	for agent in ["nacre", "pulse", "veil"]:
		var world = World.new()
		check.call(world.start_with({"start":"boreale", "agent":agent}).is_empty(), "Agent accepté : " + agent)
		check.call(store.encode(world).format == 8, "Format 8 du nouvel agent")
		var before = stable(world)
		check.call(not world.start_with({"start":"boreale", "agent":"absent"}).is_empty() and stable(world) == before, "Agent inconnu sans mutation")
		check.call(not world.start_with({"start":"boreale", "agent":agent, "reactive":true}).is_empty() and stable(world) == before, "Anciennes décisions incompatibles sans mutation")
		for day in range(45):
			if World.Strategy.pending(world): World.Strategy.choose(world, "anchor" if world.day < 30 else "surge")
			if world.day in [0, 19, 20, 21, 28, 32, 33, 44]:
				var restored = store.decode(JSON.parse_string(JSON.stringify(store.encode(world), "", true, true)))
				check.call(restored.error.is_empty(), "Reprise stratégique J%d : %s" % [world.day, agent])
				if restored.error.is_empty():
					check.call(stable(world) == stable(restored.world), "État exact restauré")
					world.step()
					restored.world.step()
					check.call(stable(world) == stable(restored.world), "Futur exact restauré avec RNG")
					continue
			world.step()
		var data = store.encode(world)
		data.strategy.choices[0].day = -1
		check.call(not store.decode(data).error.is_empty(), "Chronologie de choix corrompue refusée")
		data = store.encode(world)
		data.strategy.choices[0].choice = "absent"
		check.call(not store.decode(data).error.is_empty(), "Choix inconnu refusé")
		data = store.encode(world)
		data.points += 1
		check.call(not store.decode(data).error.is_empty(), "Budget stratégique corrompu refusé")
	var world = World.new()
	world.start_with({"start":"boreale", "agent":"nacre"})
	for day in range(20): world.step()
	check.call(World.Strategy.pending(world), "Première décision J20")
	var before = stable(world)
	check.call(not World.Strategy.choose(world, "absent").is_empty() and stable(world) == before, "Choix invalide sans mutation")
	check.call(World.Strategy.choose(world, "surge").is_empty(), "Expansion choisie")
	check.call(World.Strategy.factor(world, "exchange") == 1.0, "Aucun effet le jour du choix")
	world.step()
	check.call(World.Strategy.factor(world, "exchange") == 4.0 and World.Strategy.factor(world, "cure") == 1.45, "Effet et contrepartie dès demain")
	for day in range(8): world.step()
	check.call(World.Strategy.factor(world, "exchange") == 1.0, "Effet expiré après huit jours")
	for day in range(7): world.step()
	check.call(world.strategy.choices[-1].choice == "observe" and world.strategy.choices[-1].day == 36, "Conservation automatique à l'échéance J36")
	check.call(store.decode(store.encode(world)).error.is_empty(), "Échéance automatique sauvegardable")
	var sample = world.regions[0].duplicate(true)
	sample.active = 1000
	sample.removed = 0
	var low = World.Strategy.exchange(world, sample)
	sample.removed = int(sample.population * 0.5)
	check.call(is_equal_approx(World.Strategy.exchange(world, sample), low * 2.0), "NACRE : seuil de foyer double les exports")
	world.strategy.agent = "pulse"
	world.day = 24
	var high = World.Strategy.growth(world, sample)
	world.day = 30
	check.call(high > World.Strategy.growth(world, sample), "ONDE : poussée puis retrait de croissance")
	world.strategy.agent = "veil"
	sample.detected = false
	high = World.Strategy.growth(world, sample)
	sample.detected = true
	check.call(high > World.Strategy.growth(world, sample), "VOILE : la détection change la croissance")
	world.outcome = "defeat_cure"
	check.call(Explanation.text(world).contains("couverture manquaient"), "Bilan explicite sans causalité inventée")
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	for size in [Vector2i(1280,720), Vector2i(1920,1080), Vector2i(2395,1060)]:
		tree.root.size = size
		scene.agent_id = "nacre"
		scene.show_new_game(2)
		await tree.process_frame
		await tree.process_frame
		check.call(LayoutCheck.new().targets_ok(scene.body, Rect2(Vector2.ZERO, Vector2(size))), "Choix d'agent dans la fenêtre : %d" % size.x)
		scene.start_game()
		check.call(scene.world.strategy.agent == "nacre", "Choix d'agent appliqué depuis le menu")
		scene.paused = false
		scene.advance_time(0.5)
		check.call(scene.world.day == 0, "Profil stratégique ne progresse pas en une demi-seconde")
		scene.advance_time(5.5)
		check.call(scene.world.day == 1, "Profil stratégique : six secondes par journée")
		for day in range(18): scene.world.step()
		scene.paused = false
		scene.advance_time(6.0)
		check.call(scene.world.day == 20 and scene.paused, "Pause automatique au déclenchement stratégique")
		await tree.process_frame
		await tree.process_frame
		check.call(scene.decision_buttons.size() == 3, "Trois réponses stratégiques intégrées")
		check.call(LayoutCheck.new().targets_ok(scene.body, Rect2(Vector2.ZERO, Vector2(size))), "Réponses stratégiques dans la fenêtre : %d" % size.x)
		scene.world.outcome = "defeat_cure"
		scene.world.cure = 100.0
		scene.show_result()
		await tree.process_frame
		await tree.process_frame
		check.call(LayoutCheck.new().targets_ok(scene.body, Rect2(Vector2.ZERO, Vector2(size))), "Bilan stratégique dans la fenêtre : %d" % size.x)
	var audio = scene.feedback
	check.call(audio.cues.decision.data != audio.cues.alert.data, "Alerte de décision distincte de la détection")
	check.call(audio.ambient.stream.loop_end == 88200, "Ambiance synthétique bouclée sur quatre secondes")
	audio.configure(true, 0.3)
	audio.set_ambience(true, 0.5)
	check.call(audio.ambient.playing, "Ambiance activée avec le son")
	audio.configure(false, 0.3)
	check.call(not audio.ambient.playing, "Désactivation coupe immédiatement l'ambiance")
	scene.queue_free()
	await tree.process_frame
