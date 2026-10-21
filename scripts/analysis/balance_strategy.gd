extends SceneTree
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const POLICIES = {
	"mobilite":["transmission", "mobility", "discretion"],
	"croissance":["transmission", "relay", "focus", "retention", "discretion"],
	"discretion":["discretion", "transmission", "relay", "timing", "delay"]
}

func _initialize() -> void: call_deferred("run")

static func play(agent: String, scenario: String, difficulty: String, seed_value: int, policy: String, response: String) -> Dictionary:
	var world = World.new()
	var error = world.start_with({"start":"centrale" if scenario == "fragile2042" else "boreale", "scenario":scenario, "difficulty":difficulty, "seed":seed_value, "agent":agent})
	if not error.is_empty(): return {"error":error}
	var purchases: Array = []
	for day in range(500):
		if World.Strategy.pending(world):
			var choice = response
			if response == "context": choice = "anchor" if world.cure > 45 or world.coverage() > 0.65 else "surge"
			if not World.Strategy.choose(world, choice).is_empty(): World.Strategy.choose(world, "observe")
		for id in POLICIES[policy]:
			if id not in world.purchased:
				if world.purchase(id).is_empty(): purchases.append({"id":id, "day":world.day})
				break
		world.step()
		if not world.outcome.is_empty(): break
	if world.outcome.is_empty(): return {"error":"Partie sans résultat à J500."}
	return {"error":"", "agent":agent, "scenario":scenario, "difficulty":difficulty, "seed":seed_value, "policy":policy, "response":response, "outcome":world.outcome, "days":world.day, "cure":world.cure, "coverage":world.coverage(), "purchases":purchases, "decisions":world.strategy.choices.duplicate(true), "simulation_seconds":world.day * World.Strategy.rules().day_seconds}

func run() -> void:
	var rows: Array = []
	for agent in ["nacre", "pulse", "veil"]:
		for scenario in ["standard", "degel2042", "fragile2042"]:
			for difficulty in ["normal", "hard"]:
				for seed_value in [7, 42, 2042, 11113, 8675309]:
					for policy in POLICIES:
						for response in ["anchor", "surge", "observe", "context"]:
							var result = play(agent, scenario, difficulty, seed_value, policy, response)
							if not result.error.is_empty():
								printerr(result.error)
								quit(1)
								return
							rows.append(result)
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var file = FileAccess.open("res://build/qa/strategy-balance.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string, "hash":Store.new().strategy_hash(), "rows":rows}, "\t"))
	file.close()
	print("BALANCE: %d parties, aucun résultat manquant" % rows.size())
	quit()
