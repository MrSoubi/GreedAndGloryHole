# Classe de base pour les mouvements du joueur
@abstract class_name PlayerMovementStrategy
extends RefCounted

@abstract func move(_controller: CharacterBody3D, _delta: float) -> void
