extends CanvasLayer

# TransitionManager.gd : Gère les transitions visuelles (fondu, etc.)
# À ajouter comme autoload dans le projet Godot

signal transition_finished

@export var fade_rect: ColorRect
var duration := 0.5
var is_transitioning := false

func _ready():
	if fade_rect:
		fade_rect.color = Color(0, 0, 0, 0)
		fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fade_rect.z_index = 1000
		fade_rect.visible = false

func fade_out(time := duration):
	if is_transitioning:
		return
	is_transitioning = true
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.modulate = Color(1, 1, 1, 1)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, time)
	tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
	emit_signal("transition_finished")

func fade_in(time := duration):
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 1)
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, time)
	tween.finished.connect(_on_fade_in_finished)

func _on_fade_in_finished():
	fade_rect.visible = false
	is_transitioning = false
