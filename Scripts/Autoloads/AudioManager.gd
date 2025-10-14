extends Node

# AudioManager.gd
# Handles all SFX and music playback

# Use the same FeedbackType enum as FeedbackManager for consistency
enum FeedbackType {
	HEAL,
	DAMAGE,
	POWERUP
}

@export var sfx_heal: AudioStream
@export var sfx_damage: AudioStream
@export var sfx_powerup: AudioStream

var sfx_files = {
	FeedbackType.HEAL: sfx_heal,
	FeedbackType.DAMAGE: sfx_damage,
	FeedbackType.POWERUP: sfx_powerup,
}

func play_sfx(position: Vector2, feedback_type: int) -> void:
	if feedback_type in sfx_files:
		var sfx = AudioStreamPlayer2D.new()
		sfx.stream = sfx_files[feedback_type]
		sfx.global_position = position
		get_tree().current_scene.add_child(sfx)
		sfx.play()
		# Optionally, queue_free after finished
		sfx.connect("finished", Callable(sfx, "queue_free"))

# Add music and global audio controls as needed
