class_name PlayerProfile
extends Resource

# ATTENTION ! Toutes les variables qui sont ajoutées ici doivent l'être aussi dans PlayerStatConstants !

# --- Statistiques de Base ---
@export var base_speed: float = 5.0
@export var base_size: float = 1.0
@export var base_weight: float = 1.0

# --- Statistiques de Saut ---
@export_group("Jump")
@export var base_jump_power: float = 10.0
@export var max_air_control: float = 5.0 # Contrôle en l'air (lerp rate)
@export var max_consecutive_jumps: int = 1

# --- Glissade (Slide) ---
@export_group("Slide")
## Vitesse maximale en mode slide
@export_range(1.0, 1000.0, 0.1) var slide_max_speed: float = 30.0
## Angle maximal après lequel l'accélération en sera pas plus élevée (en degré)
@export_range(1.0, 90.0, 0.1) var slide_max_angle: float = 45.0
## Accélération maximale, atteinte lorsque la pente a un angle supérieur ou égal à slide_max_angle
@export var slide_max_acceleration: float = 2.0
## Temps maximum pour revenir à la vitesse de base après avoir relaché la touche de slide
@export var slide_to_base_speed_max_duration: float = 0.3
@export var slide_deceleration_rate: float = 5.0
@export var slide_jump_gravity_multiplier: float = 0.5 # Gravité réduite lors du saut de glissade

@export_group("Harvesting")
@export var base_harvest_range: float = 10.0
## Vitesse de récolte en unités de monnaie par seconde
@export var base_harvest_rate: float = 1.0
