extends Node

func _init():
	set_process(false)
	set_custom_multiplayer(MultiplayerAPI.new())
	custom_multiplayer.set_root_node(self)

func _ready():
	var err = multiplayer.connect("network_peer_connected", self, "_client_connected")
	err += multiplayer.connect("network_peer_disconnected", self, "_client_disconnected")
	err += multiplayer.connect("network_peer_packet", self, "_network_peer_packet")
	if err != OK: print("Error")
	
	start_server("127.0.0.1", 31500, 10)

func _exit_tree():
	multiplayer.disconnect("network_peer_connected", self, "_client_connected")
	multiplayer.disconnect("network_peer_disconnected", self, "_client_disconnected")
	multiplayer.disconnect("network_peer_packet", self, "_network_peer_packet")
	if multiplayer.has_network_peer(): 
		multiplayer.get_network_peer().close_connection()
		multiplayer.set_network_peer(null)

func _process(_delta):
	if multiplayer.has_network_peer(): multiplayer.poll()

func start_server(ip:String, port:int, maxClients:int):
	var peer = NetworkedMultiplayerENet.new()
	peer.set_bind_ip(ip)
	#peer.set_always_ordered(true)
	#peer.set_server_relay_enabled(false)
	#peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_ZSTD)
	var err = peer.create_server(port, maxClients)
	if err != OK:
		print("ERROR")
		return
	multiplayer.set_network_peer(peer)
	set_process(true)

###
func _client_connected(id):
	print("Connected peer ID:%s" % str(id))

func _client_disconnected(id):
	print("Disconnected peer ID:%s" % str(id))

func _network_peer_packet(id:int, packet:PoolByteArray):
	print("Network_peer_packet:%s" % str(packet))
	print("Network_peer_packet. ID: " + str(id))

###
remote func request_data():
	var clientID:int = multiplayer.get_rpc_sender_id()
	rpc_id(clientID, "response_data", "Hello World")







