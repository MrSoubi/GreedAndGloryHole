extends Node

var stat_boosts : Array = []
var equipments : Array = []
var effect_upgrades : Array = []
var all_upgrades : Array = []

func add_upgrade(upgrade : BaseUpgrade):
	if not is_instance_valid(upgrade):
		push_error("Trying to add an invalid upgrade.")
		return

	all_upgrades.append(upgrade)

	if upgrade is StatBoostUpgrade:
		stat_boosts.append(upgrade)
	elif upgrade is EquipmentUpgrade:
		equipments.append(upgrade)
	elif upgrade is EffectUpgrade:
		effect_upgrades.append(upgrade)
	else:
		push_warning("Upgrade type inconnu ajouté.")

	upgrade.apply_effect()

func remove_upgrade(upgrade : BaseUpgrade):
	upgrade.remove_effect()
	all_upgrades.erase(upgrade)
	if upgrade is StatBoostUpgrade:
		stat_boosts.erase(upgrade)
	elif upgrade is EquipmentUpgrade:
		equipments.erase(upgrade)
	elif upgrade is EffectUpgrade:
		effect_upgrades.erase(upgrade)

func remove_all_upgrades():
	for upgrade in all_upgrades:
		upgrade.remove_effect()
	stat_boosts.clear()
	equipments.clear()
	effect_upgrades.clear()
	all_upgrades.clear()
