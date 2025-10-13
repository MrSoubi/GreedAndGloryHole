extends BaseUpgrade

class_name EquipmentUpgrade

# Equipment: permanent, meta modifier, limited slots, saved between runs
@export var is_permanent := true
@export var slot : int = 0 # For slot management if needed

func apply_effect():
	super.apply_effect()
	# Add custom equipment logic here

func remove_effect():
	super.remove_effect()
