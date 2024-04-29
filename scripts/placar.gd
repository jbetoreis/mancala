extends Control


@onready var perfil1 = $CenterContainer/VBoxContainer/HBoxContainer/Player01Info;
@onready var perfil2 = $CenterContainer/VBoxContainer/HBoxContainer/Player02Info;
@onready var pontuacao_jogador1 = $CenterContainer/VBoxContainer/HBoxContainer/PontuacaoPlayer01;
@onready var pontuacao_jogador2 = $CenterContainer/VBoxContainer/HBoxContainer/PontuacaoPlayer02;
@onready var btn_revanche = $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer2/BtnRepeatGame;
@onready var notificacao_revanche = $CenterContainer/VBoxContainer/HBoxContainer/Player02Info/AspectRatioContainer/TexturaPerfil/NotificacaoRevanche;
@onready var LabelExtraInfo = $CenterContainer/VBoxContainer/LabelExtraInfo;

signal voltar_menu;
signal revanche_signal;
signal close_revanche_signal;

var solicitacao_revanche = false;

func _ready():
	pass


func definirVencedor(jogador = 1):
	var perfis = [perfil1, perfil2];
	var perfil_vencedor = perfis[jogador - 1];
	perfil_vencedor.get_node("LabelWinner").text = "Vencedor";
	perfil_vencedor.get_node("AspectRatioContainer/TexturaPerfil/TexturaIndicador").visible = true;

func definirPontuacao(jogador1_pontos, jogador2_pontos):
	pontuacao_jogador1.text = str(jogador1_pontos);
	pontuacao_jogador2.text = str(jogador2_pontos);

func notificarRevanche():
	notificacao_revanche.visible = true;

func ocultarRevanche():
	notificacao_revanche.visible = false;

func _on_btn_back_to_menu_button_up():
	emit_signal("voltar_menu");

func setExtraInfo(mensagem):
	LabelExtraInfo.text = str(mensagem);
	LabelExtraInfo.visible = true;

func setSinglePlayerOp():
	btn_revanche.visible = false;
	perfil1.get_node("LabelName").text = "Jogador 1";
	perfil2.get_node("LabelName").text = "Jogador 2";

func _on_btn_repeat_game_button_up():
	if(!solicitacao_revanche):
		solicitacao_revanche = true;
		emit_signal("revanche_signal");
		btn_revanche.text = "Cancelar";
	else:
		solicitacao_revanche = false;
		emit_signal("close_revanche_signal");
		btn_revanche.text = "Revanche";
