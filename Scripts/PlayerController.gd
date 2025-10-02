class_name PlayerController
extends CharacterBody3D

# --- Configuration Physique (Constantes immuables) ---
const SENSITIVITY: float = 0.002
@export var gravity: float = 9.8 
const SLIDE_DOWNWARD_FORCE: float = 20.0 
const MIN_SLOPE_ANGLE: float = 5.0 
const DECELERATION_RATE: float = 10.0 # Taux de freinage au sol

# --- Référence au Composant de Stats (Composition) ---
@export var movement_stats_comp: MovementStatsComponent 
@export var camera_pivot: Node3D # Le noeud qui contient la caméra (pour la rotation)

# --- Variables d'État du Controller ---
var current_velocity: Vector3 = Vector3.ZERO
var is_sliding: bool = false
var is_slide_jumping: bool = false


# --- Initialisation / Input (inchangés) ---

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if !is_instance_valid(movement_stats_comp):
		push_error("ERREUR: Le PlayerController nécessite une référence valide au MovementStatsComponent.")
		set_process(false)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y( -event.relative.x * SENSITIVITY)
		
		var new_rotation_x = camera_pivot.rotation.x - event.relative.y * SENSITIVITY
		new_rotation_x = clamp(new_rotation_x, deg_to_rad(-90), deg_to_rad(90))
		camera_pivot.rotation.x = new_rotation_x


# --- Logique de Jeu (Mouvement) ---

func _physics_process(delta: float):
	# --- 1. Récupération des Stats FINALES (DDD) ---
	var normal_speed: float = movement_stats_comp.get_final_walk_speed()
	var jump_power: float = movement_stats_comp.get_final_jump_power()
	var slide_jump_gravity_mult: float = movement_stats_comp.base_profile.slide_jump_gravity_multiplier
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# --- 2. LOGIQUE DE GLISSADE ACTIVE ---
	if is_sliding:
		
		# Saut pendant la glissade
		if Input.is_action_just_pressed("jump"):
			is_sliding = false
			is_slide_jumping = true # Marque ce saut comme étant un saut de glissade
			current_velocity = Vector3(velocity.x, 0, velocity.z)
			current_velocity.y = jump_power
			velocity = current_velocity
			move_and_slide()
			return

		# Vitesse Max de la glissade récupérée du DDD
		var slide_max_speed: float = movement_stats_comp.base_profile.slide_max_speed
		var slide_decel_rate: float = movement_stats_comp.base_profile.slide_deceleration_rate
		var slide_impulse: float = movement_stats_comp.base_profile.slide_impulse_speed

		if not Input.is_action_pressed("slide") or not is_on_floor():
			is_sliding = false
			var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
			current_velocity = horizontal_vel.normalized() * min(horizontal_vel.length(), normal_speed) 
			
		else:
			# Logique d'accélération/décélération (simplifiée ici pour l'espace, la logique complète des pentes est gardée en tête)
			
			# Application de l'ancrage au sol
			current_velocity.y = -SLIDE_DOWNWARD_FORCE
			
			# Simuler l'accélération/décélération...
			var horizontal_vel = Vector3(current_velocity.x, 0, current_velocity.z)
			var horizontal_speed = horizontal_vel.length()
			
			# Ici irait la logique complexe de Pente / Accélération
			# ... (omise pour le récapitulatif, mais c'est là qu'elle se trouverait)
			
			# Décélération sur le plat (Cas B)
			if horizontal_speed > normal_speed:
				var decel_amount = lerp(horizontal_speed, normal_speed, delta * slide_decel_rate)
				current_velocity = horizontal_vel.normalized() * decel_amount
				current_velocity.y = -SLIDE_DOWNWARD_FORCE
			else:
				is_sliding = false 
				current_velocity = horizontal_vel.normalized() * normal_speed
				current_velocity.y = 0.0

			velocity = current_velocity
			move_and_slide()
			return


	# --- 3. Gestion de l'état "Non Glissant" (Normal/Saut/Wall Jump) ---
	
	# Gravité et Wall Jump
	if not is_on_floor():
		# Gravité Différentielle (utilise la valeur DDD)
		var applied_gravity = gravity
		if is_slide_jumping:
			applied_gravity *= slide_jump_gravity_mult
		
		current_velocity.y = velocity.y - applied_gravity * delta 
		
		# Maintien du momentum
		var horizontal_momentum = Vector3(velocity.x, 0, velocity.z).length()
		if horizontal_momentum > normal_speed:
			current_velocity.x = velocity.x
			current_velocity.z = velocity.z
		
	else: # Au sol (pas en glissade)
		current_velocity.y = 0.0 
		is_slide_jumping = false 
		
		# DÉCLENCHEMENT DE LA GLISSADE
		if Input.is_action_just_pressed("slide") and direction != Vector3.ZERO:
			is_sliding = true
			var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
			var impulse_speed = max(normal_speed, horizontal_vel.length()) + movement_stats_comp.base_profile.slide_impulse_speed * 0.5
			current_velocity = direction * impulse_speed
			current_velocity.y = -SLIDE_DOWNWARD_FORCE 
			
		# Mouvement au sol normal
		elif not is_sliding:
			if direction:
				current_velocity.x = direction.x * normal_speed
				current_velocity.z = direction.z * normal_speed
			else:
				current_velocity.x = lerp(current_velocity.x, 0.0, delta * DECELERATION_RATE)
				current_velocity.z = lerp(current_velocity.z, 0.0, delta * DECELERATION_RATE)

		# Saut (normal) 
		if Input.is_action_just_pressed("jump") and not is_sliding:
			current_velocity.y = jump_power
			is_slide_jumping = false 


	# Mouvement XZ en l'air (contrôle réduit)
	if not is_on_floor():
		# Utilise le max_air_control du DDD
		current_velocity.x = lerp(current_velocity.x, direction.x * normal_speed, delta * movement_stats_comp.base_profile.max_air_control)
		current_velocity.z = lerp(current_velocity.z, direction.z * normal_speed, delta * movement_stats_comp.base_profile.max_air_control)
		
	# --- 5. Finaliser le Mouvement ---
	velocity = current_velocity
	move_and_slide()
