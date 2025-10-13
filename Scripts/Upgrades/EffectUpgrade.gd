extends BaseUpgrade

class_name EffectUpgrade

# EffectUpgrade: pour upgrades à effet personnalisé (explosions, auto-fire, etc)

func apply_effect():
	super.apply_effect()
	# À surcharger dans les enfants pour la logique d'effet

func remove_effect():
	super.remove_effect()
	# À surcharger dans les enfants pour la logique d'effet
