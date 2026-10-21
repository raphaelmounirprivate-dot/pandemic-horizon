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
	await run_legacy(tree, check)
	run_frozen(check)
	run_modern(check)

## Same policy as the generator described in tests/fixtures/README.md (commit 803208f).
func advance_frozen(world, until: int) -> void:
	while world.day < until and world.outcome.is_empty():
		if World.Strategy.pending(world) and world.day % 2 == 1:
			if World.Strategy.choose(world, "surge" if world.day > 40 else "anchor") != "": World.Strategy.choose(world, "observe")
		if "discretion" not in world.purchased and world.day >= 10: world.purchase("discretion")
		world.step()

func run_frozen(check: Callable) -> void:
	var store = Store.new()
	for name in ["pending", "active", "nacre"]:
		var text = FileAccess.get_file_as_string("res://tests/fixtures/save-0.25-%s.json" % name)
		var loaded = store.decode(JSON.parse_string(text))
		check.call(loaded.error.is_empty(), "Référence 0.25 chargée : " + name)
		if not loaded.error.is_empty(): continue
		check.call(World.Strategy.profile_of(loaded.world) == World.Strategy.PROFILE and store.encode(loaded.world).format == 8, "Référence 0.25 conservée en format 8 : " + name)
		check.call(World.Strategy.pending(loaded.world) == (name != "active"), "Référence 0.25 : décision en attente restaurée : " + name)
		advance_frozen(loaded.world, 70)
		var expected = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/future-0.25-%s.json" % name))
		var actual = JSON.parse_string(JSON.stringify(store.encode(loaded.world), "\t", true, true))
		expected.erase("saved_at")
		actual.erase("saved_at")
		check.call(actual == expected, "Référence 0.25 : futur identique au code 0.25 au J70 : " + name)

## Frozen strategy-0.25 profile (format 8): every game here names it explicitly.
func run_legacy(tree: SceneTree, check: Callable) -> void:
	var rules = World.Strategy.rules(World.Strategy.PROFILE)
	check.call(World.Strategy.validate(rules).is_empty(), "Profil stratégique valide")
	for key in ["window", "interval", "day_seconds", "agents", "choices"]:
		var bad = rules.duplicate(true)
		bad.erase(key)
		check.call(not World.Strategy.validate(bad).is_empty(), "Profil incomplet refusé : " + key)
	var store = Store.new()
	for agent in ["nacre", "pulse", "veil"]:
		var world = World.new()
		check.call(world.start_with({"start":"boreale", "agent":agent, "strategy":World.Strategy.PROFILE}).is_empty(), "Agent accepté : " + agent)
		check.call(store.encode(world).format == 8, "Format 8 du nouvel agent")
		var before = stable(world)
		check.call(not world.start_with({"start":"boreale", "agent":"absent"}).is_empty() and stable(world) == before, "Agent inconnu sans mutation")
		check.call(not world.start_with({"start":"boreale", "agent":agent, "reactive":true}).is_empty() and stable(world) == before, "Anciennes décisions incompatibles sans mutation")
		check.call(not world.start_with({"start":"boreale", "agent":agent, "strategy":"strategy-9"}).is_empty() and stable(world) == before, "Profil stratégique inconnu sans mutation")
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
	world.start_with({"start":"boreale", "agent":"nacre", "strategy":World.Strategy.PROFILE})
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
	world.purchased.append("discretion")
	check.call(World.Strategy.cure(world) == World.Strategy.factor(world, "cure") and World.Strategy.detection(world) == 1.0, "0.25 : Discrétion reste permanente et sans effet de détection")
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

func costed(world) -> String:
	for item in World.Strategy.choices(world):
		if item.id != "observe" and world.points >= item.cost: return item.id
	return "observe"

## strategy-0.26 (format 9): world-driven crises, temporary Discrétion, shifted ONDE cycle.
func run_modern(check: Callable) -> void:
	var strategy = World.Strategy
	var rules = strategy.rules(strategy.CURRENT)
	check.call(strategy.validate(rules).is_empty(), "0.26 : profil valide")
	var bad = rules.duplicate(true)
	bad.agents.pulse.period = bad.interval
	check.call(not strategy.validate(bad).is_empty(), "0.26 : cycle d'ONDE aligné sur les décisions refusé")
	for key in ["discretion", "triggers", "crises"]:
		bad = rules.duplicate(true)
		bad.erase(key)
		check.call(not strategy.validate(bad).is_empty(), "0.26 : profil incomplet refusé : " + key)
	bad = rules.duplicate(true)
	bad.crises.reverse()
	check.call(not strategy.validate(bad).is_empty(), "0.26 : ordre des situations imposé")
	bad = rules.duplicate(true)
	bad.crises[1].choices[2].cure = 0.5
	check.call(not strategy.validate(bad).is_empty(), "0.26 : conservation non neutre refusée")
	bad = rules.duplicate(true)
	bad.crises[2].choices[0].target_growth = 0
	check.call(not strategy.validate(bad).is_empty(), "0.26 : effet ciblé nul refusé")
	var store = Store.new()
	check.call(store.strategy_hash(strategy.CURRENT) != store.strategy_hash(strategy.PROFILE), "0.26 : empreinte distincte du profil 0.25")
	for agent in ["nacre", "pulse", "veil"]:
		var world = World.new()
		check.call(world.start_with({"start":"boreale", "agent":agent}).is_empty() and strategy.profile_of(world) == strategy.CURRENT, "0.26 : profil par défaut des nouvelles parties : " + agent)
		check.call(store.encode(world).format == 9, "0.26 : format 9")
		var seen: Array = []
		for day in range(70):
			if strategy.pending(world):
				if world.day == world.strategy.open.slot:
					seen.append(world.strategy.open.crisis)
					var waiting = store.decode(JSON.parse_string(JSON.stringify(store.encode(world), "", true, true)))
					check.call(waiting.error.is_empty() and stable(waiting.world) == stable(world), "0.26 : reprise exacte pendant une crise J%d : %s" % [world.day, agent])
					var data = store.encode(world)
					data.strategy.open = {}
					check.call(not store.decode(data).error.is_empty(), "0.26 : crise ouverte effacée refusée")
					data = store.encode(world)
					data.strategy.open.crisis = "absent"
					check.call(not store.decode(data).error.is_empty(), "0.26 : situation inconnue refusée")
				# Answer on the second day; the J56 crisis lapses into the free default at J60.
				if world.day == world.strategy.open.slot + 1 and world.day < 56: strategy.choose(world, costed(world))
			if world.day in [0, 21, 29, 40, 56, 69]:
				var restored = store.decode(JSON.parse_string(JSON.stringify(store.encode(world), "", true, true)))
				check.call(restored.error.is_empty(), "0.26 : reprise J%d : %s" % [world.day, agent])
				if restored.error.is_empty():
					check.call(stable(world) == stable(restored.world), "0.26 : état exact restauré")
					world.step()
					restored.world.step()
					check.call(stable(world) == stable(restored.world), "0.26 : futur exact restauré")
					continue
			world.step()
			if not world.outcome.is_empty(): break
		check.call(seen.size() >= 3, "0.26 : au moins trois crises proposées : " + agent)
		for i in range(1, seen.size()):
			check.call(seen[i] == "coordination" or seen[i] != seen[i - 1], "0.26 : une situation ne revient pas deux fois de suite")
		var data = store.encode(world)
		data.strategy.choices[0].target = "absente"
		check.call(not store.decode(data).error.is_empty(), "0.26 : cible inconnue refusée")
		data = store.encode(world)
		data.strategy.choices[0].choice = "absent"
		check.call(not store.decode(data).error.is_empty(), "0.26 : choix étranger à la situation refusé")
		data = store.encode(world)
		data.rules_profile = strategy.PROFILE
		check.call(not store.decode(data).error.is_empty(), "0.26 : profil déclaré incohérent refusé")
		data = store.encode(world)
		data.format = 8
		check.call(not store.decode(data).error.is_empty(), "0.26 : état 0.26 refusé en format 8")
		if world.strategy.choices.size() >= 2:
			data = store.encode(world)
			data.strategy.choices[1].crisis = data.strategy.choices[0].crisis
			data.strategy.choices[1].target = data.strategy.choices[0].target
			data.strategy.choices[1].choice = "observe"
			if data.strategy.choices[0].crisis != "coordination": check.call(not store.decode(data).error.is_empty(), "0.26 : répétition de situation refusée")
	# Deterministic: same seed, same answers, same save.
	var first = World.new()
	var second = World.new()
	for world in [first, second]:
		world.start_with({"start":"centrale", "agent":"veil", "seed":11113})
		for day in range(60):
			if strategy.pending(world): strategy.choose(world, costed(world))
			world.step()
	check.call(stable(first) == stable(second), "0.26 : parties identiques à graine et choix égaux")
	# Situations read the world state of the opening day.
	var world = World.new()
	world.start_with({"start":"boreale", "agent":"nacre"})
	for day in range(19): world.step()
	# The scripted J18 storm would otherwise make "cut" the first situation.
	world.active_events.clear()
	world.cure = 40.0
	check.call(strategy.detect_crisis(world).crisis == "science", "0.26 : remède ≥ 35 % : pression scientifique")
	world.strategy.choices.append({"slot":8, "day":8, "choice":"observe", "crisis":"science", "target":""})
	check.call(strategy.detect_crisis(world).crisis != "science", "0.26 : la situation précédente n'est pas reproposée")
	world.strategy.choices.clear()
	world.cure = 0.0
	var home = world.regions[0]
	for region in world.regions:
		if region.id == "boreale": home = region
	home.removed = int(home.population * 0.7)
	home.healthy = home.population - home.active - home.removed
	var found = strategy.detect_crisis(world)
	check.call(found.crisis == "saturated" and found.target == "boreale", "0.26 : région touchée à 60 % : foyer développé")
	for edge in world.connections:
		if "boreale" in edge: world.active_events.append({"id":"test_" + str(edge), "name":"Test", "kind":"route_closure", "target":edge, "factor":1.0, "start_day":0, "end_day":999})
	found = strategy.detect_crisis(world)
	check.call(found.crisis == "cut" and found.target == "boreale", "0.26 : liaison fermée d'une région touchée : liaison interrompue")
	world.active_events.clear()
	home.removed = 0
	home.active = 5000
	home.healthy = home.population - home.active
	# Make one open neighbour untouched; the scripted storm may close other links.
	for edge in world.connections:
		if "boreale" in edge and world.route_is_open(edge):
			var spared = strategy.region_by_id(world, edge[1] if edge[0] == "boreale" else edge[0])
			spared.active = 0
			spared.removed = 0
			spared.healthy = spared.population
			break
	found = strategy.detect_crisis(world)
	check.call(found.crisis == "passage" and found.target != "boreale", "0.26 : foyer actif relié à une région épargnée : passage ouvert")
	world.step()
	check.call(strategy.pending(world) and world.strategy.open.crisis == "passage", "0.26 : crise ouverte J20 selon la situation")
	check.call(strategy.choices(world).size() == 3 and strategy.option("cross", world).cost == 3, "0.26 : réponses propres à la situation")
	var target = world.strategy.open.target
	check.call(strategy.choose(world, "cross").is_empty(), "0.26 : passage franchi")
	check.call(strategy.active_lines(world)[0].contains("8 j restants"), "0.26 : effet actif affiché dès le choix")
	world.step()
	var reached = strategy.region_by_id(world, target)
	check.call(is_equal_approx(strategy.growth(world, reached) / strategy.growth(world, home), 2.0), "0.26 : croissance ciblée dans la région visée")
	check.call(strategy.active_lines(world)[0].contains("7 j restants") and strategy.active_lines(world)[0].contains(world.region_name(target)), "0.26 : jours restants et région visée lisibles")
	# Discrétion: temporary bonus with an exchange counterpart.
	world.points = 40
	var plain = strategy.exchange(world, home)
	check.call(world.purchase("discretion").is_empty(), "0.26 : Discrétion achetée")
	var bought = world.day
	check.call(is_equal_approx(strategy.cure(world) * world.upgrade_modifier("cure_multiplier"), strategy.factor(world, "cure") * 0.7), "0.26 : remède ×0,7 pendant Discrétion")
	check.call(strategy.detection(world) == 1.6 and is_equal_approx(strategy.exchange(world, home), plain * 0.85), "0.26 : détection retardée, échanges ×0,85")
	check.call(strategy.effect_text(world, "discretion").contains("30 jours"), "0.26 : texte de Discrétion adapté au profil")
	check.call(strategy.active_lines(world).any(func(line): return line.begins_with("Discrétion") and line.contains("30 j restants")), "0.26 : durée de Discrétion affichée")
	world.day = bought + 31
	check.call(is_equal_approx(strategy.cure(world) * world.upgrade_modifier("cure_multiplier"), strategy.factor(world, "cure")) and strategy.detection(world) == 1.0, "0.26 : Discrétion sans effet après 30 jours")
	# ONDE: decisions fall on different phases of the cycle.
	world.strategy.agent = "pulse"
	var phases: Array = []
	for opened in [20, 32, 44, 56]:
		if not strategy.pulse_high(world, opened + 1) in phases: phases.append(strategy.pulse_high(world, opened + 1))
	check.call(phases.size() == 2, "0.26 : ONDE en poussée ou en repli selon la décision")
	world.day = 20
	check.call(strategy.active_lines(world).any(func(line): return line.begins_with("ONDE") and line.contains("dès J")), "0.26 : prochaine phase d'ONDE affichée")
	var compact = strategy.compact_line(world)
	check.call(compact.contains("Franchir le passage : 8 j") and compact.contains("ONDE poussée") and compact.contains("Discrétion : 30 j"), "0.26 : résumé court des effets en cours")
