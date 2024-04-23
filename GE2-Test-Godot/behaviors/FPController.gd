extends Node3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@export var sensitivity = 0.1
@export var speed:float = 1.0
@export var draw_Gizmo = true

var move_and_slide
var max_speed

var controlling = true

var left:XRController3D
var right:XRController3D


var force
var length
var frequncy
var start_angle
var base_size
var multiplier
var velocity 

var target
var slowing_radius

var boid
var feeler

var MovementEnabled
var movement = false
var pause


func draw_gizmos_recursive(gizzy):
	draw_Gizmo = gizzy
	var children = get_children()
	for child in children:
		if child is SteeringBehavior:
			child.draw_gizmos = gizzy

func on_draw_gizmos():
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.z * 10.0 , Color(0, 0, 1), 0.1)
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.x * 10.0 , Color(1, 0, 0), 0.1)
	DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + transform.basis.y * 10.0 , Color(0, 1, 0), 0.1)
	#DebugDraw3D.draw_arrow(global_transform.origin,  global_transform.origin + force, Color(1, 1, 0), 0.1)
	
	if MovementEnabled:
		DebugDraw3D.draw_sphere(movement, 1, Color.RED)

func _input(event):
	if event is InputEventMouseMotion and controlling:
		rotate(Vector3.DOWN, deg_to_rad(event.relative.x * sensitivity))
		rotate(transform.basis.x,deg_to_rad(- event.relative.y * sensitivity))
	if event.is_action_pressed("ui_cancel"):
		if controlling:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:			
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		controlling = ! controlling
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			get_tree().quit()
		


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

@export var can_move:bool = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if draw_Gizmo:
		on_draw_gizmos()
		
	if can_move:
		var v = Vector3.ZERO
		
		var mult = 1
		if Input.is_key_pressed(KEY_SHIFT):
			mult = 3
		
		if left:
			var joy = left.get_vector2("primary")
			var cam_basis = $XROrigin3D/XRCamera3D.global_transform.basis
			global_translate(cam_basis.z * speed * mult * delta * -joy.y)
			global_translate(cam_basis.x * speed * mult * delta * joy.x)
				
		var turn = Input.get_axis("turn_left", "turn_right") - v.x	
		if abs(turn) > 0:     
			global_translate(global_transform.basis.x * speed * turn * mult * delta)
		
		var movef = Input.get_axis("move_forward", "move_back")
		if abs(movef) > 0:     
			global_translate(global_transform.basis.z * speed * movef * mult * delta)
		
		var upanddown = Input.get_axis("move_up", "move_down")
		if abs(upanddown) > 0:     
			global_translate(- global_transform.basis.y * speed * upanddown * mult * delta)

func seek_force(target: Vector3):	
	var toTarget = target - global_transform.origin
	toTarget = toTarget.normalized()
	var desired = toTarget * max_speed
	return desired - velocity
