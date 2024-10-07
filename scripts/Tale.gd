extends Node2D

var is_response_processed: bool = false
var variables: Node
var tale_data: Dictionary
const dialogue_component = preload("res://components/Dialogue.tscn")

func _ready():
	variables = get_node("/root/Variables")
	get_tale()

func _process(delta):
	pass

func _on_http_request_request_completed(result, response_code, headers, body):
	if is_response_processed:
		return
	is_response_processed = true
	var json = JSON.parse_string(body.get_string_from_utf8())
	tale_data = json
	render_dialogues()

func get_tale():
	var http_request = $HTTPRequest
	http_request.request(variables.URL_Back + "/tale/id/" + variables.tale_id, ["Cookie:token=" + variables.cookie])

func render_dialogues() -> void:
	var title = $Title
	title.text = tale_data["name"]
	var dialogues = tale_data["dialogues"]

	var timer = $Timer
	for dialogue in dialogues:
		var dialogue_instance = dialogue_component.instantiate()
		dialogue_instance.get_nodes()
		var character = dialogue["character"]

		dialogue_instance.set_data(character["name"], character["urlImage"], dialogue["text"])
		$MarginContainer/ScrollContainer/DialogueVB.add_child(dialogue_instance)
		timer.start(2.0)
		await timer.timeout
