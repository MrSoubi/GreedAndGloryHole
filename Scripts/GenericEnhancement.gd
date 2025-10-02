@tool
class_name GenericEnhancement
extends EnhancementBase

var target_stat_name: String = "walk_speed"
var additive_value: float = 0.0
var multiplier_value: float = 1.0


func apply_effect(target: Node):
	# On s'assure que la cible est bien le composant de statistiques
	var stats_comp: PlayerStatsComponent = target as PlayerStatsComponent
	
	if stats_comp and stats_comp.stats_runtime.has(target_stat_name):
		# CLÉ DE LA GÉNÉRICITÉ : Trouver l'agrégateur et modifier la propriété 'additive'
		stats_comp.stats_runtime[target_stat_name].additive += additive_value
		stats_comp.stats_runtime[target_stat_name].multiplier += multiplier_value
	else:
		push_error("Erreur: Impossible d'appliquer l'effet à la stat '" + target_stat_name + "'. Cible invalide ou stat non initialisée.")

func remove_effect(target: Node):
	var stats_comp: PlayerStatsComponent = target as PlayerStatsComponent
	
	if stats_comp and stats_comp.stats_runtime.has(target_stat_name):
		stats_comp.stats_runtime[target_stat_name].additive -= additive_value
		stats_comp.stats_runtime[target_stat_name].multiplier -= multiplier_value


func _get_property_list() -> Array:
	var properties: Array = []
	
	# Récupérer la liste des noms de stats depuis l'Autoload
	var stat_names_string = PlayerStatConstants.get_stat_names_string()
	
	# Définir la propriété 'target_stat_name' avec la liste déroulante
	properties.append({
		"name": "target_stat_name",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": stat_names_string
	})
	
	# Ajouter les autres propriétés @export existantes
	properties.append({
		"name": "additive_value",
		"type": TYPE_FLOAT,
	})
	
	properties.append({
		"name": "multiplier_value",
		"type": TYPE_FLOAT,
	})
	
	return properties
