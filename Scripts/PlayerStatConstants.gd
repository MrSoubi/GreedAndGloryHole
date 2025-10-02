@tool
class_name PlayerStatConstants
extends Node

static var Stats: Dictionary = {
	BASE_SPEED = "base_speed",
	BASE_SIZE = "base_size",
	BASE_WEIGHT = "base_weight",
	BASE_JUMP_POWER = "base_jump_power",
	MAX_AIR_CONTROL = "max_air_control",
	MAX_CONSECUTIVE_JUMPS = "max_consecutive_jumps",
	SLIDE_MAX_SPEED = "slide_max_speed",
	SLIDE_MAX_ANGLE = "slide_max_angle",
	SLIDE_MAX_ACCELERATION = "slide_max_acceleration",
	SLIDE_TO_BASE_SPEED_MAX_DURATION = "slide_to_base_speed_max_duration",
	SLIDE_DECELERATION_RATE = "slide_deceleration_rate",
	SLIDE_JUMP_GRAVITY_MULTIPLIER = "slide_jump_gravity_multiplier",
	BASE_HARVEST_RANGE = "base_harvest_range",
	BASE_HARVEST_RATE = "base_harvest_rate"
}

const SPEED = "speed"
const SIZE = "size"
const WEIGHT = "weight"
const JUMP_POWER = "jump_power"
const MAX_AIR_CONTROL = "max_air_control"
const MAX_CONSECUTIVE_JUMPS = "max_consecutive_jumps"
const SLIDE_MAX_SPEED = "slide_max_speed"
const SLIDE_MAX_ANGLE = "slide_max_angle"
const SLIDE_MAX_ACCELERATION = "slide_max_acceleration"
const SLIDE_TO_BASE_SPEED_MAX_DURATION = "slide_to_base_speed_max_duration"
const SLIDE_DECELERATION_RATE = "slide_deceleration_rate"
const SLIDE_JUMP_GRAVITY_MULTIPLIER = "slide_jump_gravity_multiplier"
const HARVEST_RANGE = "harvest_range"
const HARVEST_RATE = "harvest_rate"
	
# Fonction utilitaire pour récupérer la liste pour l'export dynamique
static func get_stat_names_string() -> String:
	var result: String = ","
	
	for key in Stats:
		result = result + Stats[key] + ","
		
	return result
