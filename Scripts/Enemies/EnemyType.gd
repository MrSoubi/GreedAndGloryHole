extends Resource
class_name EnemyType

@export var display_name: String = ""
@export var model_scene: PackedScene
@export var max_health: int = 100
@export var speed: float = 100.0
@export var damage: int = 10
@export var is_flying: bool = false

# Ajoute ici d'autres propriétés spécifiques (attaque, loot, etc.)

# Méthode à surcharger pour définir le comportement de l'ennemi
@warning_ignore("unused_parameter")
func perform_action(enemy: Node, delta: float) -> void:
	# Par défaut, ne fait rien. À surcharger dans les sous-ressources EnemyType.
	pass
