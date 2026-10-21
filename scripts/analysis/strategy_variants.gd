extends SceneTree
## Hypothetical strategy-0.26 variants, replaced in memory for one synchronous call and
## restored right after. No world played here is ever saved as a playable game.
const Balance = preload("res://scripts/analysis/balance_strategy.gd")
const Strategy = preload("res://scripts/gameplay/strategy.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const FAMILIES = {
	"mobility": {"base":{}, "m045":{"mobility_factor":0.45}, "m035":{"mobility_factor":0.35}, "cure115":{"mobility_cure":1.15}, "m045_cure110":{"mobility_factor":0.45, "mobility_cure":1.1}},
	# VOILE-only levers: other agents are unaffected, so only VOILE is replayed.
	"veil": {"base":{}, "det15":{"agents.veil.detection":1.5}, "det20":{"agents.veil.detection":2.0}, "cost10":{"agents.veil.discretion_cost":10}, "cost8":{"agents.veil.discretion_cost":8}, "det15_cost10":{"agents.veil.detection":1.5, "agents.veil.discretion_cost":10}},
	"discretion": {"base":{}, "d45":{"discretion.days":45}, "det22":{"discretion.detection":2.2}, "d45_det22":{"discretion.days":45, "discretion.detection":2.2}, "det22_ex1":{"discretion.detection":2.2, "discretion.exchange":1.0}}
}
const CONTEXTS = [["standard", "boreale"], ["degel2042", ""], ["fragile2042", ""]]
const SEEDS = [7, 42, 2042, 11113, 8675309]
const RESPONSES = ["first", "observe"]

func _initialize() -> void: call_deferred("run")

static func apply(rules: Dictionary, changes: Dictionary) -> Dictionary:
	var result: Dictionary = rules.duplicate(true)
	for key: String in changes:
		var path: PackedStringArray = key.split(".")
		var node: Dictionary = result
		for i: int in range(path.size() - 1): node = node[path[i]]
		node[path[-1]] = changes[key]
	return result

## Synchronous on purpose: no await, the cache is restored before returning.
static func play_variant(changes: Dictionary, agent: String, scenario: String, difficulty: String, seed_value: int, policy: String, response: String, start: String) -> Dictionary:
	var baseline: Dictionary = Strategy.rules(Strategy.CURRENT)
	var variant: Dictionary = apply(baseline, changes)
	var error: String = Strategy.validate(variant)
	if not error.is_empty(): return {"error":error}
	Strategy.cached[Strategy.CURRENT] = variant
	var row: Dictionary = Balance.play(agent, scenario, difficulty, seed_value, policy, response, Strategy.CURRENT, start)
	Strategy.cached[Strategy.CURRENT] = baseline
	return row

static func key(row: Dictionary) -> String:
	return "%s|%s|%s|%s|%d|%s|%s" % [row.agent, row.scenario, row.start, row.difficulty, row.seed, row.policy, row.response]

## Paired comparison; incomplete or duplicated cohorts are an error, not a result.
static func compare(base: Array, other: Array) -> Dictionary:
	var index: Dictionary = {}
	for row: Dictionary in base:
		if index.has(key(row)): return {"error":"Paire dupliquée."}
		index[key(row)] = row
	if other.size() != base.size(): return {"error":"Cohortes incomplètes."}
	var result: Dictionary = {"error":"", "only_base":0, "only_variant":0, "both":0, "both_lost":0, "variant_faster":0, "variant_slower":0}
	var seen: Dictionary = {}
	for row: Dictionary in other:
		if not index.has(key(row)) or seen.has(key(row)): return {"error":"Paire absente ou dupliquée."}
		seen[key(row)] = true
		var won_base: bool = index[key(row)].outcome == "victory"
		var won_other: bool = row.outcome == "victory"
		if won_base and won_other:
			result.both += 1
			if row.days < index[key(row)].days: result.variant_faster += 1
			elif row.days > index[key(row)].days: result.variant_slower += 1
		elif won_base: result.only_base += 1
		elif won_other: result.only_variant += 1
		else: result.both_lost += 1
	return result

static func wins(rows: Array, field: String) -> Dictionary:
	var result: Dictionary = {}
	for row: Dictionary in rows:
		var group: String = str(row[field]) + (" " + str(row.difficulty) if field == "policy" else "")
		if not result.has(group): result[group] = [0, 0]
		result[group][1] += 1
		if row.outcome == "victory": result[group][0] += 1
	return result

func run() -> void:
	var family: String = "mobility"
	for candidate: String in ["discretion", "veil"]:
		if "--" + candidate in OS.get_cmdline_user_args(): family = candidate
	var rows: Dictionary = {}
	for name: String in FAMILIES[family]:
		rows[name] = []
		for agent: String in (["veil"] if family == "veil" and name != "base" else ["nacre", "pulse", "veil"]):
			for context: Array in CONTEXTS:
				for difficulty: String in ["normal", "hard"]:
					for seed_value: int in SEEDS:
						for policy: String in Balance.POLICIES:
							for response: String in RESPONSES:
								var row: Dictionary = play_variant(FAMILIES[family][name], agent, context[0], difficulty, seed_value, policy, response, context[1])
								if not row.error.is_empty():
									printerr("%s : %s" % [name, row.error])
									quit(1)
									return
								row["variant"] = name
								rows[name].append(row)
	var summary: Dictionary = {}
	for name: String in rows:
		var reference: Array = rows.base.filter(func(row): return row.agent == "veil") if family == "veil" and name != "base" else rows.base
		var comparison: Dictionary = compare(reference, rows[name])
		if not comparison.error.is_empty():
			printerr(comparison.error)
			quit(1)
			return
		var veil: Array = rows[name].filter(func(row): return row.agent == "veil" and row.first_detection >= 0)
		var detection: Array = veil.map(func(row): return row.first_detection)
		detection.sort()
		summary[name] = {"changes":FAMILIES[family][name], "policy":wins(rows[name], "policy"), "agent":wins(rows[name], "agent"), "versus_base":comparison, "veil_first_detection_median":detection[detection.size() / 2] if not detection.is_empty() else -1}
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var file := FileAccess.open("res://build/qa/strategy-variants-%s.json" % family, FileAccess.WRITE)
	file.store_string(JSON.stringify({"engine":Engine.get_version_info().string, "hash":Store.new().strategy_hash(Strategy.CURRENT), "family":family, "summary":summary, "rows":rows}, "\t"))
	file.close()
	print("VARIANTS %s : %d variantes × %d parties, aucune sauvegardée" % [family, rows.size(), rows.base.size()])
	quit()
