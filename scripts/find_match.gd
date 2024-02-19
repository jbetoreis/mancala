extends Control

var tempo_decorrido = 0;
@onready var timerLabel = $MarginContainer/HBoxContainer/TimerLabel;
signal cancelar_busca;

func _on_base_find_time_timeout():
	tempo_decorrido += 1;
	timerLabel.text = segundos_para_minutos_segundos(tempo_decorrido);

func segundos_para_minutos_segundos(segundos):
	var minutos = int(segundos / 60)
	var segundos_restantes = int(segundos % 60)
	var segundos_str = str(segundos_restantes)
	
	# Adiciona um zero à esquerda se os segundos forem menores que 10
	if segundos_restantes < 10:
		segundos_str = "0" + segundos_str
	
	return str(minutos) + ":" + segundos_str



func _on_break_find_button_up():
	$AnimationPlayer.play("Encerrar");
	emit_signal("cancelar_busca");


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Encerrar":
		queue_free()
