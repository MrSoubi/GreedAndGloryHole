class_name SpeedMultiplierEnhancement
extends EnhancementBase

# --- Propriétés Spécifiques de l'Effet (Modifiable par le Designer) ---
# Le montant du bonus (ex: 0.15 pour +15%)
@export var speed_multiplier_value: float = 0.15 

## Implémentation du contrat : Applique le bonus au composant cible.
func apply_effect(target: Node):
	# On utilise 'as' pour tenter de caster et s'assurer que la cible est bien le bon type
	var movement_comp: PlayerStatsComponent = target as PlayerStatsComponent
	
	if movement_comp:
		# Multiplie la variable d'empilement du composant
		movement_comp.walk_speed_multiplier += speed_multiplier_value
	else:
		push_error("Erreur: La cible fournie pour SpeedMultiplierEnhancement n'est pas un MovementStatsComponent.")


## Implémentation du contrat : Retire le bonus (essentiel pour les bonus de run).
func remove_effect(target: Node):
	var movement_comp: PlayerStatsComponent = target as PlayerStatsComponent
	
	if movement_comp:
		# Annule la modification
		movement_comp.walk_speed_multiplier -= speed_multiplier_value
