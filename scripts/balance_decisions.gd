extends SceneTree
const Analysis = preload("res://scripts/analysis/decision_comparison.gd")
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var rows: Array = []
	for funding in Analysis.FUNDING:
		for difficulty in ["easy","normal","hard"]:
			for seed_value in [7,42,2042]:
				for policy in Analysis.Arctic.policies():
					for arm in Analysis.ARMS:
						var row = Analysis.play(difficulty,seed_value,policy,arm,funding)
						if not row.error.is_empty():
							printerr(row.error)
							quit(1)
							return
						rows.append(row)
	if rows.size() != 2 * 3 * 3 * 15 * 4:
		printerr("Cohorte incomplète.")
		quit(1)
		return
	var paired = Analysis.pair_rows(rows)
	if not paired.error.is_empty():
		printerr(paired.error)
		quit(1)
		return
	var csv = FileAccess.open("res://build/qa/balance-decisions.csv",FileAccess.WRITE)
	var report = FileAccess.open("res://build/qa/balance-decisions.md",FileAccess.WRITE)
	if csv == null or report == null:
		printerr("Sortie d'analyse inaccessible.")
		quit(1)
		return
	var fields = ["scenario","start","difficulty","seed","policy","funding","arm","outcome","days","coverage","cure","score","points","objective","decision","decision_attempts","purchases","attempts","samples","pre_hash","state_hash"]
	csv.store_csv_line(fields)
	for row in rows:
		var values: PackedStringArray = []
		for field in fields: values.append(JSON.stringify(row[field]) if row[field] is Dictionary or row[field] is Array else str(row[field]))
		csv.store_csv_line(values)
	csv.close()
	report.store_string(Analysis.report(rows,paired.groups))
	report.close()
	print("DECISION_ANALYSIS: %d parties ; %d groupes complets ; maintien sans dérive." % [rows.size(),paired.groups.size()])
	for funding in Analysis.FUNDING:
		for arm in Analysis.ARMS: print(Analysis.table_row(funding + " / " + arm,Analysis.select(rows,funding,arm)))
	quit()
