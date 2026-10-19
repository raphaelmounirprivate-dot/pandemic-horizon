extends SceneTree
const Analysis = preload("res://scripts/analysis/logistics_parameters.gd")
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	var original = Analysis.Decisions.definition()
	var rows: Array = []
	for difficulty in ["easy","normal","hard"]:
		for seed_value in [7,42,2042]:
			for policy in Analysis.Comparison.Arctic.policies():
				for id in Analysis.candidates():
					var row = Analysis.play(difficulty,seed_value,policy,id)
					if not row.error.is_empty():
						printerr(row.error)
						quit(1)
						return
					rows.append(row)
	if rows.size() != 3 * 3 * 15 * 12 or Analysis.Decisions.definition() != original:
		printerr("Cohorte incomplète ou catalogue non restauré.")
		quit(1)
		return
	var paired = Analysis.pair_rows(rows)
	if not paired.error.is_empty() or Analysis.Decisions.definition() != original:
		printerr(paired.error + " Vérifier la restauration du catalogue.")
		quit(1)
		return
	var raw = FileAccess.open("res://build/qa/balance-parameters.jsonl",FileAccess.WRITE)
	var report = FileAccess.open("res://build/qa/balance-parameters.md",FileAccess.WRITE)
	if raw == null or report == null:
		printerr("Sortie paramètres inaccessible.")
		quit(1)
		return
	for row in rows: raw.store_line(JSON.stringify(row,"",true,true))
	raw.close()
	report.store_string(Analysis.report(rows,paired.groups))
	report.close()
	print("PARAMETERS_ANALYSIS: %d parties ; %d groupes complets ; choix J28 ; catalogue restauré." % [rows.size(),paired.groups.size()])
	for id in Analysis.candidates(): print(Analysis.Comparison.table_row(id,Analysis.subset(rows,id)))
	quit()
