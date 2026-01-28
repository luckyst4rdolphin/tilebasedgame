extends CharacterBody2D

var tile_size = 32
var input_dir = Vector2.ZERO
var moving = false
var stop_input: bool = false
var speed = 200.0
var facing := Vector2.DOWN
var sliding := false

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var ray: RayCast2D = $RayCast2D
@onready var slide: TileMapLayer = $"../slide"

func snap_feet_to_tile():
	var cell := slide.local_to_map(slide.to_local(global_position))
	var center_local := slide.map_to_local(cell) 

	# Put "feet" at bottom-center of that cell (Pokemon-style).
	var feet_local := center_local + Vector2(0, tile_size / 2.0)

	global_position = slide.to_global(feet_local)

func _ready():
	$RayCast2D.position = Vector2(0, -8)
	animation_tree.active = true
	snap_feet_to_tile()
	
func _physics_process(_delta):
	if stop_input or moving:
		return

	# ignores input if player is sliding
	if sliding:
		_try_step(facing)
		return

	# read input
	input_dir = Vector2.ZERO
	if Input.is_action_pressed("right"):
		input_dir = Vector2.RIGHT
	elif Input.is_action_pressed("left"):
		input_dir = Vector2.LEFT
	elif Input.is_action_pressed("down"):
		input_dir = Vector2.DOWN
	elif Input.is_action_pressed("up"):
		input_dir = Vector2.UP

	if input_dir != Vector2.ZERO:
		facing = input_dir
		animation_tree["parameters/Idle/blend_position"] = input_dir
		animation_tree["parameters/Walk/blend_position"] = input_dir
		_try_step(input_dir)
	else:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
		
func _try_step(dir: Vector2) -> void:
	# collision check: point ray toward the next tile and update immediately.
	ray.target_position = dir * tile_size
	ray.force_raycast_update()
	if ray.is_colliding():
		sliding = false
		return
	
	await _step_one_tile(dir)

	sliding = is_on_slippery()

func _step_one_tile(dir: Vector2) -> void:
	moving = true
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/is_moving"] = true

	var target = global_position + dir * tile_size
	var t := create_tween()
	t.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	t.tween_property(self, "global_position", target, tile_size / speed)
	await t.finished
	moving = false

func is_on_slippery() -> bool:
	var sample_pos := global_position + Vector2(0, -1)
	var cell := slide.local_to_map(slide.to_local(sample_pos))
	var td := slide.get_cell_tile_data(cell)
	return td != null and bool(td.get_custom_data("is_slippery"))
