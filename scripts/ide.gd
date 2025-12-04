extends CanvasLayer

# Signal to tell the Player we are done
signal closed_computer
signal level_clear(level_number)
signal enter_lvl(id_level)
signal error

# --- NODE REFERENCES ---
# Make sure these paths match your Scene Tree names
@onready var code_editor = $CodeEdit
@onready var console = $RespostaIa # You might want to rename this node to "ConsoleOutput" in your scene
@onready var btn_run = $Run
@onready var btn_exit = $Exit

# Title and Instructions references
@onready var header_label = $header_label
@onready var task_label = $task_label

# Variable to track the current level
var current_level_id = 1

func _ready():
	# Connect buttons
	btn_run.pressed.connect(_on_run_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	# Setup editor colors
	setup_syntax_highlighting()
	
	# Initial text is handled by setup_level when called

# --- FUNCTION CALLED BY COMPUTER_OS (WHEN CLICKING AN ICON) ---
func setup_level(level: int):
	current_level_id = level
	
	emit_signal("enter_lvl", current_level_id)
	
	# Clear console
	console.text = "[color=gray]Awaiting command...[/color]"
	
	match level:
		1: # LAMP
			
			header_label.text = "LEVEL 1: LIGHTING"
			task_label.text = "The sensor is stuck on 'off'. Change the variable."
			# Puzzle Code
			code_editor.text = 'var lamp_status = "off"\n\nfunc update_room():\n\tapply_state(lamp_status)'
			
		2: # AC UNIT
			header_label.text = "LEVEL 2: TEMPERATURE"
			task_label.text = "Heat warning (80ºC). Lower temperature or you will burn."
			# Puzzle Code
			code_editor.text = 'var target_temp = 80\n\nfunc check_climate():\n\tif target_temp > 25:\n\t\theater.turn_on()'
			
		3: # ALARM
			header_label.text = "LEVEL 3: ALARMS!"
			task_label.text = "Can you think with that sound?."
			# Puzzle Code
			code_editor.text = 'var alarm_playing = true\n\nfunc check_alarm():\n\tif alarm_playing == true:\n\t\tplay_sound()'
			
		4: # COFRE / SENHA
			header_label.text = "NÍVEL 4: RESTRICTED"
			task_label.text = "You will need a password"
			
			# Código Inicial
			# Coloquei 'var' antes para ficar sintaticamente correto
			code_editor.text = '#You will never discover the password, it is so complex even myself need to write it down \nvar password = "?"\n\nfunc check_password():\n\tverify_password(password)'
			
		5: # DOOR
			header_label.text = "LEVEL 5: EXIT"
			task_label.text = "The loop locks the door. Use the inverse function."
			# Puzzle Code
			code_editor.text = 'func security_system():\n\tlock_door()\n\tlock_door()'
			
		_:
			console.text = "Error: Level not found."

# --- BUTTONS ---

func _on_run_pressed():
	console.text = "[color=yellow]Compiling...[/color]"
	
	# Visual delay
	await get_tree().create_timer(0.5).timeout
	
	# Check answer
	check_puzzle_solution(code_editor.text)

func _on_exit_pressed():
	hide()
	emit_signal("closed_computer")

# --- PUZZLE VERIFICATION LOGIC ---
func check_puzzle_solution(text: String):
	# Radical cleanup: remove spaces, tabs, and newlines to make checking easier
	var clean_code = text.replace(" ", "").replace("\t", "").replace("\n", "")
	var success = false
	
	match current_level_id:
		1: # Level 1: String "on"
			# Accept single or double quotes
			if 'lamp_status="on"' in clean_code or "lamp_status='on'" in clean_code:
				success = true
				emit_signal("level_clear", current_level_id)
				
		2: # Level 2: Temp < 25 OR Fan = true
			var changed_temp = !("target_temp=80" in clean_code) # Checks if 60 was removed/changed
			if changed_temp:
				success = true
				emit_signal("level_clear", current_level_id)
				
		3: # Level 3: Sleeping = false
			if "alarm_playing=false" in clean_code:
				success = true
				emit_signal("level_clear", current_level_id)
				
		4: # Nível 4: Senha "1234"
			# Vamos aceitar tanto String "1234" quanto Número 1234 para ser bonzinho com o jogador
			var string_dupla = 'password="1234"' in clean_code
			var string_simples = "password='1234'" in clean_code
			var numero_inteiro = "password=1234" in clean_code
			
			if string_dupla or string_simples or numero_inteiro:
				success = true
				emit_signal("level_clear", current_level_id)
				
		5: # Level 5: Door Logic
			# CORREÇÃO: Removemos a parte 'and not "lock_door()"' 
			# porque "unlock" contém a palavra "lock" dentro dela, o que bugava a lógica.
			
			if "unlock_door()" in clean_code:
				success = true
				emit_signal("level_clear", current_level_id)

	# Final Feedback
	if success:
		console.text = "[color=green]SUCCESS: Changes applied![/color]"
		# Note: The signal 'level_clear' is already emitted inside the match block above
	else:
		emit_signal("error")
		console.text = "[color=red]ERROR: System rejected the changes. Try again.[/color]"

# --- VISUAL STYLE (COLORS) ---
func setup_syntax_highlighting():
	var highlighter = CodeHighlighter.new()
	
	highlighter.number_color = Color("#7fcce3")
	highlighter.symbol_color = Color("#ffffff")
	highlighter.function_color = Color("#f5d547")
	highlighter.member_variable_color = Color("#ffffff")
	
	# Keywords
	highlighter.add_keyword_color("var", Color("#ff79c6"))
	highlighter.add_keyword_color("func", Color("#ff79c6"))
	highlighter.add_keyword_color("if", Color("#ff79c6"))
	highlighter.add_keyword_color("else", Color("#ff79c6"))
	highlighter.add_keyword_color("true", Color("#bd93f9"))
	highlighter.add_keyword_color("false", Color("#bd93f9"))
	
	code_editor.syntax_highlighter = highlighter
