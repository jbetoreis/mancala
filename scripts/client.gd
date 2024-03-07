extends Control


enum Message{
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer,
	check,
	removeLobby,
	findMatch,
	endfindMatch
}

var peer = WebSocketMultiplayerPeer.new()
var id = 0
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var hostId:int
var lobbyValue = ""
var findingMatch = false;
@onready var btnFindMatch = $CenterContainer/VBoxContainer/BtnFindMatch;
var pre_find_label = preload("res://scenes/find_match_timer.tscn");
@onready var popupCriar = $PopupCriarPartida;
@onready var popupEntrar = $PopupEntrarPartida;
@onready var codeNewMatch = $PopupCriarPartida/Control/CenterContainer/VBoxContainer/Code;
@onready var codeEntryMatch = $PopupEntrarPartida/Control/CenterContainer/VBoxContainer/CodeMatch;

func _ready():
	connectToServer("")
	
	multiplayer.connected_to_server.connect(RTCServerConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)

func RTCServerConnected():
	print("RTC server connected")

func RTCPeerConnected(id):
	print("rtc peer connected " + str(id))
	StartGame.rpc();
	
func RTCPeerDisconnected(id):
	print("rtc peer disconnected " + str(id))


func _process(delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			print(data)
			if data.message == Message.id:
				id = data.id
				
				connected(id)
				
			if data.message == Message.userConnected:
				createPeer(data.id)
			if data.message == Message.lobby:
				GameManager.Players = JSON.parse_string(data.players)
				hostId = data.host
				lobbyValue = data.lobbyValue
				codeNewMatch.text = "Código: " + str(lobbyValue);
			if data.message == Message.candidate: 
				if rtcPeer.has_peer(data.orgPeer):
					print("Candidato definido: " + str(data.orgPeer) + " Meu id é " + str(id))
					rtcPeer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid, data.index, data.sdp)
			if data.message == Message.offer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
			if data.message == Message.answer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("answer", data.data)


func connected(id):
	rtcPeer.create_mesh(id)
	multiplayer.multiplayer_peer = rtcPeer

func createPeer(id):
	if id != self.id:
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers": [
				{"urls": ["stun:stun.l.google.com:19302"]},
			]
		})
		print("Id do parceiro " + str(id) + " Meu Id é " + str(self.id))
		
		peer.session_description_created.connect(self.offerCreated.bind(id))
		peer.ice_candidate_created.connect(self.iceCandidateCreated.bind(id))
		
		rtcPeer.add_peer(peer, id)
		if !hostId == self.id:
			peer.create_offer()

func offerCreated(type, data, id):
	if !rtcPeer.has_peer(id):
		return
	
	rtcPeer.get_peer(id).connection.set_local_description(type, data)
	
	if type == "offer":
		sendOffer(id, data)
	else:
		sendAnswer(id, data)

func sendOffer(id, data): # Peer enviando suas informações
	var message = {
		"peer": id,
		"orgPeer": self.id,
		"message": Message.offer,
		"data": data,
		"Lobby": lobbyValue
	}
	
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func sendAnswer(id, data): # Peer retornando sobre as informações do peer que fez uma oferta a ele
	var message = {
		"peer": id,
		"orgPeer": self.id,
		"message": Message.answer,
		"data": data,
		"Lobby": lobbyValue
	}
	
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func iceCandidateCreated(midName, indexName, sdpName, id):
	var message = {
		"peer": id,
		"orgPeer": self.id,
		"message": Message.candidate,
		"mid": midName,
		"index": indexName,
		"sdp": sdpName,
		"Lobby": lobbyValue
	}
	
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func connectToServer(ip):
	peer.create_client("ws://3.88.204.95:8915")
	print("Cliente iniciado")

@rpc("any_peer", "call_local")
func StartGame():
	$WaitingMatch.queue_free();
	closeLobby();
	get_tree().change_scene_to_file("res://scenes/cena.tscn")

func _on_btn_find_match_button_down():
	ButtonSound();
	findingMatch = true;
	btnFindMatch.disabled = true;
	btnFindMatch.text = "Aguarde...";
	var p = pre_find_label.instantiate()
	get_tree().root.get_child(1).get_node("WaitingMatch").add_child(p);
	p.cancelar_busca.connect(CancelarBusca);
	var message = {
		"id": id,
		"name": "",
		"message": Message.findMatch,
		"lobbdyValue": ""
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func CancelarBusca():
	findingMatch = false;
	btnFindMatch.disabled = false;
	btnFindMatch.text = "Buscar Partida";
	SetEndFindMatch();

func SetEndFindMatch():
	var message = {
		"id": id,
		"name": "",
		"message": Message.endfindMatch,
		"lobbdyValue": ""
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())


func _on_btn_criar_partida_button_down():
	ButtonSound()
	popupCriar.show();
	initLobby("");


func _on_btn_entrar_partida_button_down():
	ButtonSound()
	popupEntrar.show();


func _on_encerrar_lobby_button_up():
	ButtonSound()
	popupCriar.hide();
	closeLobby();


func _on_cancel_match_button_up():
	ButtonSound()
	popupEntrar.hide();


func _on_entrar_lobby_button_up():
	ButtonSound()
	var code = codeEntryMatch.text;
	if code:
		initLobby(code);

func _on_popup_entrar_partida_focus_exited():
	popupEntrar.hide();

func _on_popup_criar_partida_focus_exited():
	popupCriar.hide();
	closeLobby();

func closeLobby():
	var message = {
		"message": Message.removeLobby,
		"lobbyId": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func initLobby(codigo):
	var message = {
		"id": id,
		"name": "",
		"message": Message.lobby,
		"lobbdyValue": codigo
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func ButtonSound():
	$ButtonSound.play();


func _on_btn_fechar_jogo_button_up():
	get_tree().quit();
