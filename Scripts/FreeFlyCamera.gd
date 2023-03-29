extends CharacterBody3D

var velocity = Vector3(0, 0, 0)

const PLAYER_MOVE_SPEED = 4
var boost = 1

@onready var Camera3D = $Camera3D

func move_forward_back(in_direction: int):
	"""
	Move the camera forward or backwards
	"""
	self.velocity += get_transform().basis.z * in_direction * PLAYER_MOVE_SPEED * boost

func move_left_right(in_direction: int):
	"""
	Move the camera to the left or right
	"""
	self.velocity += get_transform().basis.x * in_direction * PLAYER_MOVE_SPEED * boost

func move_up_down(in_direction: int):
	"""
	Move the camera up or down
	"""
	self.velocity += get_transform().basis.y * in_direction * PLAYER_MOVE_SPEED * boost


func _process(_delta: float):
	"""
	Allow the player to move the camera with WASD
	See Project settings -> Input map for keyboard bindings
	"""
	self.velocity = Vector3(0, 0, 0)
	
	if Input.is_action_pressed("speed_boost"):
		boost = 3
	else:
		boost = 1
	
	if Input.is_action_pressed("move_forward"):
		self.move_forward_back(-1)

	elif Input.is_action_pressed("move_back"):
		self.move_forward_back(+1)

	if Input.is_action_pressed("move_left"):
		self.move_left_right(-1)

	elif Input.is_action_pressed("move_right"):
		self.move_left_right(+1)
		
	if Input.is_action_pressed("move_up"):
		self.move_up_down(1)
		
	elif Input.is_action_pressed("move_down"):
		self.move_up_down(-1)

func _physics_process(_delta: float):
	var snap_vector = Vector3(0, 0, 0)
	
	self.velocity = self.move_and_slide_with_snap(
		self.velocity,
		snap_vector,
		Vector3(0, 0, 0),
		true
	)

