extends SceneTree
const Arctic = preload("res://scripts/analysis/arctic_analysis.gd")
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")
const Analysis = preload("res://scripts/analysis/objective_comparison.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var csv = FileAccess.open("res://build/qa/balance-arctic.csv",FileAccess.WRITE)
	if csv == null:
		printerr("CSV arctique inaccessible.")
		quit(1)
		return
	csv.store_csv_line(["scenario","difficulty","start","seed","policy","outcome","days","coverage","score","purchases_json","objective_id","objective_json","state_hash"])
	var observations: Array = []
	var policies = Arctic.policies()
	var ticks = 0
	for difficulty in ["easy","normal","hard"]:
		for seed_value in [7,42,2042]:
			for policy in policies:
				for objective_id in [Arctic.ID,""]:
					var row = Comparison.play("boreale",seed_value,"degel2042",difficulty,policies[policy],500,objective_id)
					if not row.error.is_empty():
						printerr(row.error)
						quit(1)
						return
					row.policy = policy
					observations.append(row)
					ticks += row.ticks
					csv.store_csv_line([row.scenario,row.difficulty,row.start,str(row.seed),policy,row.outcome,str(row.days),str(row.coverage),str(row.score),JSON.stringify(row.purchases),objective_id,JSON.stringify(row.objective),row.state_hash])
	csv.close()
	if observations.size() != 3 * 3 * policies.size() * 2:
		printerr("Cohorte arctique incomplète.")
		quit(1)
		return
	var paired = Analysis.pair_rows(observations,Arctic.ID,policies)
	if not paired.error.is_empty():
		printerr(paired.error)
		quit(1)
		return
	var report = FileAccess.open("res://build/qa/balance-arctic.md",FileAccess.WRITE)
	if report == null:
		printerr("Rapport arctique inaccessible.")
		quit(1)
		return
	report.store_string(Arctic.report(paired.pairs))
	report.close()
	print("ARCTIC_ANALYSIS: %d parties ; %d paires sans dérive ; %d pas." % [observations.size(),paired.pairs.size(),ticks])
	print(Analysis.table_row("Dégel",Analysis.summarize(paired.pairs)))
	quit()
