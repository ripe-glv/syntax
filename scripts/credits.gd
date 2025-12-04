extends Control

func _ready():
	# Garante que a música do alarme parou, caso ainda estivesse a tocar
	# (Se tiver um AudioServer global, desligue-o aqui)
	pass

func _process(delta):
	# Permite fechar o jogo ao pressionar ESC
	if Input.is_action_just_pressed("ui_cancel"): # Tecla ESC por defeito
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

# Opcional: Detetar quando a animação termina para fechar o jogo sozinho
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "roll":
		# Espera 2 segundos e fecha
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
