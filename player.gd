extends CharacterBody2D

var tile_size = 16
var input_dir = Vector2.ZERO
var moving = false
var stop_input: bool = false
var speed = 200.0

@onready var animation_tree : AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	animation_tree['parameters/Idle/blend_position'] = input_dir
	animation_tree['parameters/Walk/blend_position'] = input_dir

	
func _physics_process(delta):
	if stop_input:
		return
	elif moving == false:
		process_player_movement_input()
	elif input_dir != Vector2.ZERO:
		animation_tree['parameters/conditions/idle'] = false
		animation_tree['parameters/conditions/is_moving'] = true
		move(delta)
	else:
		animation_tree['parameters/conditions/idle'] = true
		animation_tree['parameters/conditions/is_moving'] = false
		moving = false
		
		
func process_player_movement_input():
	if input_dir.y == 0:
		input_dir.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	if input_dir.x == 0:
		input_dir.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
	if input_dir != Vector2.ZERO:
		animation_tree['parameters/Idle/blend_position'] = input_dir
		animation_tree['parameters/Walk/blend_position'] = input_dir
		velocity = input_dir * speed
		move_and_slide()
		moving = true
	else:
		animation_tree['parameters/conditions/idle'] = true
		animation_tree['parameters/conditions/is_moving'] = false
		

func move(delta):
	velocity = input_dir * speed
	moving = false
	move_and_slide()
			
func move_false():
	moving = false
