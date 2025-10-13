extends EffectUpgrade

class_name MagnetEffectUpgrade

@export var magnet_radius: float = 200.0
@export var magnet_force: float = 10.0
func apply_effect():
	super.apply_effect()

func remove_effect():
	super.remove_effect()

func _on_player_process(delta: float):
	# Attract pickups within radius
	for pickup in GameContext.root.get_nodes_in_group("Pickups"):
		if GameContext.player.global_position.distance_to(pickup.global_position) < magnet_radius:
			var direction = (GameContext.player.global_position - pickup.global_position).normalized()
			pickup.global_position += direction * magnet_force * delta