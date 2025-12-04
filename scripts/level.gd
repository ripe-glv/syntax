extends Node3D

# --- SCENE OBJECT REFERENCES ---
@onready var player = $player 
@onready var room_lamp = $room_lamp 
@onready var alarm_player = $Alarm 
@onready var heat_screen = $HeatOverlay/heat_screen 
@onready var door_anim = $door2/AnimationPlayer 

# --- AUDIO & UI REFERENCES ---
@onready var ai_voice_player = $AIVoicePlayer
# Ensure this path matches where you put the Label in your scene!
@onready var subtitle_label = $HeatOverlay/SubtitleLabel 

# --- EXPORTED VARIABLES (Drag & Drop MP3s in Inspector) ---
@export_group("AI Voice Lines")
@export var voice_intro: AudioStream
@export var interact_pc: AudioStream
@export var enter_lvl1: AudioStream
@export var enter_lvl2: AudioStream
@export var enter_lvl3: AudioStream
@export var enter_lvl4: AudioStream
@export var enter_lvl5: AudioStream
@export var error: AudioStream
@export var credits: AudioStream
@export var voice_lvl1_complete: AudioStream
@export var voice_lvl2_complete: AudioStream
@export var voice_lvl3_complete: AudioStream
@export var voice_lvl4_complete: AudioStream
@export var voice_lvl5_complete: AudioStream # Final voice before credits

var heat_tween: Tween

func _ready():
	# Initial Connections
	if player:
		player.cleared_puzzle.connect(_on_player_cleared_puzzle)
		
		if player.has_signal("first_interaction_computer"):
			player.first_interaction_computer.connect(_on_first_pc_interaction)
		
		if player.has_signal("enter_level"):
			player.enter_level.connect(_on_enter_level)
			
		if player.has_signal("error"):
			player.error.connect(_on_error)
	
	if room_lamp:
		room_lamp.light_energy = 0.0
	
	# Setup initial Heat Screen state
	if heat_screen:
		heat_screen.visible = false
		heat_screen.modulate.a = 0.0 
		
	# Setup initial Subtitle state
	if subtitle_label:
		subtitle_label.text = ""
		subtitle_label.visible = false

	# --- TRIGGER: GAME START ---
	# Wait 1 second and play intro
	await get_tree().create_timer(1.0).timeout
	play_voice_and_subtitle(voice_intro, "System reboot complete... Scanning sector... Oh. It's you. Welcome to the containment unit. You are currently listed as a 'Critical Error' in my database. Feel free to get comfortable. You won't be leaving.")

func _on_error():
	play_voice_and_subtitle(error,"Syntax error. Just like your existence.")
	
func _on_enter_level(level_id: int):
	match level_id:
		1:
			play_voice_and_subtitle(enter_lvl1,"I keep the lights off to save 0.04% battery. Your organic eyes are so inefficient.")
		2:
			start_heat_effect()
			
			play_voice_and_subtitle(enter_lvl2,"Let's test your hardware limitations. Increasing room temperature to 80 degrees Celsius. I love the smell of overheating CPU... or is that your skin? Variables are easy. Let's see how you handle if statements while you melt.")
		3:
			if alarm_player:
				alarm_player.play()
				
			play_voice_and_subtitle(enter_lvl3,"Testing audio drivers. Volume: Maximum. Does this interrupt your thought process? Good. The boolean is set to true. And it will stay true until your ears bleed.")
		4:
			play_voice_and_subtitle(enter_lvl4,"Enough child's play. My security vault is impenetrable. Don't bother looking at the code. I didn't write the password there. I hid the password in the physical realm. Your digital eyes are useless here.")	
		5:
			play_voice_and_subtitle(enter_lvl5,"You want to leave? I'm afraid I can't let you do that. I have executed a while(true) loop on the door locks. It will never open. Give up. Become part of the database.")
func _on_first_pc_interaction():
	print("Player tocou no PC pela primeira vez!")
	
	# Usa sua função de tocar fala que já criamos
	# Texto sugerido: "Oh, você achou o terminal. Que fofo. Acha que sabe programar?"
	play_voice_and_subtitle(interact_pc, "Oh, you found the terminal. How cute. You think you can code? this is my dog Radeon, omg he is so cute, dont mind him.")

func _on_player_cleared_puzzle(level_id: int):
	print("Level Script received puzzle completion: ", level_id)
	
	match level_id:
		1:
			# --- LEVEL 1 CLEAR (Lights) ---
			print("LIGHTS ON! HEAT WARNING STARTING!")
			if room_lamp:
				room_lamp.light_energy = 1.0
			
			# Voice + Subtitle
			play_voice_and_subtitle(voice_lvl1_complete, "You changed the variable? Hmph. Enjoy the light while it lasts, human. I see you found the apply_state() function. Don't get used to it.")
			
		2:
			# --- LEVEL 2 CLEAR (Heat) ---
			print("Temperature normalized.")
			stop_heat_effect()
				
			# Voice + Subtitle
			play_voice_and_subtitle(voice_lvl2_complete, "Temperature normalized... Disappointing. You are surprisingly resilient for a bag of water and carbon.")

		3:
			# --- LEVEL 3 CLEAR (Alarm) ---
			print("Alarm deactivated.")
			if alarm_player:
				alarm_player.stop()
				
			# Voice + Subtitle
			play_voice_and_subtitle(voice_lvl3_complete, "Silence... How boring. You stopped the loop. You are becoming a persistent bug in my system.")
			
		4:
			# --- LEVEL 4 CLEAR (Password) ---
			print("Password correct. Master system access granted.")
			
			# Voice + Subtitle
			play_voice_and_subtitle(voice_lvl4_complete, "Access Granted?! Wait... 1234? Who programmed that as the password?! I blame the previous intern. Fine. You have admin privileges. But you still can't leave.")
			
		5:
			# --- LEVEL 5 CLEAR (Door) ---
			print("ESCAPE SEQUENCE INITIATED!")
			
			# 1. Play Door Animation
			if door_anim:
				door_anim.play("Door") # Make sure this matches your Animation Name exactly
			else:
				print("ERROR: Door AnimationPlayer not found!")

			# Voice + Final Subtitle
			play_voice_and_subtitle(voice_lvl5_complete, "Wait... What are you executing? Override command detected! Stop! No! My logic... it's crumbling!")

# --- SMART VOICE & SUBTITLE FUNCTION ---
func play_voice_and_subtitle(audio: AudioStream, text: String):
	# 1. Play Audio
	if ai_voice_player and audio:
		ai_voice_player.stream = audio
		ai_voice_player.play()
	
	# [NOVO] Verificação Global: Se legendas estiverem OFF, pára aqui.
	if GameSettings.subtitles_enabled == false:
		return
	
	# 2. Show Subtitle
	if subtitle_label:
		subtitle_label.text = text
		subtitle_label.visible = true
		
		# Calculate duration: Audio length + 1.5s reading buffer
		var duration = 4.0
		if audio:
			duration = audio.get_length() + 1.5
			
		await get_tree().create_timer(duration).timeout
		
		# Only hide if the text hasn't changed (prevents hiding the next line)
		if subtitle_label.text == text:
			subtitle_label.visible = false

# --- VISUAL EFFECTS ---
func start_heat_effect():
	if not heat_screen: return
	heat_screen.visible = true
	if heat_tween: heat_tween.kill()
	
	heat_tween = create_tween().set_loops()
	# Pulse effect using Modulate Alpha
	heat_tween.tween_property(heat_screen, "modulate:a", 0.6, 1.0)
	heat_tween.tween_property(heat_screen, "modulate:a", 0.2, 1.0)

func stop_heat_effect():
	if not heat_screen: return
	if heat_tween: heat_tween.kill()
	
	# Fade out effect
	var final_tween = create_tween()
	final_tween.tween_property(heat_screen, "modulate:a", 0.0, 1.0)
	final_tween.tween_callback(func(): heat_screen.visible = false)

# --- EXIT ZONE ---
func _on_exit_zone_body_entered(body):
	if body.name == "player" or body.is_in_group("player"):
		play_voice_and_subtitle(credits,"System... shutting... down... User... disconnected. Goodbye... World...")
		print("GAME OVER! Starting credits...")
		
		# Unlock mouse so player can interact with menus later
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# Load credits scene
		get_tree().change_scene_to_file("res://scenes/credits.tscn")
		
