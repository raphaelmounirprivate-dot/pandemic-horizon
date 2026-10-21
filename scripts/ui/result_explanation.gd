extends RefCounted
## Descriptive facts only: a single playthrough cannot prove a counterfactual cause.
static func text(world: RefCounted) -> String:
	var missing: float = maxf(0.0, 90.0 - world.coverage() * 100.0)
	var margin: float = maxf(0.0, 100.0 - world.cure)
	var text: String
	match world.outcome:
		"victory": text = "Seuil de 90 %% franchi avec %.1f points de remède de marge." % margin
		"defeat_cure": text = "Remède achevé ; %.1f points de couverture manquaient pour atteindre 90 %%." % missing
		"defeat_network": text = "Échéance J60 manquée : les deux relais sont obligatoires, même si la couverture progresse."
		"defeat_extinction": text = "Plus aucun actif ; %.1f points de couverture manquaient. Les retirés ne relancent pas un foyer." % missing
		_: text = "Partie en cours."
	if not world.strategy.is_empty():
		text += " %s · %d décisions, %d points engagés." % [world.Strategy.rules().agents[world.strategy.agent].name, world.strategy.choices.size(), world.Strategy.spent(world)]
	return text
