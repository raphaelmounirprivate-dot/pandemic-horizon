extends SceneTree
const Balance = preload("res://scripts/analysis/balance_strategy.gd")
const Strategy = preload("res://scripts/gameplay/strategy.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var baseline = Strategy.rules().duplicate(true)
	var rows: Array = []
	for base in [0.9, 0.95, 1.0]:
		Strategy.cached = baseline.duplicate(true)
		Strategy.cached.base_exchange = 1.5
		Strategy.cached.choices[0].exchange = 0.2
		Strategy.cached.choices[0].cure = base
		Strategy.cached.choices[1].cure = 1.2
		for agent in ["nacre", "pulse", "veil"]:
			for scenario in ["standard", "degel2042", "fragile2042"]:
				for difficulty in ["normal", "hard"]:
					for policy in Balance.POLICIES:
						for response in ["anchor", "surge", "observe"]:
							var row = Balance.play(agent, scenario, difficulty, 2042, policy, response)
							row["anchor_cure"] = base
							rows.append(row)
	Strategy.cached = baseline
	var file = FileAccess.open("res://build/qa/strategy-parameters.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(rows))
	file.close()
	print("PARAMETERS: %d parties hypothétiques, aucun monde sauvegardé" % rows.size())
	quit()
