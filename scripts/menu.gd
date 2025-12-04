extends Control

@onready var menu_options = $VBoxContainer/MenuOptions
@onready var title_display = $VBoxContainer/TitleDisplay

const COR_CMD = "#f5d547" 
const COR_LNK = "#7fcce3" 
const COR_HOVER = "#ff5555" 

var em_submenu = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	title_display.text = """[center]
	[color=gray]/// BOOT SEQUENCE INITIATED...[/color]
	[color=gray]/// KERNEL: LOADED[/color]

	[b][font_size=60][color={cor}]SYNTAX[/color][/font_size][/b]
	[color=gray]v1.0.0 stable[/color]
	[/center]""".format({"cor": COR_CMD})

	atualizar_menu_padrao()
	
	menu_options.meta_clicked.connect(_on_link_clicked)
	menu_options.meta_hover_started.connect(_on_hover_start)
	menu_options.meta_hover_ended.connect(_on_hover_end)

func atualizar_menu_padrao():
	em_submenu = false
	
	var texto = """[center]
[url=start] > ./START_SYSTEM.exe [/url]

[url=settings] > ./SETTINGS.ini [/url]

[url=about] > ./ABOUT_DEV.txt [/url]

[url=quit] > ./DISCONNECT [/url]
[/center]"""
	
	menu_options.text = "[color=" + COR_LNK + "]" + texto + "[/color]"

func _on_link_clicked(meta):
	match meta:
		"start":
			print("Starting game...")
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		"settings":
			mostrar_settings()
		"about":
			mostrar_about()
		"quit":
			get_tree().quit()
		"back": 
			atualizar_menu_padrao()
			
		# --- SETTINGS TOGGLES ---
		"audio":
			toggle_audio()
			mostrar_settings()
		"subtitles":  # [NOVO] Lógica da legenda
			toggle_subtitles()
			mostrar_settings()

func _on_hover_start(meta):
	if em_submenu: return
	var novo_texto = menu_options.text.replace(
		"> ./" + meta.to_upper(), 
		"[color=" + COR_HOVER + "][b]>> " + meta.to_upper() + " <<[/b][/color]"
	)
	menu_options.text = novo_texto

func _on_hover_end(meta):
	if em_submenu: return
	atualizar_menu_padrao()

func mostrar_about():
	em_submenu = true
	var texto_sobre = """[center][color=gray]
	--- RECOVERED FILE ---
	Developed by Filipe Galvão
	Course: Digital Games - UEFS
	Prof. Victor Sarinho
	
	[url=back]<< RETURN[/url]
	[/color][/center]"""
	menu_options.text = texto_sobre

func mostrar_settings():
	em_submenu = true
	
	# Check current states
	var is_muted = AudioServer.is_bus_mute(0)
	var is_subs_on = GameSettings.subtitles_enabled # [NOVO] Lê do Global
	
	var check_audio = "[X]" if is_muted else "[ ]"
	var check_subs = "[X]" if is_subs_on else "[ ]" # [NOVO]
	
	var texto_config = """[center][color=gray]
	--- SYSTEM CONFIGURATION ---
	
	[url=audio] {audio_box} MUTE_AUDIO [/url]
	[url=subtitles] {subs_box} SUBTITLES [/url]
	
	[url=back]<< RETURN[/url]
	[/color][/center]""".format({"audio_box": check_audio, "subs_box": check_subs})
	
	menu_options.text = texto_config

func toggle_audio():
	var current_mute = AudioServer.is_bus_mute(0)
	AudioServer.set_bus_mute(0, !current_mute)

# [NOVO] Função que altera o Global
func toggle_subtitles():
	GameSettings.subtitles_enabled = !GameSettings.subtitles_enabled
