extends SceneTree
## Paired audit: observe opportunities using the resolved target at activation.
## Same seeds and legal purchases; response defaults to endure.
const World = preload("res://scripts/simulation/world.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var rows: Array = []
	var reactive = "--reactive" in OS.get_cmdline_user_args()
	for scenario in ["standard","degel2042","fragile2042"]:
		for difficulty in ["normal","hard"]:
			for seed_value in [7,42,2042,777,9001]:
				var world = World.new()
				var error = world.start("centrale" if scenario == "fragile2042" else "boreale",seed_value,null,null,scenario,difficulty,null,null,"",false,true,null,true,null,reactive)
				if not error.is_empty():
					printerr(error)
					quit(1)
					return
				var stats: Dictionary = {}
				for event in world.event_definitions:
					if event.get("source") == "crisis" and event.kind == "growth_multiplier":
						stats[event.id] = {"template":event.template,"target":event.target,"start":event.start_day,"duration":event.duration,"days":0,"opportunities":0}
				for day in range(500):
					for id in ["transmission","mobility","discretion"]:
						if id not in world.purchased:
							world.purchase(id)
							break
					# Growth reads yesterday's active/healthy values. An event cannot
					# affect local growth with zero actives or no susceptible population.
					if World.Tactics.pending(world): World.Tactics.choose(world,"endure")
					var before = world.regions.duplicate(true)
					world.step()
					for event in world.event_definitions:
						if not stats.has(event.id) or world.day < event.start_day or world.day >= event.start_day+event.duration: continue
						stats[event.id].target = event.target
						stats[event.id].days += 1
						for region in before:
							if region.id == event.target and region.active > 0 and region.healthy > 0: stats[event.id].opportunities += 1
					if not world.outcome.is_empty(): break
				for id in stats:
					var result = stats[id].duplicate()
					result.merge({"scenario":scenario,"difficulty":difficulty,"seed":seed_value,"completed":stats[id].days == stats[id].duration})
					rows.append(result)
	var completed = rows.filter(func(r): return r.completed)
	var inert = completed.filter(func(r): return r.opportunities == 0)
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var output = FileAccess.open("res://build/qa/regional-%s.json" % ("reactive" if reactive else "historical"),FileAccess.WRITE)
	if output == null:
		printerr("Audit output is not writable.")
		quit(1)
		return
	output.store_string(JSON.stringify(rows,"  "))
	print(("REACTIVE" if reactive else "HISTORICAL") + " : 30 parties; %d incidents regionaux complets, %d sans occasion de croissance." % [completed.size(),inert.size()])
	for scenario in ["standard","degel2042","fragile2042"]:
		var group = completed.filter(func(r): return r.scenario == scenario)
		print("%s: %d/%d sans occasion de croissance" % [scenario,group.filter(func(r): return r.opportunities == 0).size(),group.size()])
	quit()
