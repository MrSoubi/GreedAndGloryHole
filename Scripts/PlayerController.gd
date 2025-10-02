class_name PlayerController
extends CharacterBody3D

# --- Configuration Physique (Constantes immuables) ---
const SENSITIVITY: float = 0.002
const SLIDE_DOWNWARD_FORCE: float = 20.0 
const MIN_SLOPE_ANGLE: float = 5.0 
const DECELERATION_RATE: float = 10.0 # Taux de freinage au sol
const ACCELERATION_ON_SLOPE: float = 10.0

@export_category("Physic")
@export var gravity: float = 9.8 

# --- Référence au Composant de Stats (Composition) ---
@export_category("References")
@export var movement_stats_comp: PlayerStatsComponent 
@export var camera_pivot: Node3D 

# --- Variables d'État du Controller ---
var current_velocity: Vector3 = Vector3.ZERO
var is_sliding: bool = false
var is_slide_jumping: bool = false

# --- Debug values ---
var d_speed: float
var d_is_jumping: bool
var d_is_sliding: bool
var d_is_slide_jumping: bool


# --- Initialisation / Input ---

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if !is_instance_valid(movement_stats_comp):
		push_error("ERREUR: Le PlayerController nécessite une référence valide au MovementStatsComponent.")
		set_process(false)
	# La vérification de camera_pivot a été omise dans l'original fourni, mais je la garde pour l'exemple
	if !is_instance_valid(camera_pivot):
		push_error("ERREUR: Le PlayerController nécessite une référence valide à une Camera3D.")

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y( -event.relative.x * SENSITIVITY)
		var new_rotation_x = camera_pivot.rotation.x - event.relative.y * SENSITIVITY
		new_rotation_x = clamp(new_rotation_x, deg_to_rad(-90), deg_to_rad(90))
		camera_pivot.rotation.x = new_rotation_x
	
	# Gestion du focus de la fenêtre (uniquement en éditeur)
	if OS.has_feature("editor"):
		if Input.is_action_just_pressed("quit") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event is InputEventMouseButton and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# --- Logique de Jeu (Mouvement) ---

func _physics_process(delta: float):
	# --- 1. Récupération des Inputs et Stats (DDD) ---
	var normal_speed: float = movement_stats_comp.get_final_stat(PlayerStatConstants.SPEED)
	var jump_power: float = movement_stats_comp.get_final_stat(PlayerStatConstants.JUMP_POWER)
	var slide_jump_gravity_mult: float = movement_stats_comp.base_profile.slide_jump_gravity_multiplier
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# --- 2. GESTION DU FLUX DE MOUVEMENT ---

	if is_sliding:
		# Si en glissade, la gestion de l'état est prioritaire
		if handle_slide_state(delta, normal_speed, jump_power):
			return # La glissade a géré le mouvement (move_and_slide())
	
	if not is_on_floor():
		handle_air_movement(delta, normal_speed, direction, slide_jump_gravity_mult)
	else:
		handle_ground_movement(delta, normal_speed, jump_power, direction)

	# --- 3. Finaliser le Mouvement (Application) ---
	velocity = current_velocity
	move_and_slide()
	
	# --- 4. Debug ---
	d_speed = velocity.length()
	d_is_slide_jumping = is_slide_jumping
	d_is_sliding = is_sliding
	d_is_jumping = not is_on_floor() and not d_is_slide_jumping


# ======================================
# --- FONCTIONS DE GESTION DES ÉTATS ---
# ======================================

## Gère la logique complète de la glissade (déclenchement, momentum, accélération)
func handle_slide_state(delta: float, normal_speed: float, jump_power: float) -> bool:
	
	# Récupération des valeurs pour la glissade
	var slide_max_speed: float = movement_stats_comp.base_profile.slide_max_speed
	var slide_decel_rate: float = movement_stats_comp.base_profile.slide_deceleration_rate
	var min_slope_rad: float = deg_to_rad(MIN_SLOPE_ANGLE)
	
	# --- SAUT PENDANT LA GLISSADE ---
	if Input.is_action_just_pressed("jump"):
		is_sliding = false
		is_slide_jumping = true
		current_velocity = Vector3(velocity.x, 0, velocity.z)
		current_velocity.y = jump_power
		velocity = current_velocity
		move_and_slide()
		return true

	# --- FIN DE GLISSADE ---
	if not Input.is_action_pressed("slide") or not is_on_floor():
		is_sliding = false
		var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
		current_velocity = horizontal_vel.normalized() * min(horizontal_vel.length(), normal_speed) 
		return false
		
	# --- GLISSADE ACTIVE ---
	else:
		current_velocity.y = -SLIDE_DOWNWARD_FORCE # Ancrage au sol
		
		var floor_normal: Vector3 = get_floor_normal()
		var slope_angle: float = acos(floor_normal.dot(Vector3.UP))
		var horizontal_vel = Vector3(current_velocity.x, 0, current_velocity.z)
		var horizontal_speed = horizontal_vel.length()
		
		# Logique de Pente / Accélération
		var slope_vector: Vector3 = (Vector3.DOWN - Vector3.DOWN.project(floor_normal)).normalized()
		var is_descending: bool = horizontal_vel.dot(slope_vector) > 0.01
		
		if slope_angle > min_slope_rad and is_descending:
			# Cas A : Accélération en descente
			var accel_amount: float = slope_angle * ACCELERATION_ON_SLOPE * delta
			current_velocity += slope_vector * accel_amount 
			
			horizontal_vel = Vector3(current_velocity.x, 0, current_velocity.z)
			if horizontal_vel.length() > slide_max_speed:
				current_velocity = horizontal_vel.normalized() * slide_max_speed
				current_velocity.y = -SLIDE_DOWNWARD_FORCE
				
		else:
			# Cas B : Décélération (plat/montée)
			if horizontal_speed > normal_speed:
				var decel_amount = lerp(horizontal_speed, normal_speed, delta * slide_decel_rate)
				current_velocity = horizontal_vel.normalized() * decel_amount
				current_velocity.y = -SLIDE_DOWNWARD_FORCE
			else:
				is_sliding = false
				current_velocity = horizontal_vel.normalized() * normal_speed
				current_velocity.y = 0.0
				return false # La glissade se termine, on revient au flux normal
		
		# Application du mouvement de glissade et sortie
		velocity = current_velocity
		move_and_slide()
		return true


## Gère le mouvement lorsque le joueur est au sol (marche, saut, déclenchement glissade)
func handle_ground_movement(delta: float, normal_speed: float, jump_power: float, direction: Vector3):
	current_velocity.y = 0.0 # Annuler la gravité au sol
	
	# --- DÉCLENCHEMENT DE LA GLISSADE ---
	if Input.is_action_pressed("slide") and direction != Vector3.ZERO:
		is_sliding = true
		current_velocity = direction
		current_velocity.y = -SLIDE_DOWNWARD_FORCE # Ancrage initial pour démarrer la glissade
		
	# --- MOUVEMENT NORMAL ---
	else:
		if direction:
			current_velocity.x = direction.x * normal_speed
			current_velocity.z = direction.z * normal_speed
		else:
			# Décélération normale au sol
			current_velocity.x = lerp(current_velocity.x, 0.0, delta * DECELERATION_RATE)
			current_velocity.z = lerp(current_velocity.z, 0.0, delta * DECELERATION_RATE)

		# Saut (normal) 
		if Input.is_action_just_pressed("jump"):
			current_velocity.y = jump_power
			is_slide_jumping = false


## Gère le mouvement lorsque le joueur est en l'air (gravité, momentum, contrôle)
func handle_air_movement(delta: float, normal_speed: float, direction: Vector3, slide_jump_gravity_mult: float):
	
	# Gravité Différentielle (utilise le modificateur DDD si Slide Jump)
	var applied_gravity = gravity
	if is_slide_jumping:
		applied_gravity *= slide_jump_gravity_mult
	
	current_velocity.y = velocity.y - applied_gravity * delta 
	
	# Maintien du momentum XZ et contrôle en l'air (utilisation du DDD air_control)
	var air_control = movement_stats_comp.base_profile.max_air_control
	current_velocity.x = lerp(current_velocity.x, direction.x * normal_speed, delta * air_control)
	current_velocity.z = lerp(current_velocity.z, direction.z * normal_speed, delta * air_control)
	
	# Maintien du momentum si la vitesse était supérieure à la vitesse normale lors du décollage
	var horizontal_momentum = Vector3(velocity.x, 0, velocity.z).length()
	if horizontal_momentum > normal_speed:
		current_velocity.x = velocity.x
		current_velocity.z = velocity.z
