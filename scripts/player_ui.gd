extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$menu_pause.visible = false
	pass # Replace with function body.

func resume_game():
	get_tree().paused = false
	$menu_pause.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		$menu_pause.visible = !$menu_pause.visible
		get_tree().paused = $menu_pause.visible
		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if !get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
