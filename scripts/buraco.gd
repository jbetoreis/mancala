extends Node2D

@export var posicao : int = 0;

signal casa_selecionada

func _ready():
	pass

func _process(delta):
	pass


func _on_button_pressed():
	emit_signal("casa_selecionada", posicao)
