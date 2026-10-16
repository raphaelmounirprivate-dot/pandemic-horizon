extends RefCounted
## Lessons use the real world and controls. Only the training session is discarded.
const TITLES = ["Maîtriser le temps", "Lire une région", "Acheter une évolution", "Repérer la détection", "Attendre la réouverture", "Sauvegarder et reprendre"]
var stage = 0
var ready = false
var saved_slot = ""

func instruction(day: int) -> String:
	match stage:
		0: return "Appuyez sur Espace ou Reprendre : une journée passera, puis le jeu reviendra en pause."
		1: return "Sélectionnez Centrale sur la carte, à la souris ou avec Tab puis Entrée. Lisez ses statistiques à droite."
		2: return "Le temps a avancé au jour 10 pour gagner des points. Achetez Diffusion ; Mobilité exige d'abord cette évolution."
		3: return "Au jour 23, sélectionnez Boréale : sa détection déclenche une réaction locale et renforce le remède mondial."
		4:
			if day < 26: return "Reprenez jusqu'au jour 26 : deux événements ferment la route Boréale ↔ Centrale. La tempête va expirer."
			if day < 32: return "La tempête est finie, mais l'inspection ferme encore la route. Reprenez jusqu'au jour 32 pour la rouvrir."
			return "La route est ouverte : toutes ses fermetures ont expiré. Les autres réactions restent indépendantes."
		5: return "Ouvrez Sauvegardes, enregistrez dans un emplacement, puis chargez-le. Ces fichiers d'essai sont séparés de vos parties."
	return ""

func can_run() -> bool:
	return stage in [0, 4] and not ready

func after_step(world: RefCounted) -> bool:
	if stage == 0 and world.day >= 1:
		ready = true
		return true
	if stage == 4 and world.day in [26, 32]:
		ready = world.day == 32
		return true
	return false

func select_region(index: int, world: RefCounted) -> void:
	if stage == 1 and world.regions[index].id == "centrale": ready = true
	if stage == 3 and world.regions[index].id == "boreale" and world.regions[index].detected: ready = true

func next(world: RefCounted) -> bool:
	if not ready or stage == 5: return false
	stage += 1
	ready = false
	var target = {2: 10, 3: 23}.get(stage, world.day)
	while world.day < target and world.outcome.is_empty(): world.step()
	return true
