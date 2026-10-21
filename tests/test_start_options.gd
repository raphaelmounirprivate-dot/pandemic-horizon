extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")

func stable(store, world) -> Dictionary:
	var result = store.encode(world)
	result.erase("saved_at")
	return result

func run(check: Callable) -> void:
	var store = Store.new()
	# Each case pairs the named options with the historical positional call.
	var cases = [
		[{"start": "boreale"}, func(w): return w.start("boreale")],
		[{"start": "boreale", "seed": 42, "difficulty": "hard"}, func(w): return w.start("boreale",42,null,null,"standard","hard")],
		[{"start": "boreale", "objective": "first_relays"}, func(w): return w.start("boreale",2042,null,null,"standard","normal",null,null,"first_relays")],
		[{"start": "boreale", "scenario": "degel2042", "objective": "arctic_relays", "decision": true}, func(w): return w.start("boreale",2042,null,null,"degel2042","normal",null,null,"arctic_relays",true)],
		[{"start": "boreale", "seed": 777, "scenario": "degel2042", "expanded": true}, func(w): return w.start("boreale",777,null,null,"degel2042","normal",null,null,"",false,true)],
		[{"start": "centrale", "seed": 7, "scenario": "fragile2042", "crises": true}, func(w): return w.start("centrale",7,null,null,"fragile2042","normal",null,null,"",false,false,null,true)],
		[{"start": "centrale", "scenario": "fragile2042", "crises": true, "reactive": true}, func(w): return w.start("centrale",2042,null,null,"fragile2042","normal",null,null,"",false,true,null,true,null,true)],
	]
	for item in cases:
		var named = World.new()
		var positional = World.new()
		var label = JSON.stringify(item[0])
		check.call(named.start_with(item[0]).is_empty() and item[1].call(positional).is_empty(), "Options nommées acceptées : " + label)
		check.call(stable(store,named) == stable(store,positional), "Options nommées = appel positionnel : " + label)
		for day in range(40):
			named.step()
			positional.step()
		check.call(named.regions == positional.regions and named.rng.state == positional.rng.state and named.journal == positional.journal, "Options nommées : rejeu identique sur 40 jours : " + label)
	# Errors coming from start() itself are passed through unchanged.
	check.call(World.new().start_with({"start": "boreale", "scenario": "fragile2042"}) == World.new().start("boreale",2042,null,null,"fragile2042"), "Refus de start() transmis tel quel")
	var world = World.new()
	world.start_with({"start": "boreale", "seed": 9001})
	for day in range(12): world.step()
	var before = stable(store,world)
	var invalid = {
		"absent": {},
		"start vide": {"start": ""},
		"start non texte": {"start": 3},
		"clé inconnue": {"start": "boreale", "graine": 7},
		"faute de frappe": {"start": "boreale", "scenarios": "degel2042"},
		"graine flottante": {"start": "boreale", "seed": 7.0},
		"graine texte": {"start": "boreale", "seed": "7"},
		"booléen entier": {"start": "boreale", "reactive": 1},
		"difficulté non texte": {"start": "boreale", "difficulty": null},
		"clé non texte": {"start": "boreale", 4: true},
	}
	for name in invalid:
		check.call(not world.start_with(invalid[name]).is_empty(), "Option de partie refusée : " + name)
		check.call(stable(store,world) == before, "Option refusée sans mutation : " + name)
	check.call(not World.validate_start_options(null).is_empty() and not World.validate_start_options([]).is_empty(), "Options non dictionnaire refusées")
	check.call(World.validate_start_options({"start": "boreale", "regions_source": [], "crises_source": 5}).is_empty(), "Sources laissées à la validation de start()")
	check.call(World.START_OPTIONS.size() == 16, "Seize options, dont le profil stratégique facultatif")
