extends SceneTree
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const POLICIES = {
	"mobilite":["transmission", "mobility", "discretion"],
	"croissance":["transmission", "relay", "focus", "retention", "discretion"],
	"discretion":["discretion", "transmission", "relay", "timing", "delay"]
}
# 0.26 crises offer different ids: "first"/"second" pick the costed answers by position.
const RESPONSES = {"strategy-0.25":["anchor", "surge", "observe", "context"], "strategy-0.26":["first", "second", "observe", "context"]}
const STARTS = ["boreale", "centrale", "meridien", "savane", "orient"]

func _initialize() -> void: call_deferred("run")

static func pick(world, response: String) -> String:
	if response in ["first", "second"]: return World.Strategy.choices(world)[0 if response == "first" else 1].id
	if response != "context": return response
	if not World.Strategy.modern(world): return "anchor" if world.cure > 45 or world.coverage() > 0.65 else "surge"
	return World.Strategy.choices(world)[0 if world.cure <= 45 and world.coverage() <= 0.65 else 1].id

static func play(agent: String, scenario: String, difficulty: String, seed_value: int, policy: String, response: String, profile: String = World.Strategy.CURRENT, start: String = "") -> Dictionary:
	var world = World.new()
	if start.is_empty(): start = "centrale" if scenario == "fragile2042" else "boreale"
	var error = world.start_with({"start":start, "scenario":scenario, "difficulty":difficulty, "seed":seed_value, "agent":agent, "strategy":profile})
	if not error.is_empty(): return {"error":error}
	var purchases: Array = []
	var situations: Array = []
	var first_detection: int = -1
	for day in range(500):
		if World.Strategy.pending(world):
			if World.Strategy.modern(world): situations.append(world.strategy.open.crisis)
			if not World.Strategy.choose(world, pick(world, response)).is_empty(): World.Strategy.choose(world, "observe")
		for id in POLICIES[policy]:
			if id not in world.purchased:
				if world.purchase(id).is_empty(): purchases.append({"id":id, "day":world.day})
				break
		world.step()
		if first_detection < 0 and world.detected_count() > 0: first_detection = world.day
		if not world.outcome.is_empty(): break
	if world.outcome.is_empty(): return {"error":"Partie sans résultat à J500."}
	return {"error":"", "profile":profile, "agent":agent, "scenario":scenario, "difficulty":difficulty, "start":start, "seed":seed_value, "policy":policy, "response":response, "outcome":world.outcome, "days":world.day, "cure":world.cure, "coverage":world.coverage(), "purchases":purchases, "situations":situations, "first_detection":first_detection, "decisions":world.strategy.choices.duplicate(true), "simulation_seconds":world.day * World.Strategy.rules_of(world).day_seconds}

func run() -> void:
	var profile: String = World.Strategy.PROFILE if "--legacy" in OS.get_cmdline_user_args() else World.Strategy.CURRENT
	var rows: Array = []
	for agent in ["nacre", "pulse", "veil"]:
		for scenario in ["standard", "degel2042", "fragile2042"]:
			# Standard varies the start region; Dégel and Réseaux fragiles impose theirs.
			for start in (STARTS if scenario == "standard" and profile != World.Strategy.PROFILE else [""]):
				for difficulty in ["normal", "hard"]:
					for seed_value in [7, 42, 2042, 11113, 8675309]:
						for policy in POLICIES:
							for response in RESPONSES[profile]:
								var result = play(agent, scenario, difficulty, seed_value, policy, response, profile, start)
								if not result.error.is_empty():
									printerr(result.error)
									quit(1)
									return
								rows.append(result)
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var file = FileAccess.open("res://build/qa/%s-balance.json" % profile, FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string, "hash":Store.new().strategy_hash(profile), "rows":rows}, "\t"))
	file.close()
	print("BALANCE: %d parties %s, aucun résultat manquant" % [rows.size(), profile])
	quit()
