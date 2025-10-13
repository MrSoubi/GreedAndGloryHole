class_name PlayerController
extends CharacterBody3D

# --- Configuration Physique (Constantes immuables) ---
const SENSITIVITY: float = 0.002
const SLIDE_DOWNWARD_FORCE: float = 20.0 
const MIN_SLOPE_ANGLE: float = 5.0 
const DECELERATION_RATE: float = 10.0 # Taux de freinage au sol
const ACCELERATION_ON_SLOPE: float = 100.0
const SLIDE_JUMP_GRAVITY_MULTIPLIER: float = 0.8
const SLIDE_MAX_SPEED: float = 1000.0
const SLIDE_DECELERATION_RATE: float = 0.1
const SLIDE_MAX_ACCELERATION: float = 2.0

@export_category("Physic")
@export var gravity: float = 9.8 


# --- Référence au Composant de Stats (Composition) ---

@export_category("References")
@export var camera_pivot: Node3D

# --- Stratégies de mouvement assignables dans l'éditeur ---
@export var ground_strategy: Resource
@export var air_strategy: Resource
@export var slide_strategy: Resource


var movement_strategies = {}
var current_movement_strategy = null

# --- Variables d'État du Controller ---
var jump_count: int = 0
var current_velocity: Vector3 = Vector3.ZERO
var is_sliding: bool = false
var is_slide_jumping: bool = false
var input_direction: Vector3 = Vector3.ZERO

# --- Timers pour les events ---
var air_time: float = 0.0
var slide_time: float = 0.0

# --- Initialisation / Input ---


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if !is_instance_valid(camera_pivot):
		push_error("ERREUR: Le PlayerController nécessite une référence valide à une Camera3D.")
	# Chargement dynamique des stratégies de mouvement

	# Les stratégies de mouvement sont assignées via l'éditeur
	movement_strategies = {
		"ground": ground_strategy,
		"air": air_strategy,
		"slide": slide_strategy
	}
	current_movement_strategy = movement_strategies["ground"]

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
	# 1. Récupération de l'input directionnel
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var last_movement_strategy = current_movement_strategy

	# 2. Sélection de la stratégie de mouvement
	if is_sliding:
		current_movement_strategy = movement_strategies["slide"]
	elif not is_on_floor():
		current_movement_strategy = movement_strategies["air"]
	else:
		current_movement_strategy = movement_strategies["ground"]

	# 3. Application de la stratégie
	current_movement_strategy.move(self, delta)
	velocity = current_velocity
	move_and_slide()

	# 4. Gestion des timers
	if not is_on_floor():
		air_time += delta
	else:
		air_time = 0.0

	if is_sliding:
		slide_time += delta
	else:
		slide_time = 0.0

	# 5. Événements d'atterrissage
	if last_movement_strategy == movement_strategies["air"] and is_on_floor():
		EventBus.on_player_landed.emit(air_time, jump_count)