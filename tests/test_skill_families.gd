extends RefCounted
const World = preload("res://scripts/simulation/world.gd")
const Skills = preload("res://scripts/ui/skill_presenter.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
func run(tree: SceneTree, check: Callable) -> void:
	var world = World.new()
	world.start("boreale",2042,null,null,"degel2042","normal",null,null,"",false,true,null,true)
	var before = Store.new().encode(world)
	var seen: Array = []
	for family in Skills.catalog():
		for id in family.skills:
			check.call(id not in seen and world.evolutions.has(id),"Famille sans doublon ni compétence inconnue : "+id)
			seen.append(id)
	check.call(seen.size() == 24 and Skills.ordered(world).size() == 24,"24 compétences réparties et toutes visibles")
	for id in world.evolutions:
		check.call(not Skills.family(id).is_empty(),"Famille nommée pour chaque compétence")
		var lineage = Skills.lineage(world,id)
		for ancestor in lineage:
			for required in world.evolutions[ancestor].requires: check.call(required in lineage,"Ascendance transitive complète")
		check.call(not Skills.comparison(world,id).is_empty(),"Comparaison avant/après non vide")
		for reason in ["","Prérequis : test","Incompatible : test","Acquise"]:
			var detail = Skills.details(world,id,reason)
			check.call(world.evolutions[id].name in detail and world.evolutions[id].effect in detail and "Hors climat/aléas" in detail,"Fiche complète et coefficients qualifiés dans chaque état")
	check.call(Skills.lineage(world,"air_relay").has("transmission"),"Escales montre aussi Diffusion, pas seulement son parent")
	check.call("22.0 % → 30.0 %" in Skills.comparison(world,"transmission"),"Croissance additive en points de pourcentage")
	check.call("×1.00 → ×0.70" in Skills.comparison(world,"discretion"),"Remède multiplicatif")
	check.call("×1.00 → ×0.50" in Skills.comparison(world,"regional_reserves"),"Pénalité de résilience explicite")
	var after = Store.new().encode(world)
	before.erase("saved_at")
	after.erase("saved_at")
	check.call(before == after,"Consultation sans mutation des règles, RNG, fonds ou sauvegarde")
	world.points = 1000
	world.purchase("transmission")
	check.call("30.0 % → 32.5 %" in Skills.comparison(world,"relay"),"Comparaison tient compte des achats précédents")
	check.call("30.0 % → 30.0 %" in Skills.comparison(world,"transmission"),"Compétence acquise : coefficients actuels sans double application")
	# Behavior after extracting views: callbacks still update controller state.
	var ui = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(ui)
	ui.set_process(false)
	ui.autosave_enabled = false
	ui.show_new_game(2)
	ui.reactive_choice.button_pressed = true
	check.call(ui.reactive_mode and ui.crises_mode and ui.advanced_mode,"Menu extrait conserve les dépendances d'options")
	ui.start_game()
	await tree.process_frame
	var funds = ui.world.points
	ui.open_evolution("discretion")
	check.call("Discrétion" in ui.evolution_detail.text and "×0.70" in ui.evolution_detail.text and ui.world.points == funds,"Fiche lisible et sélection gratuite")
	ui.close_evolution()
	ui.show_settings()
	await tree.process_frame
	var motion = ui.body.find_child("motion",true,false)
	motion.button_pressed = not ui.reduced_motion
	check.call(ui.reduced_motion == motion.button_pressed,"Paramètres extraits : callback conservé")
	ui.show_game()
	ui.open_overview()
	await tree.process_frame
	check.call(ui.screen == "overview" and ui.paused and is_instance_valid(ui.history_chart),"Bilan extrait : navigation et pause conservées")
	ui.close_overview()
	check.call(ui.screen == "game","Retour du bilan extrait")
	ui.queue_free()
	await tree.process_frame
