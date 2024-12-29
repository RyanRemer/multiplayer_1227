class_name Player extends CharacterBody2D

@export var player_info := {};
@export var peer_id = 1;

var server_position = Vector2.ZERO;

const SPEED = 128;

func _ready() -> void:
	Sync.state_update.connect(on_state_update);
	server_position = position;
	
func on_state_update(substate_id, old_state, new_state):
	if substate_id != peer_id:
		return;
	
	if old_state.is_empty():
		position = new_state["position"];
	server_position = new_state["position"];

func _process(delta: float) -> void:
	if multiplayer.get_unique_id() == peer_id:
		_process_self(delta);
	else:
		_process_other(delta);
	
func _process_self(_delta: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	velocity = input_dir * SPEED;
	move_and_slide();
	
	if velocity.length_squared() > 0:
		Sync.update(peer_id, {
			"position": position
		});
	
func _process_other(delta: float) -> void:
	var direction: Vector2 = server_position - position;
	if direction.length_squared() >= 1:
		velocity = direction.normalized() * SPEED;
		move_and_slide();
