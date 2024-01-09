extends Node2D

@export var pontuacao = 0

func setValor(valor):
	pontuacao = valor
	$Indicador.text = str(pontuacao)

func incrementar():
	pontuacao += 1
	$Indicador.text = str(pontuacao)

func decrementar():
	pontuacao -= 1
	$Indicador.text = str(pontuacao)
