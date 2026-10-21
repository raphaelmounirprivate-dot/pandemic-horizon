extends RefCounted
const PATH = "res://data/expanded-content.json"
const PROFILE = "enriched-0.18"
static func load_file() -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))
static func build(base: Dictionary, source: Variant = null) -> Dictionary:
	var data: Variant = load_file() if source == null else source
	if not data is Dictionary or data.get("schema_version") != 1 or data.get("profile") != PROFILE: return {"error":"Profil enrichi invalide."}
	if not data.get("agent") is Dictionary or data.agent.get("id") != "nacre" or not data.agent.get("name") is String or not data.agent.get("description") is String: return {"error":"Identité d'agent invalide."}
	if data.agent.name.strip_edges().is_empty() or data.agent.name.length() > 64 or data.agent.description.strip_edges().is_empty() or data.agent.description.length() > 300: return {"error":"Description d'agent invalide."}
	if not data.get("evolutions") is Array or data.evolutions.size() != 12 or not data.get("events") is Array or data.events.size() != 8: return {"error":"Catalogue enrichi incomplet."}
	for item: Variant in data.evolutions:
		if not item is Dictionary or not item.get("short") is String or item.short.strip_edges().is_empty() or item.short.length() > 8: return {"error":"Libellé court d'évolution invalide."}
	var content: Dictionary = base.duplicate(true)
	content.evolutions.evolutions.append_array(data.evolutions.duplicate(true))
	content.events.events.append_array(data.events.duplicate(true))
	return {"error":"","content":content}
