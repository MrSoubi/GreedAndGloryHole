extends Node

# FeedbackManager.gd
# Handles visual and audio feedbacks (VFX, SFX, camera shake, etc.)

enum FeedbackType {
	HEAL,
	DAMAGE,
	POWERUP
}

@export var vfx_heal: PackedScene
@export var vfx_damage: PackedScene
@export var vfx_powerup: PackedScene

var vfx_scenes = {
	FeedbackType.HEAL: vfx_heal,
	FeedbackType.DAMAGE: vfx_damage,
	FeedbackType.POWERUP: vfx_powerup,
}

func play_feedback(position: Vector2, feedback_type: int) -> void:
	# Play VFX if available
	if feedback_type in vfx_scenes and vfx_scenes[feedback_type]:
		var vfx = vfx_scenes[feedback_type].instantiate()
		vfx.global_position = position
		get_tree().current_scene.add_child(vfx)
	# Play SFX via AudioManager
	if Engine.has_singleton("AudioManager"):
		AudioManager.play_sfx(position, feedback_type)
	elif has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(position, feedback_type)
	# Add camera shake or other feedback here as needed
