extends RefCounted
const LIMIT = 2048
static func record(world: RefCounted) -> void:
	var totals: Dictionary = world.totals()
	var sample: Dictionary = {"day":world.day,"healthy":totals.healthy,"active":totals.active,"removed":totals.removed,"cure":roundi(world.cure*100),"points":world.points,"detected":world.detected_count()}
	if not world.history.is_empty() and world.history[-1].day == world.day: world.history[-1] = sample
	else: world.history.append(sample)
	if world.history.size() > LIMIT: world.history.pop_front()
static func integer(value: Variant, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(value) and value >= 0 and value <= maximum
static func restore(world: RefCounted, data: Dictionary) -> bool:
	var samples: Variant = data.get("history",[])
	var purchases: Variant = data.get("purchase_history",[])
	if not samples is Array or samples.size() > LIMIT or not purchases is Array or purchases.size() > world.purchased.size(): return false
	var population: int = world.totals().population
	var previous: Dictionary = {}
	for sample: Variant in samples:
		if not sample is Dictionary or sample.size() != 7: return false
		for key: String in ["day","healthy","active","removed","cure","points","detected"]:
			var maximum: int = population if key in ["healthy","active","removed"] else (10000 if key == "cure" else (world.regions.size() if key == "detected" else (world.day if key == "day" else 100000)))
			if not integer(sample.get(key),maximum): return false
		if sample.healthy+sample.active+sample.removed != population: return false
		if not previous.is_empty():
			if sample.day != previous.day+1 or sample.healthy > previous.healthy or sample.removed < previous.removed or sample.cure < previous.cure or sample.detected < previous.detected: return false
		previous = sample
	if not samples.is_empty() and samples[-1].day == world.day:
		var total: Dictionary = world.totals()
		for key: String in ["healthy","active","removed"]:
			if samples[-1][key] != total[key]: return false
		if samples[-1].cure != roundi(world.cure*100) or samples[-1].detected != world.detected_count(): return false
	var purchase_ids: Array = []
	var previous_day: int = -1
	for purchase: Variant in purchases:
		if not purchase is Dictionary or purchase.size() != 3 or not purchase.get("id") is String: return false
		if not world.evolutions.has(purchase.id) or not integer(purchase.get("day"),world.day) or purchase.day < previous_day or not integer(purchase.get("cost"),100000): return false
		if purchase.cost != world.evolutions[purchase.id].cost: return false
		purchase_ids.append(purchase.id)
		previous_day = int(purchase.day)
	if not purchase_ids.is_empty() and purchase_ids != world.purchased.slice(world.purchased.size()-purchase_ids.size()): return false
	world.history = samples.duplicate(true)
	world.purchase_history = purchases.duplicate(true)
	for sample: Dictionary in world.history:
		for key: String in sample: sample[key] = int(sample[key])
	for purchase: Dictionary in world.purchase_history:
		purchase.day = int(purchase.day)
		purchase.cost = int(purchase.cost)
	return true
