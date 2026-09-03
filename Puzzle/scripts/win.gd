extends Control

class_name win_control

signal new_game

var tabuleiro_reference :tabuleiro
@export var time_count_label :Label
@export var number_movements_label :Label
func _ready() -> void:
	tabuleiro_reference = get_parent()
	tabuleiro_reference.score_game.connect(_show_score_game)
func _on_button_button_up() -> void:
	new_game.emit()

func _show_score_game(time_count :float, number_of_movements: int) -> void:
	time_count_label.text = "Time: %.1f"%time_count
	number_movements_label.text = "Movements: %d"%number_of_movements
	pass
