extends Node3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@export var sensitivity = 0.1
@export var speed:float = 1.0

var move_and_slide

var controlling = true

var left:XRController3D
var right:XRController3D

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

var pause


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
	
	#if event.is_action_pressed("pause"):
		


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.

@export var can_move:bool = true

func _redraw(gizmo):
	gizmo.clear()

	var node3d = gizmo.get_node_3d()

	var lines = PackedVector3Array()

	lines.push_back(Vector3(0, 1, 0))
	lines.push_back(Vector3(0, node3d.my_custom_value, 0))

	var handles = PackedVector3Array()

	handles.push_back(Vector3(0, 1, 0))
	handles.push_back(Vector3(0, node3d.my_custom_value, 0))

	DebugDraw3D.draw_sphere(target.global_transform.origin, slowing_radius, Color.VIOLET)
	DebugDraw3D.draw_line(boid.global_transform.origin, feeler.hit_target, Color.CHARTREUSE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

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

