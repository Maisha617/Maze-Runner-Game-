extends Node2D
#Author: Maisha Rahman mr3798

var front_texture

func set_front_texture(tex):
	front_texture = tex
	set_meta("front_texture", tex)
	$CardTemplate/FrontTexture.texture = tex

func show_back():
	$CardTemplate/BackTexture.visible = true
	$CardTemplate/FrontTexture.visible = false

func show_front():
	$CardTemplate/BackTexture.visible = false
	$CardTemplate/FrontTexture.visible = true

func flip_to_front():
	$AnimationPlayer.play("flip_to_front")
	await get_tree().create_timer(0.15).timeout
	show_front()

func flip_to_back():
	$AnimationPlayer.play("flip_to_back")
	await get_tree().create_timer(0.15).timeout
	show_back()
