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
	removeLobby
}

var peer = WebSocketMultiplayerPeer.new()
var id = 0
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var hostId:int
var lobbyValue = ""

func _ready():
	connectToServer("")
	
	multiplayer.connected_to_server.connect(RTCServerConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)


func RTCServerConnected():
	print("RTC server connected")

func RTCPeerConnected(id):
	print("rtc peer connected " + str(id))
	
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


func _on_btn_start_match_button_down():
	StartGame.rpc()

@rpc("any_peer", "call_local")
func StartGame():
	var message = {
		"message": Message.removeLobby,
		"lobbyId": lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	get_tree().change_scene_to_file("res://scenes/cena.tscn")


func _on_btn_criar_entrar_button_down():
	var message = {
		"id": id,
		"name": "",
		"message": Message.lobby,
		"lobbdyValue": $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/CodigoPartida.text
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
