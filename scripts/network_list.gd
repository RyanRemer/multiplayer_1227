class_name NetworkList extends Node

var list := {};

signal spawned(id, props, owner);
signal updated(id, old_props, new_props);

@rpc("any_peer", "call_local")
func spawn(id, props, owner):
	list[id] = [owner, props];
	sync_spawn.rpc(id, props, owner);

@rpc("authority", "call_local")	
func sync_spawn(id, props, owner):
	list[id] = [owner, props];
	spawned.emit(id, props, owner);
	
@rpc("any_peer", "call_local")
func update(id, props):
	#ownership check
	if list.has(id) and multiplayer.get_remote_sender_id() == list[id][0]:
		updated.emit(id, list[id][1], props);
		list[id][1] = props;
		sync_update.rpc(id, props);
		
@rpc("authority", "call_local")
func sync_update(id, props):
	if list.has(id):
		updated.emit(id, list[id][1], props)
		list[id][1] = props;
	else:
		request_list.rpc_id(1);
	
@rpc("any_peer", "call_local")
func request_list():
	sync_list.rpc(list);

@rpc("authority", "call_local")	
func sync_list(list):
	list = list;
