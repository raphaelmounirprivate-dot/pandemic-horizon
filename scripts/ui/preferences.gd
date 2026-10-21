extends RefCounted
## Comfort, audio and display preferences (settings.cfg) and the shared interface theme.
const INK = Color("e1eee9")
const MUTED = Color("a7c4c9")
const ACCENT = Color("69d6bd")

static func load_into(ui) -> void:
	var config = ConfigFile.new()
	if config.load(ui.settings_path) != OK: return
	ui.reduced_motion = config.get_value("comfort","reduced_motion",false) == true
	ui.reading_large = config.get_value("comfort","reading_large",false) == true
	ui.sounds_enabled = config.get_value("audio","enabled",false) == true
	var level = config.get_value("audio","volume",0.35)
	ui.sound_volume = clampf(float(level),0,1) if typeof(level) in [TYPE_FLOAT,TYPE_INT] and is_finite(float(level)) else 0.35
	if config.get_value("display","fullscreen",false) == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

static func save_from(ui) -> void:
	var config = ConfigFile.new()
	config.load(ui.settings_path)
	config.set_value("display","fullscreen",DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	config.set_value("comfort","reduced_motion",ui.reduced_motion)
	config.set_value("comfort","reading_large",ui.reading_large)
	config.set_value("audio","enabled",ui.sounds_enabled)
	config.set_value("audio","volume",ui.sound_volume)
	if is_instance_valid(ui.feedback): ui.feedback.configure(ui.sounds_enabled,ui.sound_volume)
	if config.save(ui.settings_path) != OK and is_instance_valid(ui.status_label):
		ui.status_label.text = "Préférences appliquées ; enregistrement impossible sur ce PC."

static func theme() -> Theme:
	var design = Theme.new()
	design.default_font_size = 18
	design.set_color("font_color", "Label", INK)
	design.set_color("font_color", "Button", INK)
	design.set_color("font_disabled_color", "Button", MUTED)
	design.set_constant("separation", "VBoxContainer", 8)
	design.set_constant("separation", "HBoxContainer", 16)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("254954") if state in ["hover", "pressed"] else Color("16333e")
		style.set_corner_radius_all(6)
		style.content_margin_left = 16
		style.content_margin_right = 16
		style.content_margin_top = 10
		style.content_margin_bottom = 10
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.border_color = ACCENT
			style.set_border_width_all(2)
		design.set_stylebox(state, "Button", style)
	return design
