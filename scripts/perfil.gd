extends Control

@export var nome = "asdasd";
@export var orientacao = 1;
var tempo_decorrido = 0;
@onready var timerLabel = $VBoxContainer/HBoxContainer/Contador;
@onready var timer = $Timer;

func _ready():
	$VBoxContainer/HBoxContainer/PlayerName.text = nome;
	
	var hbox_container = $VBoxContainer/HBoxContainer
	
	if orientacao == 1:
		hbox_container.move_child($VBoxContainer/HBoxContainer/PlayerName, 1)
		hbox_container.move_child($VBoxContainer/HBoxContainer/PlayerIcon, 0)
		hbox_container.move_child($VBoxContainer/HBoxContainer/CronometroIcon, 3)
		hbox_container.move_child($VBoxContainer/HBoxContainer/Contador, 4)
	else:
		hbox_container.move_child($VBoxContainer/HBoxContainer/PlayerName, 3)
		hbox_container.move_child($VBoxContainer/HBoxContainer/PlayerIcon, 4)
		hbox_container.move_child($VBoxContainer/HBoxContainer/CronometroIcon, 0)
		hbox_container.move_child($VBoxContainer/HBoxContainer/Contador, 1)

func startThink():
	$VBoxContainer/HBoxContainer/PlayerIcon/PlayerThink.visible = true;

func stopThink():
	$VBoxContainer/HBoxContainer/PlayerIcon/PlayerThink.visible = false;

func hideTimer():
	$VBoxContainer/HBoxContainer/HSeparator.visible = false;
	$VBoxContainer/HBoxContainer/CronometroIcon.visible = false;
	$VBoxContainer/HBoxContainer/Contador.visible = false;

func _on_timer_timeout():
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

func startTimer():
	tempo_decorrido = 0;
	timer.start();

func stopTimer():
	timer.stop();
