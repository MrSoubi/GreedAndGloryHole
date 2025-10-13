
extends PlayerMovementStrategy

# Mouvement au sol
class_name GroundMovement

func move(controller: CharacterBody3D, delta: float) -> void:
	var direction = controller.get("input_direction")
	var normal_speed = PS.walk_speed.current_value
	var jump_power = PS.jump_force.current_value
	var decel = controller.DECELERATION_RATE
	var slide_accel = controller.SLIDE_MAX_ACCELERATION
	var slide_speed = PS.slide_speed.current_value

	controller.current_velocity.y = 0.0
	controller.jump_count = 0

	if Input.is_action_pressed("slide") and direction != Vector3.ZERO:
		if !controller.is_sliding:
			EventBus.on_player_started_sliding.emit()
		controller.is_sliding = true
		controller.current_velocity = direction * slide_accel
		controller.current_velocity.y = -controller.SLIDE_DOWNWARD_FORCE
		controller.current_velocity.limit_length(slide_speed)
	else:
		if direction:
			controller.current_velocity.x = direction.x * normal_speed
			controller.current_velocity.z = direction.z * normal_speed
		else:
			controller.current_velocity.x = lerp(controller.current_velocity.x, 0.0, delta * decel)
			controller.current_velocity.z = lerp(controller.current_velocity.z, 0.0, delta * decel)

		if Input.is_action_just_pressed("jump"):
			controller.jump_count += 1
			controller.current_velocity.y = jump_power
			controller.is_slide_jumping = false
			EventBus.on_player_jumped.emit(controller.jump_count)
