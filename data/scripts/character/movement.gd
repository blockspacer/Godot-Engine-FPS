extends KinematicBody

# All speed variables
var n_speed : float = 04; # Normal
var r_speed : float = 12; # Running
var w_speed : float = 08; # Walking
var c_speed : float = 10; # Crouch

# Váriaveis de física
var gravity     : float = 50; # Gravity force
var jump_height : float = 15; # Jump height

# Todos os vetores
var velocity  : = Vector3(); # Velocity vector
var direction : = Vector3(); # Direction Vector

# All character inputs
var input : Dictionary = {};

func _physics_process(_delta) -> void:
	# Function for movement
	_movement(_delta);
	
	# Function for crouch
	_crouch(_delta);
	
	# Function for jump
	_jump(_delta);
	
	# Function for run
	_run(_delta)

func _movement(_delta) -> void:
	# Inputs
	input["left"]   = int(Input.is_action_pressed("KEY_A"));
	input["right"]  = int(Input.is_action_pressed("KEY_D"));
	input["foward"] = int(Input.is_action_pressed("KEY_W"));
	input["back"]   = int(Input.is_action_pressed("KEY_S"));
	
	# Look direction
	direction = Vector3();
	
	var basis = $"head/neck".global_transform.basis;
	direction += (-input["left"]    + input["right"]) * basis.x;
	direction += (-input["foward"]  +  input["back"]) * basis.z;
	
	# Check is on floor
	if not is_on_floor():
		# Applies gravity
		velocity.y += -gravity * _delta;
	
	# Interpolates between the current position and the future position of the character
	var target = direction * n_speed;
	var temp_velocity = velocity.linear_interpolate(target, n_speed * _delta);
	
	# Applies interpolation to the velocity vector
	velocity.x = temp_velocity.x;
	velocity.z = temp_velocity.z;
	
	# Calls the motion function by passing the velocity vector
	velocity = move_and_slide(velocity, Vector3(0, 1, 0), false, 4, PI/4, false);

func _crouch(_delta) -> void:
	# Inputs
	input["crouch"] = int(Input.is_action_pressed("KEY_CTRL"));
	
	# Get the character's head node
	var head = $"head";
	
	# If the head node is not touching the ceiling
	if not head.is_colliding():
		# Takes the character collision node
		var collision = $"collision";
		
		# Get the character's collision shape
		var shape = collision.shape.height;
		
		# Changes the shape of the character's collision
		shape = lerp(shape, 2 - (input["crouch"] * 1.5), c_speed  * _delta);
		
		# Apply the new character collision shape
		collision.shape.height = shape;

func _jump(_delta) -> void:
	# Inputs
	input["jump"] = int(Input.is_action_pressed("KEY_SPACE"));
	
	# Makes the player jump if he is on the ground
	if input["jump"]:
		if is_on_floor():
			velocity.y = jump_height;

func _run(_delta) -> void:
	# Inputs
	input["run"] = int(Input.is_action_pressed("KEY_SHIFT"));
	
	# Make the character run
	if not input["crouch"]: # If you are not crouching
		# switch between running and walking
		var toggle_speed : float = w_speed + ((r_speed - w_speed) * input["run"])
		
		# Create a character speed interpolation
		n_speed = lerp(n_speed, toggle_speed, 3 * _delta);
	else:
		# Create a character speed interpolation
		n_speed = lerp(n_speed, w_speed, _delta);
