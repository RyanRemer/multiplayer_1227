extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn");

var players := {}

func _ready() -> void:
	Lobby.player_disconnected.connect(on_player_disconnected);

func _process(delta: float) -> void:
	for peer_id in Lobby.players:
		if not players.has(peer_id):
			var player: Player =  player_scene.instantiate();
			player.peer_id = peer_id;
			player.player_info = Lobby.players[peer_id];
			if Sync.state.has(peer_id):
				player.position = Sync.state[peer_id]["position"];
			add_child(player);
			players[peer_id] = player;
			
func on_player_disconnected(peer_id):
	var player = players[peer_id];
	remove_child(player);
	players.erase(peer_id);
