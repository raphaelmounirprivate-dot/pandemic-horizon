extends RefCounted

const World = preload("res://scripts/simulation/world.gd")
const Content = preload("res://scripts/gameplay/content.gd")

func clean_content() -> Dictionary:
	var content = Content.load_files()
	content.events.events = []
	content.events.detection.min_active = 1000000000
	return content

func run(check: Callable) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	var content = Content.load_files()
	check.call(Content.validate(content, data.regions, data.connections).is_empty(), "Contenu JSON valide")
	for mutation in ["cycle", "missing", "duplicate", "cost", "nan", "modifier", "duration", "fractional_day", "route", "region", "kind", "factor", "detection", "version", "requires_type", "event_duplicate"]:
		var invalid = content.duplicate(true)
		match mutation:
			"cycle": invalid.evolutions.evolutions[0].requires = ["mobility"]
			"missing": invalid.evolutions.evolutions[1].requires = ["absent"]
			"duplicate": invalid.evolutions.evolutions[1].id = "transmission"
			"cost": invalid.evolutions.evolutions[0].cost = -1
			"nan": invalid.evolutions.evolutions[0].modifiers.growth_bonus = NAN
			"modifier": invalid.evolutions.evolutions[0].modifiers = {"unknown": 1}
			"duration": invalid.events.events[0].duration = 0
			"fractional_day": invalid.events.events[0].start_day = 1.5
			"route": invalid.events.events[0].target = ["boreale", "archipel"]
			"region": invalid.events.events[2].target = "absent"
			"kind": invalid.events.events[0].kind = "absent"
			"factor": invalid.events.events[0].factor = 3
			"detection": invalid.events.detection.active_ratio = 0
			"version": invalid.events.schema_version = 99
			"requires_type": invalid.evolutions.evolutions[1].requires = "transmission"
			"event_duplicate": invalid.events.events.append(invalid.events.events[0].duplicate(true))
		check.call(not Content.validate(invalid, data.regions, data.connections).is_empty(), "Rejet contenu : " + mutation)
	var model = World.new()
	model.start("boreale")
	model.points = 100
	check.call(model.purchase("mobility").begins_with("Prérequis"), "Prérequis manquant expliqué")
	check.call(model.points == 100 and model.purchased.is_empty(), "Aucun débit si prérequis manquant")
	model.purchase("transmission")
	check.call(model.purchase("mobility").is_empty(), "Achat après prérequis")
	check.call(model.points == 78, "Deux achats au coût exact")
	# Failed reloads must preserve the existing game.
	var before = model.regions.duplicate(true)
	var invalid = content.duplicate(true)
	invalid.events.events[0].duration = -2
	check.call(not model.start("boreale", 42, data, invalid).is_empty(), "Démarrage avec contenu invalide refusé")
	check.call(model.regions == before and model.points == 78, "Échec sans mutation du monde")
	# Shifting a JSON value changes gameplay without changing source code.
	var custom = content.duplicate(true)
	custom.evolutions.evolutions[0].cost = 2
	custom.evolutions.evolutions[0].modifiers.growth_bonus = 0.12
	model.start("boreale", 1, data, custom)
	model.purchase("transmission")
	check.call(model.points == 6 and is_equal_approx(model.upgrade_modifier("growth_bonus", 0.22), 0.34), "Coût et effet pilotés par JSON")
	# Actual shipped overlapping closures, with end-exclusive boundaries.
	model.start("boreale")
	var route = ["boreale", "centrale"]
	while model.day < 17: model.step()
	check.call(model.route_is_open(route), "Route ouverte avant la tempête")
	model.step()
	check.call(not model.route_is_open(route), "Fermeture au jour 18")
	check.call(model.active_events.any(func(e): return e.id == "boreal_storm" and e.end_day == 26), "Durée huit jours")
	while model.day < 25: model.step()
	check.call(not model.route_is_open(route), "Fermetures chevauchantes au jour 25")
	model.step()
	check.call(not model.active_events.any(func(e): return e.id == "boreal_storm"), "Premier effet expiré au jour 26")
	check.call(not model.route_is_open(route), "Seconde fermeture préservée")
	check.call(not model.route_is_open(["centrale", "boreale"]), "Fermeture bidirectionnelle")
	while model.day < 31: model.step()
	check.call(not model.route_is_open(route), "Dernier jour du second effet")
	model.step()
	check.call(model.route_is_open(route), "Rétablissement après la dernière fermeture")
	check.call(model.journal.any(func(line): return line.begins_with("Jour 32 · Route rétablie")), "Rétablissement annoncé au bon jour")
	check.call(not model.journal.any(func(line): return line.begins_with("Jour 26 · Route rétablie")), "Pas de réouverture annoncée trop tôt")
	check.call(model.activate_event("boreal_storm") != "", "Événement non redéclenchable après expiration")
	check.call(model.activate_event("absent") != "", "Événement inconnu refusé")
	# Multiplicative overlap without mutation/undo of the base coefficients.
	var overlap = clean_content()
	overlap.events.events = [
		{"id": "slow_a", "name": "Ralentissement A", "kind": "growth_multiplier", "target": "boreale", "factor": 0.5, "start_day": 1, "duration": 2},
		{"id": "slow_b", "name": "Ralentissement B", "kind": "growth_multiplier", "target": "boreale", "factor": 0.8, "start_day": 2, "duration": 3},
		{"id": "cure_a", "name": "Recherche A", "kind": "cure_multiplier", "target": "global", "factor": 1.5, "start_day": 1, "duration": 2},
		{"id": "cure_b", "name": "Recherche B", "kind": "cure_multiplier", "target": "global", "factor": 2.0, "start_day": 2, "duration": 3}
	]
	model.start("boreale", 2, data, overlap)
	model.step()
	check.call(is_equal_approx(model.event_modifier("growth_multiplier", "boreale"), 0.5), "Premier ralentissement")
	check.call(is_equal_approx(model.event_modifier("growth_multiplier", "orient"), 1), "Effet régional limité à sa cible")
	model.step()
	check.call(is_equal_approx(model.event_modifier("growth_multiplier", "boreale"), 0.4), "Cumul des ralentissements")
	check.call(is_equal_approx(model.event_modifier("cure_multiplier"), 3), "Cumul de recherche")
	check.call(model.activate_event("slow_a") != "", "Activation répétée sans cumul accidentel")
	model.step()
	check.call(is_equal_approx(model.event_modifier("growth_multiplier", "boreale"), 0.8), "Expiration conserve le second ralentissement")
	check.call(is_equal_approx(model.event_modifier("cure_multiplier"), 2), "Expiration conserve le second bonus de remède")
	model.step()
	model.step()
	check.call(is_equal_approx(model.event_modifier("growth_multiplier", "boreale"), 1) and is_equal_approx(model.event_modifier("cure_multiplier"), 1), "Retour exact aux coefficients de base")
	check.call(model.active_events.is_empty(), "Aucun effet résiduel")
	# A closure replacing another on the same day must not announce reopening.
	var replacement = clean_content()
	replacement.events.events = [
		{"id": "close_a", "name": "Fermeture A", "kind": "route_closure", "target": route, "factor": 1.0, "start_day": 1, "duration": 2},
		{"id": "close_b", "name": "Fermeture B", "kind": "route_closure", "target": route, "factor": 1.0, "start_day": 3, "duration": 2}
	]
	model.start("boreale", 2, data, replacement)
	for i in range(3): model.step()
	check.call(not model.route_is_open(route), "Fermeture de remplacement le jour de l'expiration")
	check.call(not model.journal.any(func(line): return "Route rétablie" in line), "Aucune annonce de réouverture transitoire")
	# A closed edge really prevents imported cases, then reopens for propagation.
	var minimal = data.duplicate(true)
	minimal.connections = [["boreale", "centrale"]]
	var closing = clean_content()
	closing.events.events = [{"id": "closure", "name": "Fermeture", "kind": "route_closure", "target": route, "factor": 1.0, "start_day": 1, "duration": 2}]
	model.start("boreale", 2, minimal, closing)
	model.regions[0].active = 10000
	model.regions[0].healthy = 90000
	model.step()
	model.step()
	check.call(model.regions[2].active == 0, "Route fermée empêche les nouveaux cas importés")
	model.step()
	check.call(model.regions[2].active > 0, "Propagation reprend après réouverture")
	# Detection is irreversible; the reaction itself expires and is not retriggered.
	var detecting = clean_content()
	detecting.events.detection.min_active = 200
	detecting.events.detection.active_ratio = 0.001
	detecting.events.detection.reaction_duration = 2
	model.start("boreale", 7, data, detecting)
	check.call(model.detected_count() == 0 and model.cure == 0, "Aucune détection au jour zéro")
	model.step()
	check.call(model.detected_count() == 1 and model.regions[0].detected, "Détection au seuil")
	check.call(model.cure > 0, "Détection lance la recherche")
	check.call(is_equal_approx(model.event_modifier("growth_multiplier", "boreale"), 0.8), "Réaction locale effective")
	model.step()
	model.step()
	check.call(model.regions[0].detected and is_equal_approx(model.event_modifier("growth_multiplier", "boreale"), 1), "Détection conservée après expiration de la réaction")
	check.call(model.activated_events.count("reaction_boreale") == 1, "Réaction unique par région")
	# Real cure boost and real slowdown, using identical seeded states.
	var first = World.new()
	var second = World.new()
	first.start("boreale", 10, data, detecting)
	var boosting = detecting.duplicate(true)
	boosting.events.events = [{"id": "boost", "name": "Recherche", "kind": "cure_multiplier", "target": "global", "factor": 2.0, "start_day": 1, "duration": 2}]
	second.start("boreale", 10, data, boosting)
	first.step()
	second.step()
	check.call(is_equal_approx(second.cure, first.cure * 2), "Accélération réelle du remède")
	first.start("boreale", 10, data, clean_content())
	second.start("boreale", 10, data, overlap)
	first.step()
	second.step()
	check.call(second.regions[0].active < first.regions[0].active, "Ralentissement réel de la progression")
	second.start("orient")
	check.call(second.active_events.is_empty() and second.activated_events.is_empty() and second.detected_count() == 0, "Redémarrage réinitialise événements et détection")
