extends SceneTree
const World = preload("res://scripts/simulation/world.gd")
const POLICIES = {
	"mobilite":["transmission","mobility","discretion"],
	"secours":["transmission","mobility","backup_links","discretion"],
	"veille":["transmission","discretion","research_watch","mobility"],
	"reserves":["transmission","relay","regional_reserves","mobility","discretion"]}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var rows: Array = []
	for scenario in ["standard","degel2042","fragile2042"]:
		for difficulty in ["normal","hard"]:
			for seed_value in [7,42,2042,777,9001]:
				for enabled in [false,true]:
					if scenario == "fragile2042" and not enabled: continue
					for policy in POLICIES:
						if not enabled and policy != "mobilite": continue
						var world = World.new()
						var error = world.start("centrale" if scenario == "fragile2042" else "boreale",seed_value,null,null,scenario,difficulty,null,null,"",false,true,null,enabled)
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
						rows.append({"scenario":scenario,"difficulty":difficulty,"seed":seed_value,"crises":enabled,"policy":policy,"outcome":world.outcome,"day":world.day,"cure":world.cure,"purchases":world.purchase_history.duplicate(true)})
	FileAccess.open("res://build/qa/crises-balance.json",FileAccess.WRITE).store_string(JSON.stringify(rows,"  "))
	var report = "# Exploration des aléas 0.20\n\n140 parties, graines 7/42/2042/777/9001, difficultés normale/difficile. Catalogue enrichi dans tous les cas. Départ Boréale pour Standard/Dégel, Centrale pour Réseaux fragiles. Achats légaux dans un ordre strict, sans réserve injectée, horizon 500 jours ; objectifs et décision logistique désactivés. Comparaison aléas activés/désactivés uniquement à politique mobilite identique sur Standard/Dégel. Les trois autres politiques ne sont pas des comparaisons isolant un seul coefficient.\n\nLes effets favorable/défavorable sont qualifiés du point de vue de la diffusion. Douze incidents tirés par graine au lancement ; le premier sac contient chacun des huit types une fois. Deux incidents peuvent se chevaucher. Aucun essai humain ni preuve de stratégie optimale.\n\n| Scénario | Difficulté | Aléas | Politique | Victoires/5 | Jour final moyen | Remède final moyen |\n| --- | --- | --- | --- | --- | --- | --- |\n"
	for scenario in ["standard","degel2042","fragile2042"]:
		for difficulty in ["normal","hard"]:
			for enabled in [false,true]:
				for policy in POLICIES:
					var group = rows.filter(func(r): return r.scenario == scenario and r.difficulty == difficulty and r.crises == enabled and r.policy == policy)
					if group.is_empty(): continue
					var wins=0
					var days=0.0
					var cure=0.0
					for row in group:
						wins += int(row.outcome == "victory")
						days += row.day
						cure += row.cure
					report += "| %s | %s | %s | %s | %d | %.1f | %.2f %% |\n" % [scenario,difficulty,"oui" if enabled else "non",policy,wins,days/group.size(),cure/group.size()]
	report += "\n## Chronologies normales, graine 2042\n\n"
	for row in rows:
		if row.seed != 2042 or row.difficulty != "normal": continue
		var purchases: Array[String] = []
		for item in row.purchases: purchases.append("J%d %s (%d pts)" % [item.day,item.id,item.cost])
		report += "- %s / aléas %s / %s : %s.\n" % [row.scenario,row.crises,row.policy,", ".join(purchases)]
	FileAccess.open("res://docs/EQUILIBRAGE-0.20-ALEAS.md",FileAccess.WRITE).store_string(report)
	print("CRISES_BALANCE: %d parties, rapport produit." % rows.size())
	quit()
