@tool
extends Node3D

@export_tool_button('Reposition') var reposition_button = reposition_button_callback
@export var camera_distance:float = 10
@export var camera_pitch:float = 0
@export var camera_yaw:float = 0


func reposition_button_callback() -> void:
	%Camera.position = Vector3.ZERO
	%Camera.rotation = Vector3.ZERO
	%Camera.rotate_x(camera_pitch)
	%Camera.rotate_y(camera_yaw)
	%Camera.translate_object_local(%Pad.position + Vector3(0,0,camera_distance))
