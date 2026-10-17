extends RefCounted
const Analysis = preload("res://scripts/analysis/logistics_parameters.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func buy(world: RefCounted) -> void:
	for id in ["transmission","mobility","discretion"]:
		if id not in world.purchased:
			world.purchase(id)
			break
func run(check: Callable) -> void:
	var original = Analysis.Decisions.definition()
	check.call(Analysis.candidates().size() == 12,"Douze modèles, dont trois témoins et neuf soutiens")
	var rows: Array = []
	for policy in ["mobilite","saisonnier"]:
		for id in Analysis.candidates():
			var row = Analysis.play("normal",42,policy,id)
			check.call(row.error.is_empty(),"Modèle terminé : " + id)
			check.call(Analysis.Decisions.definition() == original,"Catalogue distribué restauré après simulation")
			if row.error.is_empty(): rows.append(row)
	var paired = Analysis.pair_rows(rows)
	check.call(paired.error.is_empty() and paired.get("groups",[]).size() == 2,"Groupes complets, budget et jour de choix constants")
	check.call(Analysis.Decisions.definition() == original,"Catalogue restauré après validation des traces")
	if not paired.error.is_empty(): return
	var group = paired.groups[0]
	var baseline = Analysis.Comparison.play("normal",42,group.disabled.policy,"support","reserve",500,6)
	var candidate = group.support_c3_r1150.duplicate(true)
	for key in ["candidate","parameters","model_hash"]: candidate.erase(key)
	check.call(candidate == baseline,"Candidat 3/1,15 exactement égal au modèle 0.12 distribué")
	for id in Analysis.candidates():
		if Analysis.candidates()[id].arm != "support": continue
		check.call(group[id].decision.day == 28 and group[id].decision.choice == "support","Tous les prix sont financés au même J28")
	check.call(group.support_c0_r1150.points >= group.support_c6_r1150.points or group.support_c0_r1150.purchases != group.support_c6_r1150.purchases,"Prix appliqué au budget réel, sans masquer les achats modifiés")
	check.call(not Analysis.play("normal",42,"mobilite","unknown").error.is_empty(),"Candidat inconnu refusé")
	check.call(not Analysis.play("unknown",42,"mobilite","support_c3_r1075").error.is_empty() and Analysis.Decisions.definition() == original,"Erreur du simulateur restaure le catalogue")
	check.call(not Analysis.play("normal",42,"mobilite","support_c3_r1075",1).error.is_empty() and Analysis.Decisions.definition() == original,"Partie non terminée restaure le catalogue")
	var previous = Analysis.Decisions._definition.duplicate(true)
	Analysis.Decisions._definition = {}
	Analysis.play("unknown",42,"mobilite","support_c3_r1075")
	check.call(Analysis.Decisions._definition.is_empty(),"Cache initialement vide restauré après erreur")
	Analysis.Decisions._definition = previous
	var valid: Array = []
	for id in Analysis.candidates(): valid.append(group[id])
	for mutation in ["missing","duplicate","field","parameters","price","model","reserve","arm","pre","neutral","points","attempt","sample","goal"]:
		var bad = valid.duplicate(true)
		match mutation:
			"missing": bad.pop_back()
			"duplicate": bad.append(bad[0].duplicate(true))
			"field": bad[0].erase("model_hash")
			"parameters": bad[-1].parameters.cure = 0.8
			"price": bad[-1].parameters.cost = 3
			"model": bad[-1].model_hash = "f".repeat(64)
			"reserve": bad[-1].reserve_floor = 3
			"arm": bad[-1].arm = "observe"
			"pre": bad[-1].pre_hash = "f".repeat(64)
			"neutral": bad[1].state_hash = "f".repeat(64)
			"points": bad[-1].points += 1
			"attempt": bad[-1].decision_attempts.clear()
			"sample": bad[-1].samples.pop_back()
			"goal": bad[-1].objective.routes.orient = 1001
		check.call(not Analysis.pair_rows(bad).error.is_empty(),"Expérience incohérente rejetée : " + mutation)
		check.call(Analysis.Decisions.definition() == original,"Validation refusée sans fuite du catalogue")
	var report = Analysis.report(rows,paired.groups)
	check.call("## Contrastes à un paramètre" in report and "support_c3_r1075" in report and "Empreinte catalogue hypothétique" in report,"Rapport explicite paramètres, contrastes et provenance")
	var store = Store.new()
	store.directory = "user://tests-parameters-011"
	var files = load("res://tests/test_persistence.gd").new()
	files.clean(store)
	for name in ["pending","active","expired","neutral"]:
		var text = FileAccess.get_file_as_string("res://tests/fixtures/save-0.11-%s.json" % name)
		var decoded = store.decode(JSON.parse_string(text))
		check.call(decoded.error.is_empty(),"Vraie référence 0.11 acceptée : " + name)
		if not decoded.error.is_empty(): continue
		check.call(decoded.world.decision_profile == "0.11" and Analysis.Decisions.option("support",decoded.world).cost == 6,"Profil 0.11 conserve le prix original")
		var current_save = store.decode(store.encode(decoded.world))
		check.call(current_save.error.is_empty() and current_save.world.decision_rules == decoded.world.decision_rules and current_save.world.points == decoded.world.points,"Format 4 conserve le profil historique sans remboursement")
		if name == "pending":
			var pending = store.decode(JSON.parse_string(text)).world
			check.call(Analysis.Decisions.choose(pending,"support").is_empty() and pending.points == 17,"Décision historique en attente coûte encore six points")
		for i in range(30):
			buy(decoded.world)
			decoded.world.step()
		var reference = store.decode(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/future-0.11-%s.json" % name)))
		check.call(reference.error.is_empty(),"Futur original 0.11 valide")
		if reference.error.is_empty(): check.call(Analysis.Comparison.fingerprint(decoded.world) == Analysis.Comparison.fingerprint(reference.world) and decoded.world.decision == reference.world.decision and decoded.world.journal == reference.world.journal,"Trente journées 0.11 exactes, choix et annonces inclus")
		DirAccess.make_dir_recursive_absolute(store.directory)
		store._write(store._path("slot1"),text)
		var resumed = store.load_slot("slot1")
		check.call(resumed.error.is_empty() and FileAccess.get_file_as_string(store._path("slot1")) == text,"Lecture de référence sans réécriture")
		check.call(store.save_slot("slot1",resumed.world).is_empty() and FileAccess.get_file_as_string(store._path("slot1") + ".bak") == text,"Premier secours garde le texte de référence 0.11")
	files.clean(store)
	var world = Analysis.Comparison.World.new()
	world.start("boreale",2042,null,null,"degel2042","normal",null,null,"",true)
	check.call(world.decision_profile == "0.12" and Analysis.Decisions.option("support",world).cost == 3,"Nouvelle partie attachée au tarif 0.12")
	Analysis.configure("support_c0_r1000")
	check.call(Analysis.Decisions.option("support",world).cost == 3,"Une partie existante conserve son catalogue face aux expériences")
	Analysis.Decisions._definition = original.duplicate(true)
	for i in range(28): world.step()
	Analysis.Decisions.choose(world,"support")
	var encoded = store.encode(world)
	for mutation in ["missing","unknown","empty","historical","legacy_injected"]:
		var bad = encoded.duplicate(true)
		match mutation:
			"missing": bad.erase("decision_profile")
			"unknown": bad.decision_profile = "unknown"
			"empty": bad.decision_profile = ""
			"historical": bad.decision_profile = "0.11"
			"legacy_injected": bad.format = 3; bad.content = Store.LEGACY_11_HASH
		check.call(not store.decode(bad).error.is_empty(),"Profil incompatible rejeté : " + mutation)
