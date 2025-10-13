extends BaseUpgrade

class_name StatBoostUpgrade

# Stat boost: simple stat increase, resets every run
# Example: +1 level to a main stat

func apply_effect():
	super.apply_effect()
	# Additional logic if needed

func remove_effect():
	super.remove_effect()
