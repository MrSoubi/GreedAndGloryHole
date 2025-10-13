class_name BaseUpgrade
extends Resource

@export var stat_to_upgrade : StatDefinition

@export var additive : float
@export var multiplier : float

var upgraded_stat : StatDefinition

func apply_effect():
	if not is_instance_valid(stat_to_upgrade):
		push_error("Trying to apply effect of an upgrade to an invalid StatDefinition.")
		return
	
	upgraded_stat = stat_to_upgrade
	stat_to_upgrade.additive += additive
	stat_to_upgrade.multiplier += multiplier
	
func remove_effect():
	upgraded_stat.additive -= additive
	upgraded_stat.multiplier -= multiplier
	upgraded_stat = null
