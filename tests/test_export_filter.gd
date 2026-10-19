extends RefCounted
# Analysis tools must live in scripts/analysis/, excluded as a whole from the export.
func run(check: Callable) -> void:
	var loose: Array = []
	for file in DirAccess.get_files_at("res://scripts"):
		if file.ends_with(".gd"): loose.append(file)
	check.call(loose.is_empty(), "Aucun script .gd à la racine de scripts/ : %s" % ", ".join(loose))
	var preset = ConfigFile.new()
	check.call(preset.load("res://export_presets.cfg") == OK, "Préréglage d'export lisible")
	var excluded = str(preset.get_value("preset.0", "exclude_filter", "")).split(",")
	check.call("scripts/analysis/*" in excluded, "Outils d'analyse exclus de l'export par motif")
	check.call("tests/*" in excluded and "docs/*" in excluded, "Tests et documents exclus de l'export")
	var shipped: Array = []
	for folder in ["res://scripts/simulation", "res://scripts/gameplay", "res://scripts/persistence", "res://scripts/ui"]:
		for file in DirAccess.get_files_at(folder):
			if file.ends_with(".gd") and (file.begins_with("balance") or file.contains("analysis")): shipped.append(folder.path_join(file))
	check.call(shipped.is_empty(), "Aucun outil d'équilibrage dans les dossiers embarqués : %s" % ", ".join(shipped))
	check.call(DirAccess.get_files_at("res://scripts/analysis").has("balance.gd"), "Lanceurs d'équilibrage rangés dans scripts/analysis/")
