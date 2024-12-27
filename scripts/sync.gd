extends Node

# concept of starts and syncs, if you don't have an old value, set it, otherwise be smooth

var syncs := {};
signal on_sync_update(peer_id, old_sync, new_sync);

func _ready() -> void:
	Lobby.player_connected.connect(on_player_connected);

func emit(id, sync):
	syncs[id] = sync;
	send_sync.rpc_id(1, id, sync);
	
# Send sync to server
@rpc("any_peer", "call_local")
func send_sync(id, sync):
	syncs[id] = sync;
	
	# Update sync for clients
	update_sync.rpc(id, sync);
		
# Send sync to clients
@rpc("authority", "call_local")
func update_sync(id, sync):
	on_sync_update.emit(id, syncs[id] if syncs.has(id) else {}, sync);
	syncs[id] = sync;

func on_player_connected(peer_id, player_info):
	send_state.rpc_id(peer_id, syncs);

@rpc("authority", "call_local")	
func send_state(server_syncs):
	syncs = server_syncs;
