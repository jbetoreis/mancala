extends Node

var pre_semente = preload("res://scenes/semente.tscn");
var pre_placar = preload("res://scenes/placar.tscn");
@onready var BtnMenu = $CanvasLayer/MenuButton;
@onready var ModalConfirmacao = $ModalConfirmacao;

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
	"jogadas": 1,
}

var tabuleiro = []
var casas_opostas = []
var seed_sec_speed = 0.5
var placar_final = null
var revanche_adversario = false;

func _ready():
	jogador1["perfil"] = $CanvasLayer/InfoJogadores/Perfil1;
	jogador2["perfil"] = $CanvasLayer/InfoJogadores/Perfil2;
	
	MensagemTurno("Vez do Jogador 1!");
	jogador1["perfil"].startThink();
	
	BtnMenu.get_popup().id_pressed.connect(MenuPressed);
	
	tabuleiro = [
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco0,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos0,
			"jogador": jogador1,
			"casa_oposta": 12
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco1,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos1,
			"jogador": jogador1,
			"casa_oposta": 11
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco2,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos2,
			"jogador": jogador1,
			"casa_oposta": 10
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco3,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos3,
			"jogador": jogador1,
			"casa_oposta": 9
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco4,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos4,
			"jogador": jogador1,
			"casa_oposta": 8
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco5,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos5,
			"jogador": jogador1,
			"casa_oposta": 7
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
			"casa_oposta": 5
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco8,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos8,
			"jogador": jogador2,
			"casa_oposta": 4
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco9,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos9,
			"jogador": jogador2,
			"casa_oposta": 3
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco10,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos10,
			"jogador": jogador2,
			"casa_oposta": 2
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco11,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos11,
			"jogador": jogador2,
			"casa_oposta": 1
		},
		{
			"chave": "buraco",
			"total_sementes": 4,
			"sementes": [],
			"posicao": $Tabuleiro/Casas/Buraco12,
			"indicador": $Tabuleiro/Indicadores/IndicadorDePontos12,
			"jogador": jogador2,
			"casa_oposta": 0
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

func distribuir_sementes(casa_selecionada, jogador):
	if casa_selecionada < 0 or casa_selecionada > 13:
		return
	if casa_selecionada in [6, 13]:  # 6 e 13 Kallas
		return
	turno_atual["jogadas"] = 0
	var sementes_casa = tabuleiro[casa_selecionada]["sementes"];
	var i = casa_selecionada + 1;
	var timer = 0.6;
	while i <= 13:  # Parei a analise aqui
		if tabuleiro[i]["chave"] == "kalla" and tabuleiro[i]["jogador"]["id"] != jogador["id"]:  # Semente não deve cair na kalla adversária
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
				if tabuleiro[i]["sementes"].size() <= 1 and tabuleiro[casa_oposta]["sementes"].size() > 0 and tabuleiro[i]["jogador"]["id"] == jogador["id"]:  # Condição para captura
					$TurnSound.play();
					MensagemTurno("Captura!");
					capturarSementes(i);
				else:
					if VerificarMinhasSementes() <= 0:
						EncerrarPartida();
					else:
						passar_jogada(jogador);
			else:
				if VerificarMinhasSementes() <= 0:
					EncerrarPartida();
				else:
					$TurnSound.play();
					if GameManager.ModoJogo != "Offline" and jogador["indicador"] == 2:
						MensagemTurno("Vez do Computador!");
						var jogada = escolher_melhor_jogada(GameManager.ModoJogo);
						await get_tree().create_timer(1).timeout;
						distribuir_sementes(jogada, turno_atual["jogador"]);
					else:
						turno_atual["jogadas"] = 1;
						MensagemTurno("Jogue Novamente!");
			break
		elif i == 13: # Ainda falta sementes para distribuir
			i = 0;
			continue;
		i += 1;
	
	tabuleiro[casa_selecionada]["total_sementes"] = 0;

func passar_jogada(jogador):
	if jogador["indicador"] == 1:
		jogador1["perfil"].stopThink();
		jogador2["perfil"].startThink();
		turno_atual["jogador"] = jogador2;
		
		if GameManager.ModoJogo != "Offline":
			MensagemTurno("Vez do Computador!");
			var jogada = escolher_melhor_jogada(GameManager.ModoJogo);
			await get_tree().create_timer(1).timeout;
			distribuir_sementes(jogada, turno_atual["jogador"]);
		else:
			MensagemTurno("Vez do Jogador2!");
			turno_atual["jogadas"] = 1;
	else:
		turno_atual["jogador"] = jogador1;
		MensagemTurno("Vez do Jogador1!");
		jogador1["perfil"].startThink();
		jogador2["perfil"].stopThink();
		turno_atual["jogadas"] = 1;

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
	distribuir_sementes(posicao, turno_atual["jogador"]);

func capturarSementes(casa):
	var casa_oposta = tabuleiro[casa]["casa_oposta"];
	var kalla = tabuleiro[6];
	if turno_atual["jogador"]["indicador"] == 2:
		kalla = tabuleiro[13];
	
	var posicao_destino = kalla["posicao"].position;
	
	await guardarSementes(casa, posicao_destino, kalla);
	await guardarSementes(casa_oposta, posicao_destino, kalla, true);

func RetornarSementes():
	var casas_tabuleiro = tabuleiro.size();
	var maximo_sementes = 1;
	for i in range(casas_tabuleiro):
		if tabuleiro[i]["chave"] == "buraco":
			var kalla = tabuleiro[6];
			if tabuleiro[i]["jogador"]["indicador"] == 2:
				kalla = tabuleiro[13];
			var posicao_destino = kalla["posicao"].position;
			var sementes_casa = tabuleiro[i]["sementes"].size();
			if sementes_casa > maximo_sementes:
				maximo_sementes = sementes_casa;
			guardarSementes(i, posicao_destino, kalla);
	await get_tree().create_timer((seed_sec_speed * maximo_sementes) + 0.5).timeout;
	ExibirPlacar();


func guardarSementes(casa, posicao_destino, kalla_destino, passar_jogada = false):
	var seed_amount = tabuleiro[casa]["sementes"].size();
	for i in range(seed_amount):
		var rand_posx = randi_range(-30, 30);
		var rand_posy = randi_range(-75, 75);
		var posicao_kalla = posicao_destino + Vector2(rand_posx, rand_posy)
		tabuleiro[casa]["sementes"][-1].mover_para(posicao_kalla);
		
		var ultima_semente = tabuleiro[casa]["sementes"].pop_back();
		kalla_destino["sementes"].append(ultima_semente);
		kalla_destino["total_sementes"] += 1;
		kalla_destino["indicador"].incrementar();
		tabuleiro[casa]["indicador"].decrementar();
		
		await get_tree().create_timer(seed_sec_speed).timeout;
		if i == seed_amount - 1:
			if passar_jogada:
				if VerificarMinhasSementes() <= 0:
					EncerrarPartida();
				else:
					passar_jogada(turno_atual["jogador"]);

func VerificarMinhasSementes(jogador_id = turno_atual["jogador"]["id"]):
	var total_sementes = 0;
	for casa in tabuleiro:
		if casa["jogador"]["id"] == jogador_id && casa["chave"] == "buraco":
			total_sementes += casa["sementes"].size()
	return total_sementes;

func ExibirPlacar():  # Continuar a analise a partir deste ponto
	var placar_jogador1 = tabuleiro[6]["sementes"].size();
	var placar_jogador2 = tabuleiro[13]["sementes"].size();
	var vencedor = 1 if placar_jogador1 > placar_jogador2 else 2;
	
	var placar = pre_placar.instantiate();
	get_tree().root.get_node("Cena/CanvasLayer").add_child(placar)
	placar.position = get_viewport().get_visible_rect().size / 2
	placar_final = placar;
	
	placar.definirPontuacao(placar_jogador1, placar_jogador2);
	placar.definirVencedor(vencedor);
	placar.setSinglePlayerOp();
	placar.voltar_menu.connect(VoltarMenu);

func VoltarMenu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn");

func EncerrarPartida():
	turno_atual["jogadas"] = 0;
	jogador1["perfil"].visible = false;
	jogador2["perfil"].visible = false;
	RetornarSementes();

func MensagemTurno(mensagem):
	$CanvasLayer/Mensagem.setMessage(mensagem);
	$CanvasLayer/Mensagem.disparar_mensagem();


func MenuPressed(id):
	if id == 0:  # Sair
		ModalConfirmacao.show();

func _on_modal_confirmacao_focus_exited():
	ModalConfirmacao.hide();

func _on_btn_confirmar_button_up():
	ModalConfirmacao.hide();
	VoltarMenu();

func _on_btn_fechar_button_up():
	ModalConfirmacao.hide();



# Função para escolher a melhor jogada para o jogador 2 (computador)
func escolher_melhor_jogada(dificuldade):
	var melhor_jogada = -1
	var melhor_pontuacao = -1
	var inicio = 7  # Casa inicial do jogador 2
	var fim = 12  # Casa final do jogador 2
	
	var jogadas_possiveis = []  # Lista para armazenar possíveis jogadas
	
	# Percorre todas as casas do jogador 2 para encontrar a melhor jogada
	for i in range(inicio, fim + 1):
		if tabuleiro[i]["sementes"].size() > 0:
			jogadas_possiveis.append(i)
			# Simula a distribuição de sementes para verificar o resultado da jogada
			var temp_tabuleiro = tabuleiro.duplicate(true)  # Cria uma cópia do tabuleiro
			var casa_selecionada = i
			var sementes_casa = temp_tabuleiro[casa_selecionada]["sementes"].size()
			var posicao = casa_selecionada + 1
			var distribuidas = 0  # Contagem de sementes distribuídas
			
			# Simula a distribuição de sementes
			while distribuidas < sementes_casa:
				if posicao > 13:  # Se passar do fim do tabuleiro, reinicia no começo
					posicao = 0
				if temp_tabuleiro[posicao]["chave"] == "kalla" and temp_tabuleiro[posicao]["jogador"]["id"] != jogador2["id"]:
					posicao += 1  # Não pode cair no Kalla do jogador 1
					continue
				temp_tabuleiro[posicao]["sementes"].append(1)  # Adiciona uma semente
				distribuidas += 1
				posicao += 1
			
			# Verifica se a última semente caiu no Kalla do jogador 2, permitindo outra jogada
			if posicao - 1 == 13:
				melhor_jogada = i  # Jogada permite turno extra
				break  # Não precisa verificar mais
			
			# Verifica se a jogada resulta em captura
			var ultima_posicao = posicao - 1
			var casa_oposta = temp_tabuleiro[ultima_posicao]["casa_oposta"]
			if temp_tabuleiro[ultima_posicao]["sementes"].size() == 1 and temp_tabuleiro[casa_oposta]["sementes"].size() > 0 and temp_tabuleiro[ultima_posicao]["jogador"]["id"] == jogador2["id"]:
				melhor_jogada = i  # Jogada que captura sementes
				break
			
			# Atualiza a melhor jogada com base no total de sementes no Kalla do jogador 2
			var pontuacao = temp_tabuleiro[13]["sementes"].size()
			if pontuacao > melhor_pontuacao:
				melhor_pontuacao = pontuacao
				melhor_jogada = i
	
	var chance_erro = 0  # Nível 3, 0% de margem de erro
	if dificuldade == "Nivel1":
		chance_erro = 0.60  # 60% de chance de erro no modo fácil
	elif dificuldade == "Nivel2":
		chance_erro = 0.40  # 40% de chance de erro no modo médio
	
	if randi() % 100 < chance_erro * 100:
		# Se o computador errar, escolha uma jogada aleatória da lista de jogadas possíveis
		melhor_jogada = jogadas_possiveis[randi() % jogadas_possiveis.size()]
	
	return melhor_jogada
