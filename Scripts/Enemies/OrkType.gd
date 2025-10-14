class_name OrkType
extends EnemyType

func perform_action(enemy: Node, _delta: float) -> void:
	var player = GameContext.player
	if not player:
		return
	var direction = (player.global_transform.origin - enemy.global_transform.origin).normalized()
	enemy.velocity = direction * speed
	enemy.move_and_slide()
