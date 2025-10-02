class_name MovementProfile
extends Resource

# --- Statistiques de Vitesse de Base ---
@export var base_speed: float = 5.0

# --- Statistiques de Saut ---
@export var base_jump_power: float = 10.0
@export var max_air_control: float = 5.0 # Contrôle en l'air (lerp rate)

# --- Glissade (Slide) ---
@export var slide_impulse_speed: float = 15.0 
@export var slide_max_speed: float = 30.0 
@export var slide_deceleration_rate: float = 5.0
@export var slide_jump_gravity_multiplier: float = 0.5 # Gravité réduite lors du saut de glissade
