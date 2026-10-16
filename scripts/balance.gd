extends SceneTree
## Reproducible automated exploration, not a human difficulty rating.
const World = preload("res://scripts/simulation/world.gd")
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")
const POLICIES = {
	"attente": [],
	"discretion": ["discretion", "transmission", "mobility"],
	"diffusion": ["transmission", "discretion", "mobility"],
	"mobilite": ["transmission", "mobility", "discretion"],
	"polaire": ["polar", "transmission", "discretion", "seasonal", "mobility", "resilience"],
	"terrestre": ["transmission", "mobility", "land_network", "discretion"],
	"aerien": ["transmission", "mobility", "air_bridge", "discretion"],
	"maritime": ["transmission", "mobility", "sea_logistics", "discretion"]
}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var policies = POLICIES.duplicate(true)
	for choice in Comparison.CHOICES:
		policies[choice + "_discretion_avant"] = ["transmission", "mobility", "discretion", Comparison.CHOICES[choice]]
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var csv = FileAccess.open("res://build/qa/balance.csv", FileAccess.WRITE)
	if csv == null:
		quit(1)
		return
	csv.store_csv_line(["scenario", "difficulty", "start", "seed", "policy", "outcome", "days", "coverage", "score", "purchases_json"])
	var observations: Array = []
	var regions = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH)).regions
	var aggregate: Dictionary = {}
	var winning_starts: Dictionary = {}
	var total = 0
	var ticks = 0
	var total_usec = 0
	var max_usec = 0
	for scenario_id in ["standard", "degel2042"]:
		for difficulty_id in ["easy", "normal", "hard"]:
			for start in regions:
				if scenario_id == "degel2042" and start.id != "boreale": continue
				for seed_value in [7, 42, 2042]:
					for policy in policies:
						if scenario_id == "standard" and policy == "polaire": continue
						var result = Comparison.play(start.id, seed_value, scenario_id, difficulty_id, policies[policy])
						if not result.error.is_empty():
							printerr(result.error)
							quit(1)
							return
						result.policy = policy
						observations.append(result)
						total_usec += result.total_usec
						max_usec = maxi(max_usec, result.max_usec)
						ticks += result.ticks
						csv.store_csv_line([scenario_id, difficulty_id, start.id, str(seed_value), policy, result.outcome, str(result.days), str(result.coverage), str(result.score), JSON.stringify(result.purchases)])
						var group = scenario_id + "/" + difficulty_id + "/" + policy
						if not aggregate.has(group): aggregate[group] = {"wins":0, "losses":0, "min_day":500, "max_day":0}
						var row = aggregate[group]
						if result.outcome == "victory":
							row.wins += 1
							winning_starts[scenario_id + "/" + difficulty_id + "/" + start.id] = true
						else: row.losses += 1
						row.min_day = mini(row.min_day, result.days)
						row.max_day = maxi(row.max_day, result.days)
						total += 1
	csv.close()
	var paired = Comparison.pair_rows(observations)
	if not paired.error.is_empty():
		printerr(paired.error)
		quit(1)
		return
	var report = FileAccess.open("res://build/qa/balance-comparison.md", FileAccess.WRITE)
	if report == null:
		printerr("Rapport de comparaison inaccessible.")
		quit(1)
		return
	report.store_string(Comparison.report(paired.pairs))
	report.close()
	print("PAIRS: %d comparaisons à départ et graine identiques." % paired.pairs.size())
	for group in aggregate:
		print("%s : %d V / %d D ; %d–%d jours" % [group, aggregate[group].wins, aggregate[group].losses, aggregate[group].min_day, aggregate[group].max_day])
	var missing: Array[String] = []
	for scenario_id in ["standard", "degel2042"]:
		for difficulty_id in ["easy", "normal", "hard"]:
			for start in regions:
				if scenario_id == "degel2042" and start.id != "boreale": continue
				var key = scenario_id + "/" + difficulty_id + "/" + start.id
				if not winning_starts.has(key): missing.append(key)
	print("BALANCE: %d parties ; %d pas ; moyenne %.3f ms/pas ; maximum observé %.3f ms/pas" % [total, ticks, float(total_usec) / ticks / 1000, max_usec / 1000.0])
	print("Départs sans victoire observée parmi ces politiques : " + ("aucun" if missing.is_empty() else ", ".join(missing)))
	print("Rapports : build/qa/balance.csv et build/qa/balance-comparison.md. Ces politiques ne représentent pas des joueurs humains.")
	quit()
