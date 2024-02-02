extends Control

func setMessage(message):
	$CenterContainer/Mensagem.text = message

func disparar_mensagem():
	$Animation.play("Transicionar")
