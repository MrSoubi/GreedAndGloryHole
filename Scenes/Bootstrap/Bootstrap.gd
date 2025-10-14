extends Node

# Bootstrap.gd : Script de démarrage du jeu
# À attacher à la scène Bootstrap.tscn (scène principale du projet)

func _ready():
	# Lancer le splash screen dès le démarrage
	SceneManager.change_scene(SceneManager.SceneId.SPLASH)
