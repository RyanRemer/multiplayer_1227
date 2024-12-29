extends VBoxContainer

const PORT = 5656;

@onready var name_edit: LineEdit = $NameEdit
@onready var address_edit: LineEdit = $AddressEdit
@onready var label: Label = $Label

func _process(delta: float) -> void:
	if not Sync.state.is_empty():
		get_tree().change_scene_to_file("res://scenes/world.tscn");

func _on_host_button_pressed() -> void:
	Lobby.player_info["name"] = "Host" if name_edit.text.is_empty() else name_edit.text;
	Lobby.player_connected.connect(Sync.on_player_connected);
	Sync.update("world", {});
	Lobby.create_game();
	get_tree().change_scene_to_file("res://scenes/world.tscn");

func _on_join_button_pressed() -> void:
	Lobby.player_info["name"] = "Client" if name_edit.text.is_empty() else name_edit.text;
	Lobby.join_game(address_edit.text);
	
