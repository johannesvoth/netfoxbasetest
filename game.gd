extends Node2D

const BOX = preload("res://box.tscn")

@rpc("any_peer")  # Allow clients to call this
func request_spawn_box():
	if not multiplayer.is_server():
		return  # Only the server should handle actual spawning

	var box = BOX.instantiate()
	add_child(box)  # Adding on server will replicate to clients
	box.set_multiplayer_authority(multiplayer.get_remote_sender_id())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		request_spawn_box.rpc()  # Call the server to spawn the box


@onready var lobby_list: VBoxContainer = $LobbyList/VBoxContainer
var lobby_id: int = 0
var peer = SteamMultiplayerPeer.new()

func _ready():
	# Yeah so we need to do this here because the Steam autoload doesn't call it for some reason. I don't like it.
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)


# connected to button
func _on_host_steam_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	# MultiplayerManager.setLevel("res://level.tscn")

# connected below, steam stuff, also connected to button?
func _on_steam_join(lobby_id:int):
	peer.connect_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer

# connected above
func _on_lobby_match_list(these_lobbies: Array) -> void:
	if lobby_list.get_child_count() > 0:
		for n in lobby_list.get_children():
			n.queue_free()
	
	for this_lobby in these_lobbies:
		
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(this_lobby, "mode")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		
		
		var lobby_button: Button = Button.new()
		lobby_button.set_text("Lobby %s: %s [%s] - %s Player(s)" % [this_lobby, lobby_name, lobby_mode, lobby_num_members])
		lobby_button.set_size(Vector2(400/4, 25/4))
		lobby_button.set_name("lobby_%s" % this_lobby)
		lobby_button.connect("pressed", Callable(self, "_on_steam_join").bind(this_lobby))

		lobby_list.add_child(lobby_button)

# connected above
func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect == 1:
		lobby_id = this_lobby_id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print("Created lobby: ",str(Steam.getPersonaName()+"'s Lobby"))

# signal connected to button in scene
func _on_refresh_lobbies_pressed() -> void:
	_open_lobby_list()

func _open_lobby_list() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	print("305 Mr. Worldwide Requesting a lobby list")
	Steam.requestLobbyList()
