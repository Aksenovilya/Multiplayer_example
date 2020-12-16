extends Node

func _init():
	set_process(false)
	set_custom_multiplayer(MultiplayerAPI.new())
	custom_multiplayer.set_root_node(self)

func _ready():
	var err = multiplayer.connect("network_peer_connected", self, "_peer_connected")
	err += multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	err += multiplayer.connect("connected_to_server", self, "_connected_to_server")
	err += multiplayer.connect("connection_failed", self, "_connected_failed")
	err += multiplayer.connect("server_disconnected", self, "_server_disconnected")
	err += multiplayer.connect("network_peer_packet", self, "_network_peer_packet")
	if err != OK: print("Error multiplayer connect ")
	
	start("127.0.0.1", 31500)

func _exit_tree():
	multiplayer.disconnect("connection_failed", self, "_connected_failed")
	multiplayer.disconnect("connected_to_server", self, "_connected_to_server")
	multiplayer.disconnect("network_peer_disconnected", self, "_peer_disconnected")
	multiplayer.disconnect("network_peer_connected", self, "_peer_connected")
	multiplayer.disconnect("server_disconnected", self, "_server_disconnected")
	multiplayer.disconnect("network_peer_packet", self, "_network_peer_packet")
	if multiplayer.has_network_peer(): 
		multiplayer.get_network_peer().close_connection()
		multiplayer.set_network_peer(null)

func _process(_delta):
	#if !multiplayer.has_network_peer(): return
	multiplayer.poll()

func start(ip: String, port: int):
	var peer = NetworkedMultiplayerENet.new()
	peer.set_always_ordered(true)
	var err = peer.create_client(ip, port)
	if err != OK:
		print("Error")
	multiplayer.set_network_peer(peer)
	set_process(true)

#EVENTS
func _peer_connected(id):
	print("_server_connected")
	print(id)

func _peer_disconnected(id):
	print("_server_disconnected")
	print(id)

func _connected_to_server():
	print("connected_to_server")
	rpc_id(1, "request_data") #TEST REQUEST

func _server_disconnected():
	print("server_disconnected")
	set_process(false)

func _connected_failed():
	print("connected_failed")
	set_process(false)

func _network_peer_packet(id:int, packet:PoolByteArray):
	print("Network_peer_packet:%s" % str(packet))
	print("Network_peer_packet. ID: " + str(id))

#RPC
remote func response_data(text:String):
	print(text)
