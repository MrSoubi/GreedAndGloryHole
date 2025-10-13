
extends PlayerMovementStrategy

# Mouvement de glissade
class_name SlideMovement

func move(controller: CharacterBody3D, delta: float) -> void:
	var normal_speed = PlayerStatsManager.walk_speed.current_value
	var jump_power = PlayerStatsManager.jump_force.current_value
	var slide_max_speed = controller.SLIDE_MAX_SPEED
	var slide_decel_rate = controller.SLIDE_DECELERATION_RATE
	var min_slope_rad = deg_to_rad(controller.MIN_SLOPE_ANGLE)

	# Saut pendant la glissade
	if Input.is_action_just_pressed("jump"):
		EventBus.on_player_jumped.emit(controller.jump_count + 1)
		controller.is_sliding = false
		controller.is_slide_jumping = true
		controller.current_velocity = Vector3(controller.velocity.x, 0, controller.velocity.z)
		controller.current_velocity.y = jump_power
		controller.velocity = controller.current_velocity
		controller.move_and_slide()
		return

	# Fin de glissade
	if not Input.is_action_pressed("slide") or not controller.is_on_floor():
		if controller.is_sliding:
			EventBus.on_player_stopped_sliding.emit(controller.slide_time)
		var horizontal_vel_end = Vector3(controller.velocity.x, 0, controller.velocity.z)
		controller.is_sliding = false
		controller.current_velocity = horizontal_vel_end.normalized() * min(horizontal_vel_end.length(), normal_speed)
		return

	# Glissade active
	controller.current_velocity.y = -controller.SLIDE_DOWNWARD_FORCE
	var floor_normal = controller.get_floor_normal()
	var slope_angle = acos(floor_normal.dot(Vector3.UP))
	var horizontal_vel = Vector3(controller.current_velocity.x, 0, controller.current_velocity.z)
	var horizontal_speed = horizontal_vel.length()
	var slope_vector = (Vector3.DOWN - Vector3.DOWN.project(floor_normal)).normalized()
	var is_descending = horizontal_vel.dot(slope_vector) > 0.01

	if slope_angle > min_slope_rad and is_descending:
		var accel_amount = slope_angle * controller.ACCELERATION_ON_SLOPE * delta
		controller.current_velocity += slope_vector * accel_amount
		horizontal_vel = Vector3(controller.current_velocity.x, 0, controller.current_velocity.z)
		if horizontal_vel.length() > slide_max_speed:
			controller.current_velocity = horizontal_vel.normalized() * slide_max_speed
			controller.current_velocity.y = -controller.SLIDE_DOWNWARD_FORCE
	else:
		if horizontal_speed > normal_speed:
			var decel_amount = lerp(horizontal_speed, normal_speed, delta * slide_decel_rate)
			controller.current_velocity = horizontal_vel.normalized() * decel_amount
			controller.current_velocity.y = -controller.SLIDE_DOWNWARD_FORCE
		else:
			controller.is_sliding = false
			controller.current_velocity = horizontal_vel.normalized() * normal_speed
			controller.current_velocity.y = 0.0
