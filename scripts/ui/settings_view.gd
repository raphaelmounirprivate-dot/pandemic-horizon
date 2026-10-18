extends RefCounted
static func build(ui) -> void:
	ui.screen = "settings"
	ui.paused = true
	ui._reset_screen("Paramètres", "Préférences de confort conservées sur ce PC, sans modifier la partie.")
	var fullscreen = CheckButton.new()
	fullscreen.text = "Plein écran"
	fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen.custom_minimum_size.y = 48
	fullscreen.toggled.connect(func(enabled):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
		ui._save_preferences()
	)
	ui.body.add_child(fullscreen)
	for item in [["Réduire les mouvements",ui.reduced_motion,"motion"],["Agrandir le texte de lecture (aide, actualités et bilan)",ui.reading_large,"reading"],["Activer les sons de retour",ui.sounds_enabled,"sound"]]:
		var toggle = CheckButton.new()
		toggle.name = item[2]
		toggle.text = item[0]
		toggle.button_pressed = item[1]
		toggle.custom_minimum_size.y = 44
		toggle.toggled.connect(func(active):
			match item[2]:
				"motion": ui.reduced_motion = active
				"reading": ui.reading_large = active
				"sound": ui.sounds_enabled = active
			ui._save_preferences()
			if item[2] == "sound" and active: ui.feedback.play_cue("purchase")
		)
		ui.body.add_child(toggle)
	var volume_row = HBoxContainer.new()
	volume_row.name = "audio_volume"
	ui.body.add_child(volume_row)
	var volume_label = ui._label("Volume : %d %%" % roundi(ui.sound_volume*100),18)
	volume_label.custom_minimum_size.x = 160
	volume_row.add_child(volume_label)
	var volume = HSlider.new()
	volume.name = "volume"
	volume.min_value = 0
	volume.max_value = 1
	volume.step = 0.05
	volume.value = ui.sound_volume
	volume.custom_minimum_size = Vector2(300,44)
	volume.tooltip_text = "Volume des sons facultatifs ; zéro coupe le son."
	volume.value_changed.connect(func(level):
		ui.sound_volume = level
		volume_label.text = "Volume : %d %%" % roundi(level*100)
		ui._save_preferences()
	)
	volume_row.add_child(volume)
	ui.body.add_child(ui._label("Espace : pause · 1 / 2 / 4 : vitesse · F1 : aide · F3 : monde\nÉchap : retour · Tab / Maj + Tab : parcourir · Entrée : activer",18))
	ui.status_label = ui._label("Les mouvements réduits figent les véhicules ; la simulation continue.\nLes sons sont facultatifs : chaque action conserve son retour visuel.", 18, ui.MUTED)
	ui.body.add_child(ui.status_label)
	ui._button("Retour au menu", ui.show_menu, ui.body)
	fullscreen.grab_focus()
