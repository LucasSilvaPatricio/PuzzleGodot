extends Node3D

class_name tabuleiro

@export var static_bodys :Array[StaticBody3D]
@onready var raycast :RayCast3D = $RayCast3D
@onready var win_scene :PackedScene = preload("res://scenes/win.tscn")
# verificar -1 e +1 casas
# verificar -4 e + 4 casas
enum direction {LEFT,RIGHT, UP, DOWN, NONE}

var win = true
var scene_win :Control
var tab_positions = { 0:0,1:1, 2:2, 3:3,
				   4:4, 5:5, 6:6, 7:7,
				   8:8, 9:9, 10:10, 11:11,
				   12:12, 13:13, 14:14, 15:-1
				}
				
var original_positions = tab_positions.duplicate()
#var tab_positions = [
#					0,1,2,3, # 0, 1, 2, 3
#					4,5,6,7, # 4, 5, 6, 7
#					8,9,10,11, # 8, 9, 10, 11
#					12,13,14,-1 # 12, 13, 14, null
#					]
					
func _ready() -> void:
	
	random_box()
	debugger()
	
	win = _check_win()
	
	scene_win = win_scene.instantiate()
	add_child(scene_win)
	scene_win.visible=false
	
func _process(_delta: float) -> void:
	$Label.text = "win="+str(win)

func change_position(index :int) -> Variant:

	if tab_positions[index] == -1:
		return

	var direction_move :direction = direction.NONE
	var next_index = index+1 
	var prev_index = index-1
	var up_index = index-4
	var down_index = index+4
	var curr_index = index
	var lenght = tab_positions.size()-1
	var mesh = get_node("M"+str(tab_positions[curr_index]))
	var speed = 0.1

	if tab_positions[next_index if next_index <= lenght else curr_index] == -1:
		var now = tab_positions[curr_index]
		tab_positions[curr_index] = tab_positions.get(next_index)
		tab_positions[next_index] = now
		direction_move = direction.RIGHT
		
	elif tab_positions[prev_index if prev_index >= 0 else curr_index ] == -1:	
		var now = tab_positions[curr_index]
			
		tab_positions[curr_index] = tab_positions.get(prev_index)
		tab_positions[prev_index] = now
		direction_move = direction.LEFT

	elif tab_positions[up_index if up_index >= 0 else curr_index] == -1:	
		var now = tab_positions[curr_index]
		tab_positions[curr_index] = tab_positions.get(up_index)
		tab_positions[up_index] = now
		direction_move = direction.UP	
	
	elif tab_positions[down_index if down_index <= lenght else curr_index] == -1:	
		
		var now = tab_positions[curr_index]
		tab_positions[curr_index] = tab_positions.get(down_index)
		tab_positions[down_index] = now
		direction_move = direction.DOWN
	else:
		direction_move = direction.NONE
	
	var t = null
	if direction_move != direction.NONE:						
		t= get_tree().create_tween()
	
	match direction_move:
		
		direction.LEFT: 
			t.tween_property(mesh,"position",mesh.position+Vector3(-0.4,0,0), speed)
			#mesh.position = mesh.position + Vector3(-0.4,0,0) 
		direction.RIGHT: 
			t.tween_property(mesh,"position",mesh.position+Vector3(0.4,0,0), speed)
			#mesh.position = mesh.position + Vector3(0.4,0,0)
		direction.UP: 
			t.tween_property(mesh,"position",mesh.position+Vector3(0,0,-0.4), speed)
			#mesh.position = mesh.position + Vector3(0,0,-0.4)
		direction.DOWN:
			t.tween_property(mesh,"position",mesh.position+Vector3(0,0,0.4), speed) 
			#mesh.position = mesh.position + Vector3(0,0,0.4)
	debugger()
	win = _check_win()
	
	if win:
		scene_win.visible=true
		
	return direction_move

func random_box() -> void:
	var numbers = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
	for key in tab_positions.keys():
		if key != tab_positions.size()-1:
			var value = numbers.pick_random()
			numbers.erase(value)
			tab_positions[key] = value
			var mesh :MeshInstance3D = get_node("M"+str(value))
			mesh.position = static_bodys[key].position
		else:
			tab_positions[key] = -1
	pass
	
func debugger() -> void:
	var str_f = ""
	var c = 1
	for i in tab_positions.keys():
		str_f+=str(tab_positions[i])+"|,"
		if(c%4==0 and c > 1):
			str_f+="\n"
		c+=1
	print(str_f)
	str_f = ""

func _check_win() -> bool:
	return true if tab_positions == original_positions else false

func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			raycast.position = Vector3(event_position.x,raycast.position.y,event_position.z)
			await get_tree().process_frame
			if(raycast.is_colliding()):
				var mesh_name = raycast.get_collider().get("name")
				change_position(int(mesh_name))
