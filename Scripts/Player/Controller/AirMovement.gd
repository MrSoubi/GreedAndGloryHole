extends PlayerMovementStrategy

# Mouvement en l'air
class_name AirMovement

func move(controller: CharacterBody3D, delta: float) -> void:
	var direction = controller.get("input_direction")
	var normal_speed = PlayerStatsManager.walk_speed.current_value
	var air_control = PlayerStatsManager.air_control.current_value
	var slide_jump_gravity_mult = controller.SLIDE_JUMP_GRAVITY_MULTIPLIER
	var jump_power = PlayerStatsManager.jump_force.current_value
	var gravity = controller.gravity

	var applied_gravity = gravity
	if controller.is_slide_jumping:
		applied_gravity *= slide_jump_gravity_mult

	controller.current_velocity.y = controller.velocity.y - applied_gravity * delta
	controller.current_velocity.x = lerp(controller.current_velocity.x, direction.x * normal_speed, delta * air_control)
	controller.current_velocity.z = lerp(controller.current_velocity.z, direction.z * normal_speed, delta * air_control)

	var horizontal_momentum = Vector3(controller.velocity.x, 0, controller.velocity.z).length()
	if horizontal_momentum > normal_speed:
		controller.current_velocity.x = controller.velocity.x
		controller.current_velocity.z = controller.velocity.z

	if Input.is_action_just_pressed("jump") and controller.jump_count < PlayerStatsManager.consecutive_jumps.current_value:
		controller.jump_count += 1
		controller.current_velocity.y = jump_power
		controller.is_slide_jumping = false
		EventBus.on_player_jumped.emit(controller.jump_count)
