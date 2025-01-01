extends Node2D

@onready var player_scene = preload("res://scenes/player.tscn");
var players := {}

func _ready() -> void:
	NetworkPlayers.created.connect(on_created);
	NetworkPlayers.updated.connect(on_updated);
	NetworkPlayers.deleted.connect(on_deleted);
	NetworkPlayers.reloaded.connect(on_reloaded);
	NetworkPlayers.request_reload.rpc_id(1);
	
	if multiplayer.is_server():
		Lobby.player_connected.connect(on_player_connected);
		Lobby.player_disconnected.connect(on_player_disconnect);
		NetworkPlayers.create(1, {
			"position": Vector2(500,500)
		})
	
func on_player_connected(peer_id, player_info):
	NetworkPlayers.create(peer_id, {
		"position": Vector2.ZERO
	})
	
func on_player_disconnect(peer_id):
	NetworkPlayers.delete(peer_id);
	
func on_reloaded(list):
	print(multiplayer.get_unique_id(), " Reload players: ", NetworkPlayers.list);
	for id in players:
		remove_child(players[id]);
		
	players.clear();
	
	for id in list:
		on_created(id, list[id]);

func on_created(id, props):
	print(multiplayer.get_unique_id(), " Create Player ", id, props);
	var player: Player = player_scene.instantiate();
	player.peer_id = id;
	player.props = props;
	add_child(player);
	players[id] = player;
	
func on_updated(id, old_props, new_props):
	players[id].props = new_props;
		
func on_deleted(id):
	print(multiplayer.get_unique_id(), " Remove Player ", id);
	if players.has(id):
		remove_child(players[id]);
		players.erase(id);
