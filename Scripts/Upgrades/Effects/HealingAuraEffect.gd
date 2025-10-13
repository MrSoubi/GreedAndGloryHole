extends EffectUpgrade

class_name HealingAuraEffectUpgrade

@export var heal_amount: float = 2.0
@export var heal_interval: float = 0.5
@export var duration: float = 8.0

var _heal_timer: Timer = null
var _player = null

func apply_effect():
	super.apply_effect()
	_player = GameContext.player
	_heal_timer = Timer.new()
	GameContext.root.add_child(_heal_timer)
	_heal_timer.wait_time = heal_interval
	_heal_timer.one_shot = false
	_heal_timer.timeout.connect(_on_heal)
	_heal_timer.start()

func remove_effect():
	super.remove_effect()
	if _heal_timer:
		_heal_timer.queue_free()

func _on_heal():
	if _player:
		if _player.health < _player.max_health:
			_player.health = min(_player.health + heal_amount, _player.max_health)
			# TODO: Add visual glow effect
