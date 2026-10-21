extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Variants = preload("res://scripts/analysis/strategy_variants.gd")

func row(seed_value: int, outcome: String, days: int) -> Dictionary:
	return {"agent":"veil", "scenario":"standard", "start":"boreale", "difficulty":"normal", "seed":seed_value, "policy":"mobilite", "response":"first", "outcome":outcome, "days":days}

func run(check: Callable) -> void:
	var Strategy = World.Strategy
	var original = JSON.stringify(Strategy.rules(Strategy.CURRENT))
	var changed = Variants.apply(Strategy.rules(Strategy.CURRENT), {"discretion.days":45, "mobility_factor":0.45})
	check.call(changed.discretion.days == 45 and changed.mobility_factor == 0.45 and JSON.stringify(Strategy.rules(Strategy.CURRENT)) == original, "Variante appliquée sur une copie")
	var played = Variants.play_variant({"mobility_cure":1.15}, "veil", "standard", "normal", 7, "mobilite", "observe", "boreale")
	check.call(played.error.is_empty() and played.outcome != "", "Partie hypothétique jouée jusqu'à son issue")
	check.call(JSON.stringify(Strategy.rules(Strategy.CURRENT)) == original, "Règles du profil restaurées après la variante")
	check.call(not Variants.play_variant({"mobility_cure":0}, "veil", "standard", "normal", 7, "mobilite", "observe", "boreale").error.is_empty(), "Variante invalide refusée avant de jouer")
	check.call(JSON.stringify(Strategy.rules(Strategy.CURRENT)) == original, "Variante refusée sans toucher aux règles")
	var bad = Strategy.rules(Strategy.CURRENT).duplicate(true)
	bad.mobility_cure = -1
	check.call(not Strategy.validate(bad).is_empty(), "Contrepartie de Mobilité invalide refusée")
	var world = World.new()
	world.start_with({"start":"boreale", "agent":"veil"})
	var before = Strategy.cure(world)
	world.purchased.append("mobility")
	check.call(is_equal_approx(Strategy.cure(world), before * 1.15), "0.26 : Mobilité acquise, remède ×1,15")
	check.call(Strategy.effect_text(world, "mobility").contains("×1,15"), "0.26 : texte de Mobilité adapté au profil")
	# Absent counterpart: Mobilité leaves the cure factor exactly unchanged.
	var baseline = Strategy.rules(Strategy.CURRENT)
	var neutral = baseline.duplicate(true)
	neutral.erase("mobility_cure")
	Strategy.cached[Strategy.CURRENT] = neutral
	var unchanged = Strategy.cure(world) == before
	Strategy.cached[Strategy.CURRENT] = baseline
	check.call(unchanged, "Sans contrepartie, Mobilité ne change pas le remède")
	# VOILE levers: own detection threshold and Discrétion price, VOILE only.
	var levers = baseline.duplicate(true)
	levers.agents.veil.detection = 1.5
	levers.agents.veil.discretion_cost = 10
	Strategy.cached[Strategy.CURRENT] = levers
	var veil = World.new()
	veil.start_with({"start":"boreale", "agent":"veil"})
	var other = World.new()
	other.start_with({"start":"boreale", "agent":"nacre"})
	var veil_ok = veil.evolutions.discretion.cost == 10 and Strategy.detection(veil) == 1.5
	var other_ok = other.evolutions.discretion.cost == 14 and Strategy.detection(other) == 1.0
	levers.agents.veil.discretion_cost = 0
	var refused = not Strategy.validate(levers).is_empty()
	Strategy.cached[Strategy.CURRENT] = baseline
	check.call(veil_ok and other_ok, "Leviers de VOILE limités à VOILE")
	check.call(refused, "Prix de Discrétion invalide refusé")
	check.call(World.new().start_with({"start":"boreale", "agent":"veil"}).is_empty(), "Règles restaurées après les leviers")
	var comparison = Variants.compare([row(1, "victory", 70), row(2, "victory", 80), row(3, "defeat_cure", 90), row(4, "defeat_cure", 90)], [row(1, "victory", 65), row(2, "defeat_cure", 80), row(3, "victory", 85), row(4, "defeat_cure", 95)])
	check.call(comparison.error.is_empty() and comparison.both == 1 and comparison.variant_faster == 1, "Doubles victoires et durée comparées")
	check.call(comparison.only_base == 1 and comparison.only_variant == 1 and comparison.both_lost == 1, "Victoires propres et doubles défaites séparées")
	check.call(not Variants.compare([row(1, "victory", 70)], [row(1, "victory", 70), row(2, "victory", 70)]).error.is_empty(), "Cohortes incomplètes refusées")
	check.call(not Variants.compare([row(1, "victory", 70), row(1, "victory", 70)], [row(1, "victory", 70), row(2, "victory", 70)]).error.is_empty(), "Paire dupliquée refusée")
	check.call(not Variants.compare([row(1, "victory", 70)], [row(2, "victory", 70)]).error.is_empty(), "Paire absente refusée")
