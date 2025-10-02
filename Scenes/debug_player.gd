extends Control

@onready var speed: Label = $VBoxContainer/Speed/Value
@onready var is_jumping: Label = $VBoxContainer/IsJumping/Value
@onready var is_sliding: Label = $VBoxContainer/IsSliding/Value
@onready var is_slide_jumping: Label = $VBoxContainer/IsJumpSliding/Value

@export var player_controller: PlayerController

func _process(delta: float) -> void:
	speed.text = str(player_controller.d_speed).left(4)
	is_jumping.text = str(player_controller.d_is_jumping)
	is_sliding.text = str(player_controller.d_is_sliding)
	is_slide_jumping.text = str(player_controller.d_is_slide_jumping)
	
