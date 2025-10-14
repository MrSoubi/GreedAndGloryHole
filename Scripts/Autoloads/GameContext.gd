extends Node

var player = null
var enemies = []
var root = null
var current_karkass : Karkass :
	get : return current_karkass
	set(value) : 
		current_karkass = value
		EventBus.karkass_changed.emit(current_karkass)
