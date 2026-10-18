extends SceneTree
const World = preload("res://scripts/simulation/world.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var rows: Array = []
	for scenario in ["standard","degel2042","fragile2042"]:
		for difficulty in ["normal","hard"]:
			for seed_value in [7,42,2042,777,9001]:
				for policy in ["mobility","growth","wait"]:
					for choice in ["endure","detour","opportunity"]:
						var world = World.new()
						var error = world.start("centrale" if scenario == "fragile2042" else "boreale",seed_value,null,null,scenario,difficulty,null,null,"",false,true,null,true,null,true)
						if not error.is_empty():
							printerr(error)
							quit(1)
							return
						var priorities = ["transmission","mobility","discretion"] if policy == "mobility" else (["transmission","relay","focus","cohesion","discretion"] if policy == "growth" else [])
						for day in range(500):
							if World.Tactics.pending(world): World.Tactics.choose(world,choice)
							for id in priorities:
								if id not in world.purchased:
									world.purchase(id)
									break
							world.step()
							if not world.outcome.is_empty(): break
						rows.append({"scenario":scenario,"difficulty":difficulty,"seed":seed_value,"policy":policy,"requested":choice,"response":world.tactics.response.duplicate(true),"goal":world.tactics.goal.duplicate(true),"outcome":world.outcome,"day":world.day,"cure":world.cure,"coverage":world.coverage(),"purchases":world.purchase_history.duplicate(true)})
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	FileAccess.open("res://build/qa/reactive-balance.json",FileAccess.WRITE).store_string(JSON.stringify(rows,"  "))
	for scenario in ["standard","degel2042","fragile2042"]:
		for policy in ["mobility","growth","wait"]:
			for choice in ["endure","detour","opportunity"]:
				var group = rows.filter(func(r): return r.scenario == scenario and r.policy == policy and r.requested == choice)
				print("%s/%s/%s : victoire %d/%d; relais %d; J%d–%d" % [scenario,policy,choice,group.filter(func(r): return r.outcome == "victory").size(),group.size(),group.filter(func(r): return r.goal.get("status") == "completed").size(),group.map(func(r): return r.day).min(),group.map(func(r): return r.day).max()])
	quit()
