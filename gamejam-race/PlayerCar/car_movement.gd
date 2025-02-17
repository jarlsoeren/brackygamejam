extends CharacterBody2D




#var speed = 400
#var angular_speed = PI

#func _process(delta):
	#
	#if !is_multiplayer_authority():
		#return
	#
	#var velocity = Vector2.UP.rotated(rotation) * speed
	#
	#if Input.is_action_pressed("left"):
		#rotation -= angular_speed * delta
	#elif Input.is_action_pressed("right"):
		#rotation += angular_speed * delta
	#if Input.is_action_pressed("up"):
		#position += velocity * delta
		

@export var steering_angle = 15 # Maximum angle for steering the car's wheels
@export var engine_power = 900 # How much force the engine can apply for acceleration
@export var friction = -55 # The friction coeffisient that slows down the car
@export var drag = -0.06 # Air drag coefficient that also slows down the car
@export var braking = -450 # Braking power when the brake input is applied
@export var max_speed_reverse = 250 # Maximum speed limit in reverse
@export var slip_speed = 400 # Speed above which the car's traction decreases (for drifting)
@export var traction_fast = 2.5 # Traction factor when the car is moving fast (affects control)
@export var traction_slow = 10 # Traction factor when the car is moving slow (affects control)

var wheel_base = 65 # Distance between the front and back axle of the car
var acceleration = Vector2.ZERO # Current acceleration vector
var steer_direction # Current direction of steering

func _enter_tree():
	set_multiplayer_authority(int(str(name)))

func _process(delta):
	if !is_multiplayer_authority():
		return

func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	get_input() #  get input from player
	apply_friction(delta) # Apply friction forces to the car
	calculate_steering(delta) # Apply turning logic based on steering
	velocity += acceleration * delta # Apply the resulting acceleration to the velocity
	move_and_slide()
	
func get_input():
	# Get steering input and translate it to an angle
	var turn = Input.get_axis("left", "right")
	steer_direction = turn * deg_to_rad(steering_angle)
	
	# if accelerate is pressed, apply engine power to the car's forward direction
	if Input.is_action_pressed("up"):
		acceleration = transform.x * engine_power
		
	# If break is pressed, apply braking force
	if Input.is_action_pressed("down"):
		acceleration = transform.x * braking
		
func apply_friction(delta):
	# if there is no input and speed is very low, just stop to prevent endless sliding
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	# Calculate friction forec and air drag based on steering
	var friction_force	 = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	# Add the forces to the acceleration
	acceleration += drag_force + friction_force		
	
# function to apply friction forces to the car, making it 'slide' to a halt
func calculate_steering(delta):
	# Calculate the positions of the rear and front wheel
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# Advance the wheels' positions based on the current velocity, applying rottaion to the front wheel
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	# Calculate the new heading based on the wheels' positions
	var new_heading = rear_wheel.direction_to(front_wheel)
	
	# Choose the traction model based on the current speed
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
		
	# Dot product represents how aligned the new heading is with the current velocity direction
	var d = new_heading.dot(velocity.normalized())
	
	# If not braking (d > 0), adjust the car velocity smoothly towards the new heading
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
		
	# if braking (d < 0), reverse the direction and limit the speed
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
		
	# update the car's rotation to face the direction of the new heading
	rotation = new_heading.angle()
			
		
