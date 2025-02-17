extends Node

@onready var multiplayer_ui = $UI/UI_Multiplayer

const PLAYER = preload("res://PlayerCar/PlayerCar.tscn")
@onready var oid_lbl = $UI/UI_Multiplayer/VBoxContainer/OID
@onready var oid_input = $"UI/UI_Multiplayer/VBoxContainer/OID Input"

var peer = ENetMultiplayerPeer.new()

func _ready():
	await Multiplayer.noray_connected
	oid_lbl.text = Noray.oid

func _on_host_pressed():
	Multiplayer.host()
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("PEER " + str(pid) + " has joined")
			add_player(pid, Vector2(200, 50))
	)
	add_player(multiplayer.get_unique_id(), Vector2(50, 200))
	multiplayer_ui.hide()

func _on_join_pressed():
	Multiplayer.join(oid_input.text)
	
	multiplayer.multiplayer_peer = peer
	multiplayer_ui.hide()

func add_player(pid, offset = Vector2(0, 0)):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	player.position = offset
	add_child(player)


func _on_copy_oid_pressed():
	DisplayServer.clipboard_set(Noray.oid)
