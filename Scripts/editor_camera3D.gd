extends Camera3D

var sensitivity = 0.005
var speed = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_W):
		position = position + global_basis * Vector3.FORWARD * speed * delta
	if Input.is_key_pressed(KEY_S):
		position = position + global_basis * Vector3.BACK * speed * delta
	if Input.is_key_pressed(KEY_A):
		position = position + global_basis * Vector3.LEFT * speed * delta
	if Input.is_key_pressed(KEY_D):
		position = position + global_basis * Vector3.RIGHT * speed * delta
	if Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE):
		position = position + global_basis * Vector3.UP * speed * delta
	if Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_CTRL):
		position = position + global_basis * Vector3.DOWN * speed * delta
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.x -= event.screen_relative.y * sensitivity
		rotation.y -= event.screen_relative.x * sensitivity
		rotation.x = clamp(rotation.x,deg_to_rad(-89),deg_to_rad(89))
