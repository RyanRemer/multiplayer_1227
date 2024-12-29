extends Node

# state of the world, as we know it locally
var state := {};

# listen to this to update our state to match
signal state_update(substate_id, old, new);

# use this to update the state we own
func update(substate_id, sub_state):
	state[substate_id] = sub_state;
	send_update.rpc_id(1, substate_id, sub_state);
	
@rpc("any_peer", "call_local")
func send_update(substate_id, sub_state):
	state[substate_id] = sub_state;
	sync_update.rpc(substate_id, sub_state);
	
@rpc("authority", "call_local")
func sync_update(substate_id, sub_state):
	state_update.emit(substate_id, state[substate_id] if state.has(substate_id) else {}, sub_state);
	state[substate_id] = sub_state;
	
func on_player_connected(peer_id, player_info):
	send_entire_state.rpc_id(peer_id, state);
	
@rpc("authority", "call_local")
func send_entire_state(server_state):
	state = server_state;
	print(multiplayer.get_unique_id(), state);
