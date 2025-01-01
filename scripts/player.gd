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
	if old_position != position:
		print("Changed position ", old_position, " ", position);
	old_position = position;
	
	if multiplayer.get_unique_id() == peer_id:
		_process_self(delta);
	
func _process_self(_delta: float) -> void:	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	velocity = input_dir * SPEED;
	move_and_slide();
	
	if position.distance_squared_to(props["position"]) >= 64:
		props["position"] = position;
