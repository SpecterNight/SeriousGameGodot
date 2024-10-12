extends Control

var is_response_processed: bool = false
var results: Array
var variables: Node

const result_component = preload("res://components/ResultItem.tscn")
const decision_component = preload("res://components/DecisionItem.tscn")

func _ready():
	variables = get_node("/root/Variables")
	get_results()


func _process(delta):
	pass


func _on_get_results_request_completed(result, response_code, headers, body):
	if is_response_processed:
		return
	is_response_processed = true
	var json = JSON.parse_string(body.get_string_from_utf8())
	results = json
	render_results()

func render_results():
	var results_container = $MarginContainer/ScrollContainer/VBoxContainer
	for result in results:
		var result_com = result_component.instantiate()
		result_com.set_data(result["date"], result["decisions"])
		results_container.add_child(result_com)		

func get_results():
	var http_request = $getResults
	http_request.request(variables.URL_Back + "/results/tale/"+variables.tale_id, ["Cookie:token=" + variables.cookie])


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/TaleSelect.tscn") # Replace with function body.
