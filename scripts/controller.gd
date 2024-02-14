extends Node

var pre_semente = preload("res://scenes/semente.tscn")

var jogador1 = {
	"indicador": 1,
	"id": 1,
	"pontuacao": 0,
	"perfil": null
}

var jogador2 = {
	"indicador": 2,
	"id": 2,
	"pontuacao": 0,
	"perfil": null
}

var turno_atual = {
	"jogador": jogador1,
	"jogadas": 0,
}

var tabuleiro = []
var casas_opostas = []

func _ready():
	jogador1["perfil"] = $CanvasLayer/InfoJogadores/Perfil1;
	jogador2["perfil"] = $CanvasLayer/InfoJogadores/Perfil2;
	var meu_id = multiplayer.get_unique_id();
	if GameManager.Players[str(meu_id)]["index"] == 1:
		turno_atual["jogadas"] = 1;
		jogador1["perfil"].startThink();
	else:
		jogador2["perfil"].startThink();
	
	tabuleiro = [
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco0,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos0,
			"jogador": jogador1,
			"casa_oposta": 12,
			"casa_adversario": 7,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco1,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos1,
			"jogador": jogador1,
			"casa_oposta": 11,
			"casa_adversario": 8,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco2,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos2,
			"jogador": jogador1,
			"casa_oposta": 10,
			"casa_adversario": 9,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco3,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos3,
			"jogador": jogador1,
			"casa_oposta": 9,
			"casa_adversario": 10,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco4,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos4,
			"jogador": jogador1,
			"casa_oposta": 8,
			"casa_adversario": 11,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco5,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos5,
			"jogador": jogador1,
			"casa_oposta": 7,
			"casa_adversario": 12,
		},
		{
			"chave": "kalla",
			"total_sementes": 0,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Kalla01,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos6,
			"jogador": jogador1
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco7,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos7,
			"jogador": jogador2,
			"casa_oposta": 5,
			"casa_adversario": 0,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco8,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos8,
			"jogador": jogador2,
			"casa_oposta": 4,
			"casa_adversario": 1,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco9,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos9,
			"jogador": jogador2,
			"casa_oposta": 3,
			"casa_adversario": 2,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco10,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos10,
			"jogador": jogador2,
			"casa_oposta": 2,
			"casa_adversario": 3,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco11,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos11,
			"jogador": jogador2,
			"casa_oposta": 1,
			"casa_adversario": 4,
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco12,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos12,
			"jogador": jogador2,
			"casa_oposta": 0,
			"casa_adversario": 5,
		},
		{
			"chave": "kalla",
			"total_sementes": 0,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Kalla02,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos13,
			"jogador": jogador2
		}
	]
	
	
	montar_tabuleiro()

func _process(delta):
	if Input.get_action_strength("ui_home"):
		get_tree().change_scene_to_file("res://scenes/cena.tscn")

@rpc("any_peer","call_local")
func distribuir_sementes(casa_selecionada, jogador):
	var is_remote = multiplayer.get_remote_sender_id() != multiplayer.get_unique_id();
	if is_remote:
		casa_selecionada = tabuleiro[casa_selecionada]["casa_adversario"];
	if casa_selecionada < 0 or casa_selecionada > 13:
		return
	if casa_selecionada in [6, 13]:  # 6 e 13 Kallas
		return
	turno_atual["jogadas"] = 0
	var sementes_casa = tabuleiro[casa_selecionada]["sementes"];
	var i = casa_selecionada + 1;
	var timer = 0.6;
	while i <= 13:
		var jogador_alvo = jogador1;
		if is_remote:
			jogador_alvo = jogador2;
		if tabuleiro[i]["chave"] == "kalla" and tabuleiro[i]["jogador"]["id"] != jogador_alvo["id"]:  # Semente não deve cair na kalla adversária
			if i == 13:
				i = 0;
			else:
				i += 1;
			continue;
		var rand_posx = randi_range(-30, 30);
		var rand_posy = randi_range(-30, 30);
		var posicao_destino = tabuleiro[i]["posicao"].position + Vector2(rand_posx, rand_posy);
		tabuleiro[casa_selecionada]["sementes"][-1].mover_para(posicao_destino);
		var ultima_semente = tabuleiro[casa_selecionada]["sementes"].pop_back();
		sementes_casa = tabuleiro[casa_selecionada]["sementes"].size();
		tabuleiro[i]["sementes"].append(ultima_semente);
		tabuleiro[i]["total_sementes"] += 1;
		tabuleiro[i]["indicador"].incrementar();
		tabuleiro[casa_selecionada]["indicador"].decrementar();
		await get_tree().create_timer(timer).timeout;
		
		if sementes_casa <= 0: # Todas as sementes distribuidas
			if tabuleiro[i]["chave"] != "kalla":  # Regra para jogar mais uma vez
				var casa_oposta = tabuleiro[i]["casa_oposta"];
				print("Opa")
				if tabuleiro[i]["sementes"].size() <= 1 and tabuleiro[i]["jogador"]["id"] == jogador["id"] and tabuleiro[casa_oposta]["sementes"].size() > 0 and !is_remote:
					print("Capturar")
					await rpc("capturarSementes", i)
				
				if is_remote:
					turno_atual["jogadas"] = 1
					MensagemNovaJogada();
					jogador1["perfil"].startThink()
					jogador2["perfil"].stopThink()
				else:
					turno_atual["jogadas"] = 0
					jogador1["perfil"].stopThink()
					jogador2["perfil"].startThink()
			else:
				if is_remote:
					turno_atual["jogadas"] = 0
					jogador1["perfil"].stopThink()
					jogador2["perfil"].startThink()
				else:
					turno_atual["jogadas"] = 1
					MensagemNovaJogada();
					jogador1["perfil"].startThink()
					jogador2["perfil"].stopThink()
			print("Opa2")
			if VerificarMinhasSementes() <= 0:
				print("Opa3")
				turno_atual["jogadas"] = 0
				await rpc("RetornarSementes");
			break
		elif i == 13: # Ainda falta sementes para distribuir
			i = 0;
			continue;
		i += 1;
	
	tabuleiro[casa_selecionada]["total_sementes"] = 0;

func montar_tabuleiro():
	for casa in tabuleiro:
		if casa["chave"] == "buraco":
			for i in range(4):
				var semente = pre_semente.instantiate()
				get_tree().root.get_node("Cena/Tabuleiro").add_child(semente)
				
				var offset_x = randi_range(-25, 25)
				var offset_y = randi_range(-25, 25)
				semente.position = casa["posicao"].position + Vector2(offset_x, offset_y)
				semente.DefineTexture(i - 1);
				casa["sementes"].append(semente)
			casa["indicador"].setValor(4)

func _on_buraco_casa_selecionada(posicao):
	if tabuleiro[posicao]["jogador"]["id"] != turno_atual["jogador"]["id"]:
		return
	if turno_atual["jogadas"] <= 0:
		return
	if (tabuleiro[posicao]["sementes"]).size() <= 0:
		return
	rpc("distribuir_sementes", posicao, turno_atual["jogador"])

@rpc("any_peer","call_local")
func capturarSementes(casa):
	var is_remote = multiplayer.get_remote_sender_id() != multiplayer.get_unique_id();
	if is_remote:
		casa = tabuleiro[casa]["casa_adversario"];
	var timer = 0.5;
	var casa_oposta = tabuleiro[casa]["casa_oposta"];
	
	# var kalla = tabuleiro[6];
	# if turno_atual["jogador"]["indicador"] == 2:
	#	kalla = tabuleiro[13];
	var kalla = tabuleiro[6];
	if is_remote:
		kalla = tabuleiro[13];
	
	var posicao_destino = kalla["posicao"].position;
	
	await guardarSementes(casa, posicao_destino, kalla);
	await guardarSementes(casa_oposta, posicao_destino, kalla);


@rpc("any_peer", "call_local")
func RetornarSementes():
	var is_remote = multiplayer.get_remote_sender_id() != multiplayer.get_unique_id();
	var kalla = tabuleiro[13];
	var jogador = jogador2;
	if is_remote:
		kalla = tabuleiro[6];
		jogador = jogador1;
		
	var posicao_destino = kalla["posicao"].position;
	for i in range(tabuleiro.size()):
		if tabuleiro[i]["jogador"]["id"] == jogador["id"] && tabuleiro[i]["chave"] == "buraco":
			guardarSementes(i, posicao_destino, kalla);


func guardarSementes(casa, posicao_destino, kalla_destino):
	for i in range(tabuleiro[casa]["sementes"].size()):
		var rand_posx = randi_range(-30, 30);
		var rand_posy = randi_range(-75, 75);
		var posicao_kalla = posicao_destino + Vector2(rand_posx, rand_posy)
		tabuleiro[casa]["sementes"][-1].mover_para(posicao_kalla);
		
		var ultima_semente = tabuleiro[casa]["sementes"].pop_back();
		kalla_destino["sementes"].append(ultima_semente);
		kalla_destino["total_sementes"] += 1;
		kalla_destino["indicador"].incrementar();
		tabuleiro[casa]["indicador"].decrementar();
		
		await get_tree().create_timer(0.5).timeout;

func VerificarMinhasSementes():
	var total_sementes = 0;
	for casa in tabuleiro:
		if casa["jogador"]["id"] == turno_atual["jogador"]["id"] && casa["chave"] == "buraco":
			total_sementes += casa["sementes"].size()
	return total_sementes;

func MensagemNovaJogada():
	$CanvasLayer/Mensagem.setMessage("Sua Vez!");
	$CanvasLayer/Mensagem.disparar_mensagem();
