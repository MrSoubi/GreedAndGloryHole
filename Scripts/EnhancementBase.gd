@abstract class_name EnhancementBase
extends Resource

# --- Propriétés de Configuration (Métadonnées pour le Designer) ---
@export var title: String = "Nom de l'Amélioration"
@export var description: String = "Description de l'effet de l'amélioration."
@export var icon: Texture2D # Référence à l'icône dans l'UI
@export var cost: int = 100 # Coût en monnaie
@export var is_permanent: bool = false # Si True: acheté dans le Hub; si False: bonus temporaire de Run

## Applique l'effet au composant cible.
@abstract func apply_effect(target: Node)

## Retire l'effet du composant cible.
@abstract func remove_effect(target: Node)
