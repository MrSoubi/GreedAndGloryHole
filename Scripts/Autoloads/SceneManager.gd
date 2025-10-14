extends Node

# SceneManager.gd : Gère le changement de scènes principales et transitions
# À ajouter comme autoload dans le projet Godot

var current_scene: Node = null

# Enum pour identifier les scènes de façon sûre
enum SceneId {
	SPLASH,
	MAIN_MENU,
	OPTIONS,
	HUB,
	PAUSE,
	GAME_OVER,
	VICTORY
}

# Dictionnaire pour la correspondance SceneId -> PackedScene
var scenes_map := {}

# Scènes principales exportées comme PackedScene
@export var splash_scene: PackedScene
@export var main_menu_scene: PackedScene
@export var options_scene: PackedScene
@export var hub_scene: PackedScene
@export var pause_scene: PackedScene
@export var game_over_scene: PackedScene
@export var victory_scene: PackedScene

signal scene_changed(scene_id)

func _ready():
	# Initialisation du dictionnaire de correspondance
	scenes_map = {
		SceneId.SPLASH: splash_scene,
		SceneId.MAIN_MENU: main_menu_scene,
		SceneId.OPTIONS: options_scene,
		SceneId.HUB: hub_scene,
		SceneId.PAUSE: pause_scene,
		SceneId.GAME_OVER: game_over_scene,
		SceneId.VICTORY: victory_scene
	}


# Change de scène par enum SceneId, avec transition visuelle
func change_scene(scene_id: SceneId):
	var scene = scenes_map.get(scene_id, null)
	if scene == null:
		push_error("SceneManager: scène nulle pour l'id %s !" % [str(scene_id)])
		return
	TransitionManager.fade_out()
	await TransitionManager.transition_finished
	_change_scene_by_packed(scene, scene_id)
	TransitionManager.fade_in()

func _change_scene_by_packed(scene: PackedScene, scene_id: SceneId):
	var new_scene = scene.instantiate()
	if current_scene:
		current_scene.queue_free()
	get_tree().get_root().add_child(new_scene)
	current_scene = new_scene
	emit_signal("scene_changed", scene_id)

# Pour accéder à la scène courante
func get_current_scene() -> Node:
	return current_scene
