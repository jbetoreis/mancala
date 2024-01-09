extends Control


var server_ip = "localhost"
var port = 7777
var par = null

func _ready():
	pass
	

func connect_to_server():
	par = ENetMultiplayerPeer.new();
	par.create_client(server_ip, port);
	multiplayer.multiplayer_peer = par;

@rpc("reliable")
func definir_canal(channel):
	DadosBase.my_channel = channel
	print("Canal atribuído:", channel)
	get_tree().change_scene_to_file("res://scenes/cena.tscn");



func _on_button_pressed():
	connect_to_server()
