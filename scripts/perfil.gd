extends Control

@export var nome = "asdasd";
@export var orientacao = 1;

func _ready():
	$HBoxContainer/PlayerName.text = nome;
	
	var hbox_container = $HBoxContainer
	
	if orientacao == 1:
		hbox_container.move_child($HBoxContainer/PlayerName, 1)
		hbox_container.move_child($HBoxContainer/PlayerIcon, 0)
	else:
		hbox_container.move_child($HBoxContainer/PlayerName, 0)
		hbox_container.move_child($HBoxContainer/PlayerIcon, 1)

func startThink():
	$HBoxContainer/PlayerIcon/PlayerThink.visible = true;

func stopThink():
	$HBoxContainer/PlayerIcon/PlayerThink.visible = false;
