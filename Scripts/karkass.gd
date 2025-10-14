
class_name Karkass
extends Node3D

# --- Propriétés de la Karkass ---
@export var total_currency: float
var currency_left: float

var player_in_area: bool = false
var harvest_timer: float = 0.0

func _ready() -> void:
	currency_left = total_currency

func _process(delta: float) -> void:
	if player_in_area and currency_left > 0:
		# Récupérer les stats du joueur
		var player_harvest_rate = PlayerStatsManager.harvest_rate.current_value
		var player_harvest_power = PlayerStatsManager.harvest_power.current_value

		harvest_timer += delta
		var interval = 1.0 / player_harvest_rate if player_harvest_rate > 0 else 1.0
		while harvest_timer >= interval and currency_left > 0:
			harvest_timer -= interval
			var amount = min(player_harvest_power, currency_left)
			# Ajouter la monnaie au joueur (supposons une méthode add_currency sur le joueur)
			CurrencyManager.currency += amount
			currency_left -= amount
			if currency_left <= 0:
				queue_free()
				break

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == GameContext.player:
		player_in_area = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == GameContext.player:
		player_in_area = false
