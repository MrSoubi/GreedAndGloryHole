class_name MovementStatsComponent
extends Node

# Référence au profil de base (PlayerMovementProfile.tres)
@export var base_profile: MovementProfile 

# --- Variables d'Empilement des Améliorations ---
# Ces variables sont modifiées par les Enhancement Resources (upgrades permanents ou de run).

var walk_speed_additive: float = 0.0
var jump_power_multiplier: float = 1.0

# --- Getteurs : Le Calcul des Stats Finales (DDD en action) ---

func get_final_walk_speed() -> float:
	return base_profile.base_speed + walk_speed_additive

func get_final_jump_power() -> float:
	return base_profile.base_jump_power * jump_power_multiplier

## Fonction hypothétique pour l'application des upgrades
# func apply_upgrade_effect(upgrade_resource: EnhancementBase):
#    upgrade_resource.apply_effect(self)
