extends Node

var cookie: String
var URL_Back: String
var tale_id: String

var result: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	URL_Back = "http://localhost:3006/api/v1"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
