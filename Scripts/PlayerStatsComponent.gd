class_name PlayerStatsComponent
extends Node

@export var base_profile: PlayerProfile # Contient les valeurs de base

# --- Le Conteneur Abstraité pour toutes les stats ---
# Clé = Nom de la stat (String), Valeur = StatEnhancementDefinition
var stats_runtime: Dictionary = {} 

func _ready():
	# Initialisation de toutes les stats définies par le profil de base
	initialize_stats()

# --- Le Getter Générique (Abstraction) ---
## Récupère la valeur finale d'une statistique donnée
func get_final_stat(stat_name: String) -> float:
	
	# 1. Récupère la valeur de base (via le PlayerProfile.gd)
	var base_value: float = get_base_value(stat_name)
	
	# 2. Récupère l'agrégateur d'améliorations
	if stats_runtime.has(stat_name):
		var stat_def: StatEnhancementDefinition = stats_runtime[stat_name]
		
		# 3. Applique la formule générique : (Base + Additive) * Multiplier
		return (base_value + stat_def.additive) * stat_def.multiplier
	
	# Retourne la valeur de base si la stat n'a pas été initialisée dans le runtime
	return base_value


# --- Initialisation Automatique (Le Secret) ---
func initialize_stats():
	# Parcourt les propriétés du PlayerProfile pour trouver les stats de base
	for stat_name in base_profile.get_property_list():
		# Nous supposons que toutes les propriétés dans le profil sont des floats/ints de stat
		
		# Le nom de la propriété du profil DOIT correspondre au nom de la stat demandée ("base_speed" -> "speed")
		if stat_name.name.begins_with("base_"):
			var generic_stat_name = stat_name.name.trim_prefix("base_") # Ex: "base_speed" devient "speed"
			
			# Crée une nouvelle instance de l'agrégateur (Data Driven)
			var new_stat_aggregator = StatEnhancementDefinition.new()
			
			stats_runtime[generic_stat_name] = new_stat_aggregator
			
			# Optionnel: Si vous voulez que la stat elle-même soit un Resource persistante,
			# remplacez .new() par l'instanciation de cette Resource.


# --- Fonction utilitaire pour récupérer la valeur de base ---
func get_base_value(stat_name: String) -> float:
	var property_name = "base_" + stat_name # ex: "speed" -> "base_speed"
	
	# ATTENTION ! Gros risque d'erreur ici, à travailler !
	return base_profile.get(property_name)
