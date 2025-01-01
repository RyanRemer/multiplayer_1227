class_name NetworkList extends Node

var list := {};

signal created(id, props);
signal updated(id, old_props, new_props);
signal deleted(id);
signal reloaded(list);

@rpc("any_peer", "call_local")
func create(id, props):
	if not list.has(id):
		list[id] = props;
		sync_create.rpc(id, props);

@rpc("authority", "call_local")	
func sync_create(id, props):
	list[id] = props;
	created.emit(id, props);
	
@rpc("any_peer", "call_local", "unreliable_ordered", 2)
func update(id, props):
	if list.has(id):
		updated.emit(id, list[id], props);
		list[id] = props;
		sync_update.rpc(id, props);
		
@rpc("authority", "call_local")
func sync_update(id, props):
	if list.has(id):
		updated.emit(id, list[id], props)
		list[id] = props;
	else:
		request_reload.rpc_id(1);

@rpc("any_peer", "call_local")
func delete(id):
	list.erase(id);
	sync_delete.rpc(id);

@rpc("authority", "call_local")	
func sync_delete(id):
	if list.has(id):
		deleted.emit(id);
		list.erase(id);
	
@rpc("any_peer", "call_local")
func request_reload():
	sync_reload.rpc_id(multiplayer.get_remote_sender_id(), list);

@rpc("authority", "call_local")	
func sync_reload(server_list):
	list = server_list;
	reloaded.emit(server_list);
