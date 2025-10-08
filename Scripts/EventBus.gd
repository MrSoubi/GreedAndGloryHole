extends Node

signal on_player_shot
signal on_player_jumped(jump_count : int)
signal on_player_died
signal on_player_started_sliding
signal on_player_stopped_sliding(slide_duration : float)
signal on_player_landed(air_duration : float, jump_count : int)
