extends Node

var upgrades : Array[Upgrade]

func add_upgrade(upgrade : Upgrade):
	if not is_instance_valid(upgrade):
		push_error("Trying to add an invalid upgrade.")
		return
	
	upgrades.append(upgrade)
	upgrade.apply_effect()

func remove_upgrade(upgrade : Upgrade):
	upgrade.remove_effect()
	upgrades.erase(upgrade)

func remove_all_upgrades():
	upgrades.clear()
