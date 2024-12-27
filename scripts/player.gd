class_name Player extends CharacterBody2D

@export var player_info := {};
@export var peer_id = 1;

const SPEED = 128;

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
		Sync.emit(peer_id, {
			"position": position
		});
	
func _process_other(delta: float) -> void:
	if not Sync.syncs.has(peer_id):
		return;
	
	var sync = Sync.syncs[peer_id];
	
	if sync.has("position"):
		var direction: Vector2 = sync["position"] - position;
		if direction.length_squared() >= 1:
			velocity = direction.normalized() * SPEED;
			move_and_slide();
