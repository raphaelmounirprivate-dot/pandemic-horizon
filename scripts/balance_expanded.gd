extends SceneTree
const World = preload("res://scripts/simulation/world.gd")
const POLICIES = {
	"discretion":["discretion","transmission","mobility"],
	"mobility":["transmission","mobility","discretion"],
	"maritime":["transmission","mobility","sea_logistics","discretion"],
	"network":["transmission","mobility","network","discretion","relay"],
	"growth":["transmission","relay","focus","discretion","mobility"]}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var rows: Array = []
	for scenario in ["standard","degel2042"]:
		for difficulty in ["easy","normal","hard"]:
			for seed_value in [7,42,2042,777,9001]:
				for profile in ["classic","enriched"]:
					for policy in POLICIES:
						if profile == "classic" and policy in ["network","growth"]: continue
						var world = World.new()
						var objective = "arctic_relays" if scenario == "degel2042" else "first_relays"
						var error = world.start("boreale",seed_value,null,null,scenario,difficulty,null,null,objective,false,profile == "enriched")
						if not error.is_empty():
							printerr(error)
							quit(1)
							return
						for day in range(500):
							for id in POLICIES[policy]:
								if id not in world.purchased:
									world.purchase(id)
									break
							world.step()
							if not world.outcome.is_empty(): break
						rows.append({"scenario":scenario,"difficulty":difficulty,"seed":seed_value,"profile":profile,"policy":policy,"outcome":world.outcome,"day":world.day,"cure":world.cure,"coverage":world.coverage(),"optional":world.objective.status,"purchases":world.purchase_history.duplicate(true)})
	var raw = FileAccess.open("res://build/qa/expanded-balance.json",FileAccess.WRITE)
	raw.store_string(JSON.stringify(rows,"  "))
	var report = "# Mesures du profil enrichi 0.18\n\n240 parties : deux scénarios, trois difficultés, cinq graines (7, 42, 2042, 777, 9001), trois politiques communes aux deux profils et deux propres au profil enrichi. Départ Boréale, objectifs facultatifs actifs, décision logistique désactivée pour isoler le catalogue. Achats légaux, ordre strict, horizon 500 jours. Aucune réserve injectée.\n\nExploration déterministe, pas validation humaine ni preuve d'optimalité. Les essais joueurs restent à faire. Les coefficients ne sont pas ajustés automatiquement.\n\n| Scénario | Difficulté | Profil | Politique | Victoires/5 | Objectif/5 | Remède final moyen | Jour final moyen |\n| --- | --- | --- | --- | --- | --- | --- | --- |\n"
	for scenario in ["standard","degel2042"]:
		for difficulty in ["easy","normal","hard"]:
			for profile in ["classic","enriched"]:
				for policy in POLICIES:
					var group = rows.filter(func(row): return row.scenario == scenario and row.difficulty == difficulty and row.profile == profile and row.policy == policy)
					if group.is_empty(): continue
					var wins = 0
					var goals = 0
					var cure = 0.0
					var days = 0.0
					for row in group:
						wins += int(row.outcome == "victory")
						goals += int(row.optional == "completed")
						cure += row.cure
						days += row.day
					report += "| %s | %s | %s | %s | %d | %d | %.2f %% | %.1f |\n" % [scenario,difficulty,profile,policy,wins,goals,cure/group.size(),days/group.size()]
	report += "\n## Achats observés, normale et graine 2042\n\n"
	for row in rows:
		if row.difficulty != "normal" or row.seed != 2042: continue
		var events: Array[String] = []
		for purchase in row.purchases: events.append("J%d %s (%d pts)" % [purchase.day,purchase.id,purchase.cost])
		report += "- %s / %s / %s : %s.\n" % [row.scenario,row.profile,row.policy,", ".join(events)]
	report += "\nTraces complètes : `build/qa/expanded-balance.json` (hors Git), script reproductible `scripts/balance_expanded.gd`. Les défaites peuvent inclure une réussite facultative. Comparer les profils uniquement sur les mêmes scénarios, graines et politiques communes. Les politiques enrichies sont des alternatives, sans témoin classique de même liste d'achats.\n"
	var output = FileAccess.open("res://docs/EQUILIBRAGE-0.18-ENRICHI.md",FileAccess.WRITE)
	output.store_string(report)
	print("EXPANDED_BALANCE: %d parties, rapport Markdown produit." % rows.size())
	quit()
