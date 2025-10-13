extends EffectUpgrade

class_name ExplosiveJumpEffectUpgrade

@export var shockwave_radius: float = 150.0
@export var shockwave_force: float = 600.0

var _player = null

func apply_effect():
	super.apply_effect()
	_player = GameContext.player
	EventBus.on_player_jump.connect(_on_player_jump)
	
func remove_effect():
	super.remove_effect()
	EventBus.on_player_jump.disconnect(_on_player_jump)

func _on_player_jump():
	_player = GameContext.player
	for enemy in GameContext.enemies:
		if _player.global_position.distance_to(enemy.global_position) < shockwave_radius:
			var direction = (enemy.global_position - _player.global_position).normalized()
			enemy.global_position += direction * shockwave_force * 0.01 # Push enemy away
	# TODO: Add visual feedback for shockwave