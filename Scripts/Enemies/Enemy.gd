class_name Enemy
extends CharacterBody3D

@export var enemy_type: Resource # EnemyType
var health: int

func _ready():
    if enemy_type:
        health = enemy_type.max_health
        # Instancie le modèle 3D si défini
        if enemy_type.model_scene:
            var model = enemy_type.model_scene.instantiate()
            add_child(model)
    else:
        health = 100

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()

func die() -> void:
    queue_free()