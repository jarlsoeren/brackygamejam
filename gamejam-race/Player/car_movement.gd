extends CharacterBody2D

var speed = 400
var angular_speed = PI

func _enter_tree():
	set_multiplayer_authority(int(str(name)))

func _process(delta):
	
	if !is_multiplayer_authority():
		return
	
	var velocity = Vector2.UP.rotated(rotation) * speed
	
	if Input.is_physical_key_pressed(KEY_A):
		rotation -= angular_speed * delta
	elif Input.is_physical_key_pressed(KEY_D):
		rotation += angular_speed * delta
		
	if Input.is_physical_key_pressed(KEY_W):
		position += velocity * delta
		
	

	
