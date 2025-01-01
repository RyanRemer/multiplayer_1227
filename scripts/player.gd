class_name Player extends CharacterBody2D

@export var player_info := {};
@export var peer_id = 1;
var props := {
	"position" : Vector2.ZERO,
};

const SPEED = 128;

var old_position := Vector2.ZERO;

func _ready() -> void:
	position = props["position"];

func _process(delta: float) -> void:	
	if multiplayer.get_unique_id() == peer_id:
		_process_self(delta);
	else:
		_process_other(delta);
	
func _process_self(_delta: float) -> void:	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	velocity = input_dir * SPEED;
	move_and_slide();
	
	if position.distance_squared_to(props["position"]) >= 64:
		props["position"] = position;
		NetworkPlayers.update.rpc_id(1, peer_id, props);

func _process_other(_delta: float) -> void:
	var direction: Vector2 = props["position"] - position;
	if direction.length_squared() > 128:
		position = props["position"];
	elif direction.length_squared() > 1:
		velocity = direction.normalized() * SPEED;
		move_and_slide();
	else:
		position = props["position"];
