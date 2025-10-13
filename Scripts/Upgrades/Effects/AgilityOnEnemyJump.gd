extends "res://Scripts/Upgrades/EffectUpgrade.gd"

class_name AgilityOnEnemyJumpUpgrade

# +0.1% d'agilité à chaque fois que le joueur saute sur un ennemi
@export var agility_stat : StatDefinition
@export var percent_increase : float = 0.001 # 0.1%

func apply_effect():
	super.apply_effect()
	if not is_instance_valid(agility_stat):
		push_error("Agility stat is invalid for AgilityOnEnemyJumpUpgrade")
		return
	EventBus.on_player_jump_on_enemy.connect(_on_jump_on_enemy)

func remove_effect():
	super.remove_effect()
	EventBus.on_player_jump_on_enemy.disconnect(_on_jump_on_enemy)

func _on_jump_on_enemy():
	agility_stat.additive += agility_stat.base_value * percent_increase
