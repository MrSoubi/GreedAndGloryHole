extends Area3D

@export var upgrade : Upgrade

func _ready() -> void:
	upgrade = upgrade.duplicate()

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		UpgradeManager.add_upgrade(upgrade)
		queue_free()
