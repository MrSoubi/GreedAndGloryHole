extends Node

# SplashScreen.gd : Affiche le logo/écran de démarrage puis passe au menu principal

@export var splash_duration: float = 2.0 # Durée d'affichage en secondes

func _ready():
    await get_tree().create_timer(splash_duration).timeout
    SceneManager.change_scene(SceneManager.SceneId.MAIN_MENU)
