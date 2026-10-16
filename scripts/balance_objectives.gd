extends SceneTree
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")
const Analysis = preload("res://scripts/analysis/objective_comparison.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var csv = FileAccess.open("res://build/qa/balance-objectives.csv", FileAccess.WRITE)
	if csv == null:
		printerr("CSV d'objectifs inaccessible.")
		quit(1)
		return
	csv.store_csv_line(["scenario","difficulty","start","seed","policy","outcome","days","coverage","score","purchases_json","objective_id","objective_json","state_hash"])
	var regions = JSON.parse_string(FileAccess.get_file_as_string(Comparison.World.DATA_PATH)).regions
	var observations: Array = []
	var policies = Comparison.policies(false)
	var ticks = 0
	for difficulty in ["easy", "normal", "hard"]:
		for start in regions:
			for seed_value in [7,42,2042]:
				for policy in policies:
					for objective_id in [Analysis.ID, ""]:
						var row = Comparison.play(start.id, seed_value, "standard", difficulty, policies[policy], 500, objective_id)
						if not row.error.is_empty():
							printerr(row.error)
							csv.close()
							quit(1)
							return
						row.policy = policy
						observations.append(row)
						ticks += row.ticks
						csv.store_csv_line([row.scenario,row.difficulty,row.start,str(row.seed),policy,row.outcome,str(row.days),str(row.coverage),str(row.score),JSON.stringify(row.purchases),objective_id,JSON.stringify(row.objective),row.state_hash])
		print("OBJECTIVE_PROGRESS: %s terminé." % difficulty)
	csv.close()
	var paired = Analysis.pair_rows(observations)
	if not paired.error.is_empty():
		printerr(paired.error)
		quit(1)
		return
	var report = FileAccess.open("res://build/qa/balance-objectives.md", FileAccess.WRITE)
	if report == null:
		printerr("Rapport d'objectifs inaccessible.")
		quit(1)
		return
	report.store_string(Analysis.report(paired.pairs))
	report.close()
	print("OBJECTIVE_BALANCE: %d parties ; %d paires sans dérive ; %d pas." % [observations.size(),paired.pairs.size(),ticks])
	print(Analysis.table_row("Standard",Analysis.summarize(paired.pairs)))
	print("Rapports : build/qa/balance-objectives.csv et build/qa/balance-objectives.md.")
	quit()
