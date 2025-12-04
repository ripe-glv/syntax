extends CharacterBody3D

@onready var raycast = $head/Camera3D/RayCast3D
@onready var ui_label_chair = $Control/Label
@onready var computer = $PlayerUi/computer
@onready var folder = $PlayerUi/computer/folder2
@onready var help = $PlayerUi/computer/help
@onready var Ide = $PlayerUi/computer/Ide

signal enter_level(id_level)
signal cleared_puzzle(id_level)
signal first_interaction_computer
signal error()
var has_accessed_pc_before: bool = false

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sitting: bool = false
var is_using_computer: bool = false

func _ready():
	Ide.level_clear.connect(_on_ide_completed)
	Ide.enter_lvl.connect(_on_enter_level)
	Ide.error.connect(_on_error)
	
func _on_enter_level(level):
	emit_signal("enter_level", level)

func _on_error():
	emit_signal("error")
	
func _on_ide_completed(level):
	# O Player simplesmente grita para o Nível ouvir
	emit_signal("cleared_puzzle", level)

func _physics_process(delta: float) -> void:
	if is_using_computer:
		return
	computer.visible = false
	folder.visible = false
	Ide.visible = false
	help.visible = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		# Só verifica levantar se estiver sentado
		if sitting:
			ui_label_chair.text = "Press E to Use Terminal"
			ui_label_chair.visible = true
			
			if Input.is_action_just_pressed("interact"):
				enter_computer_mode()
			verify_getup()
			return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	verify_interaction()
	
func verify_interaction():
	
	if raycast.is_colliding():
		var objeto = raycast.get_collider()
		
		if objeto.is_in_group("interactive"):
			ui_label_chair.text = "Press E to sit"
			ui_label_chair.visible = true
			
			if Input.is_action_just_pressed("interact"):
				sit(objeto)
				
		else:
			ui_label_chair.visible = false
	else:
		ui_label_chair.visible = false
		

func enter_computer_mode():
	is_using_computer = true
	ui_label_chair.visible = false
	velocity = Vector3.ZERO # Pára o boneco
	
	# Solta o mouse para você poder clicar na IDE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Aqui você torna sua cena da IDE visível
	computer.visible = true
	
	if has_accessed_pc_before == false:
		has_accessed_pc_before = true # Marca como usado
		# Emite o sinal para quem estiver ouvindo (o Level)
		emit_signal("first_interaction_computer")

func open_folder():
	folder.visible = !folder.visible
	
func open_help():
	help.visible = !help.visible

func open_ide(level: int):
	Ide.setup_level(level)
	Ide.visible = true

func close_ide():
	Ide.visible = false

func exit_computer_mode():
	is_using_computer = false
	
	# Prende o mouse de volta para a câmera 3D
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Esconde a IDE
	computer.visible = false

func sit(cadeira):
	sitting = true
	$CollisionShape3D.disabled = true 
	global_transform = cadeira.obter_posicao_sentar()
	
func verify_getup():

	if Input.is_action_just_pressed("get_up"):
		getup()

func getup():
	
	sitting = false
	$CollisionShape3D.disabled = false
	position += Vector3(0, 0, 2) 
	
func menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func exit_computer() -> void:
	pass # Replace with function body.
