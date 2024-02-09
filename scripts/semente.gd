extends Node2D

var semeando = false;
var target_position = Vector2()
var speed = 0
var move = Vector2();
var texturas = ["res://assets/BlueStone.png", "res://assets/RedStone.png", "res://assets/CyanStone.png", "res://assets/GreenStone.png"]

func _process(delta):
	if semeando:
		var direction = (target_position - position).normalized()
		var displacement = direction * speed * delta
		
		move.x = lerp(move.x, displacement.x, 0.1)
		move.y = lerp(move.y, displacement.y, 0.1)
		position += move
		
		if (position - target_position).length() < displacement.length():
			position = target_position
			semeando = false;

func mover_para(destino):
	semeando = true
	speed = 800
	target_position = destino

func DefineTexture(index):
	$Sprite.texture = load(texturas[index]);
