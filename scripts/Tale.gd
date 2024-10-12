extends Node2D

var is_response_processed: bool = false
var is_result_uploaded: bool = false
var variables: Node
var tale_data: Dictionary

const dialogue_component = preload("res://components/Dialogue.tscn")
const decision_component = preload("res://components/Decision.tscn")

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
	variables.set_result_tale(tale_data["externalId"])
	render_dialogues()

func get_tale():
	var http_request = $HTTPRequest
	http_request.request(variables.URL_Back + "/tale/id/" + variables.tale_id, ["Cookie:token=" + variables.cookie])

func render_dialogues() -> void:
	var title = $Title
	title.text = tale_data["name"]
	var dialogues = tale_data["dialogues"]

	var timer = $Timer
	
	var i = 0
	while i < dialogues.size():
		var dialogue = dialogues[i]
		if(dialogue["type"]=="DECISION"):
			var decision_instance = decision_component.instantiate()
			decision_instance.get_nodes()
			var character = dialogue["character"]
			var next_dialogue = dialogues[i+1] if i + 1 < dialogues.size() else null
			decision_instance.set_data(character["name"], character["urlImage"], dialogue, next_dialogue)
			$MarginContainer/ScrollContainer/DialogueVB.add_child(decision_instance)
			i += 2
			await wait_for_variable_true(decision_instance, "isRecorded")
		else:	
			var dialogue_instance = dialogue_component.instantiate()
			dialogue_instance.get_nodes()
			var character = dialogue["character"]

			dialogue_instance.set_data(character["name"], character["urlImage"], dialogue["text"])
			$MarginContainer/ScrollContainer/DialogueVB.add_child(dialogue_instance)
			i += 1
		timer.start(2.0)
		await timer.timeout
	upload_Result()

func wait_for_variable_true(instance, variable_name):
	while not instance.get(variable_name):
		await get_tree().create_timer(0.1).timeout

func upload_Result():
	var json = JSON.stringify(variables.result)
	var headers = ["Content-Type: application/json", "Cookie:token=" + variables.cookie]
	var http_request = $UploadResult
	http_request.request(variables.URL_Back + "/result/new", headers, HTTPClient.METHOD_POST, json)
	
func _on_upload_result_request_completed(result, response_code, headers, body):
	if(is_result_uploaded):
		return
	is_result_uploaded = true
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

