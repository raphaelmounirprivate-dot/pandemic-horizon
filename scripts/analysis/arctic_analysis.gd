extends RefCounted
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")
const Analysis = preload("res://scripts/analysis/objective_comparison.gd")
const ID = "arctic_relays"
const UPGRADES = ["polar","seasonal","resilience","transmission","mobility","discretion"]

static func policies() -> Dictionary:
	var result = Comparison.policies()
	result.saisonnier = ["polar","seasonal","transmission","mobility","discretion"]
	result.polaire_diffusion = ["polar","transmission","seasonal","mobility","discretion"]
	result.resilience_precoce = ["polar","resilience","seasonal","transmission","mobility","discretion"]
	result.saisonnier_discret = ["polar","seasonal","discretion","transmission","mobility"]
	return result

static func purchases(pairs: Array, id: String, deadline: int) -> Dictionary:
	var stats = {"count":pairs.size(),"acquired":0,"in_time":0,"min_day":500,"max_day":0}
	for pair in pairs:
		for purchase in pair.active.purchases:
			if purchase.id == id:
				stats.acquired += 1
				if purchase.day <= deadline: stats.in_time += 1
				stats.min_day = mini(stats.min_day,int(purchase.day))
				stats.max_day = maxi(stats.max_day,int(purchase.day))
	return stats

static func purchase_row(label: String, stats: Dictionary) -> String:
	var days = "—" if stats.acquired == 0 else "%d–%d" % [stats.min_day,stats.max_day]
	return "| %s | %d | %d | %d | %s |\n" % [label,stats.count,stats.acquired,stats.in_time,days]

static func report(pairs: Array) -> String:
	var item = Comparison.World.Objectives.definition(ID)
	var text = "# Stratégies climatiques — prototype %s\n\n" % ProjectSettings.get_setting("application/config/version")
	text += "Moteur : `%s`. Empreinte du contenu : `%s`.\n\n" % [Engine.get_version_info().string,Comparison.Store.new().content_hash()]
	text += "Commande : `dev.ps1 BalanceArctic`. Dégel, départ Boréale, difficultés facile/normale/difficile, graines 7/42/2042 et quinze politiques (onze historiques, quatre climatiques précoces). Une tentative du premier achat manquant avant chaque journée ; points légaux ; arrêt au résultat principal, limite de 500 jours.\n\n"
	text += "Chaque paire active/désactive Relais arctiques, à graine, difficulté et décisions identiques. Appariement et empreintes suivent les mêmes contrôles que BalanceObjectives : seul le suivi, ses annonces et la date d'enregistrement sont exclus. Toute dérive, paire manquante ou dupliquée est une erreur. Les témoins ne sont pas des échecs facultatifs.\n\n"
	text += "Quotas : 1 000 unités sortantes par route, Orient J36–54 et Centrale J39–54. Les compteurs sont plafonnés et figés à la résolution : ils ne mesurent pas les flux totaux ultérieurs. Deux succès = objectif et victoire principale ; objectif seul ou victoire seule séparent les deux résultats. Les dates moyennes concernent uniquement les réussites. Les taux décrivent cet échantillon, pas des joueurs humains ; aucun coefficient n'est modifié.\n\n"
	text += "## Ensemble\n\n" + Analysis.header("Échantillon") + Analysis.table_row("Dégel",Analysis.summarize(pairs))
	var groups: Dictionary = {}
	for pair in pairs:
		var key = pair.active.difficulty + " / " + pair.active.policy
		if not groups.has(key): groups[key] = []
		groups[key].append(pair)
	text += "\n## Résultats par difficulté et politique\n\n" + Analysis.header("Difficulté / politique") + Analysis.group_rows(groups)
	text += "\n## Achats réellement effectués\n\nTous les achats jusqu'à la fin principale sont comptés. La colonne avant échéance compte ceux effectués au plus tard au jour %d ; un achat plus tardif peut aider la victoire principale mais arrive après la fenêtre de l'objectif. Aucun achat absent n'entre dans les dates min–max.\n\n" % item.deadline
	text += "| Difficulté / politique / achat | Parties | Acquis | Avant échéance inclus | Jours acquis min–max |\n| --- | ---: | ---: | ---: | ---: |\n"
	var keys = groups.keys()
	keys.sort()
	for key in keys:
		for id in UPGRADES: text += purchase_row(key + " / " + id,purchases(groups[key],id,int(item.deadline)))
	text += "\n## Politiques\n\n"
	var orders = policies()
	for policy in orders:
		var ids: Array[String] = []
		for id in orders[policy]: ids.append(id)
		text += "- `%s` : %s.\n" % [policy,"aucun achat" if ids.is_empty() else " → ".join(ids)]
	return text
