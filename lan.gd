extends Node

@export_category("UI")
@export var connect_ui: Control
@export var address_input: LineEdit
@export var port_input: LineEdit

func async_condition(cond: Callable, timeout: float = 10.0) -> Error:
	timeout = Time.get_ticks_msec() + timeout * 1000
	while not cond.call():
		await get_tree().process_frame
		if Time.get_ticks_msec() > timeout:
			return ERR_TIMEOUT
	return OK


func host():
	var host = _parse_input()
	if host.size() == 0:
		return ERR_CANT_RESOLVE

	var port = host.port

	# Start host
	print("Starting host on port %s" % port)
	
	var peer = ENetMultiplayerPeer.new()
	if peer.create_server(port) != OK:
		print("Failed to listen on port %s" % port)

	get_tree().get_multiplayer().multiplayer_peer = peer
	print("Listening on port %s" % port)
	
	# Wait for server to start
	await async_condition(
		func():
			return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)

	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		OS.alert("Failed to start server!")
		return
	
	print("Server started")
	get_tree().get_multiplayer().server_relay = true
	
	# NOTE: This is not needed when using NetworkEvents
	# However, this script also runs in multiplayer-simple where NetworkEvents
	# are assumed to be absent, hence starting NetworkTime manually
	NetworkTime.start()

func join():
	var host = _parse_input()
	if host.size() == 0:
		return ERR_CANT_RESOLVE
		
	var address = host.address
	var port = host.port

	# Connect
	print("Connecting to %s:%s" % [address, port])
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, port)
	if err != OK:
		OS.alert("Failed to create client, reason: %s" % error_string(err))
		return err

	get_tree().get_multiplayer().multiplayer_peer = peer
	
	# Wait for connection process to conclude
	await async_condition(
		func():
			return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)

	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		OS.alert("Failed to connect to %s:%s" % [address, port])
		return

	print("Client started")
	
	# NOTE: This is not needed when using NetworkEvents
	# However, this script also runs in multiplayer-simple where NetworkEvents
	# are assumed to be absent, hence starting NetworkTime manually
	NetworkTime.start()

func _parse_input() -> Dictionary:
	# Validate inputs
	var address = "localhost"
	var port = "30312"
	
	if address == "":
		OS.alert("No host specified!")
		return {}
		
	if not port.is_valid_int():
		OS.alert("Invalid port!")
		return {}
	port = port.to_int()

	return {
		"address": address,
		"port": port
	}


func _on_join_pressed() -> void:
	join()


func _on_host_pressed() -> void:
	host()
