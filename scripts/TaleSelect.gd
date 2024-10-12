extends Control

var tales: Array
var variables: Node
var is_response_processed: bool = false

const tale_component = preload("res://components/TaleItem.tscn")

func _ready():
	variables = get_node("/root/Variables")
	get_tales()

func _process(delta):
	pass

func _on_http_request_request_completed(result, response_code, headers, body):
	if is_response_processed:
		return
	is_response_processed = true
	var json = JSON.parse_string(body.get_string_from_utf8())
	tales = json
	render_tales()

func get_tales():
	var http_request = $HTTPRequest
	http_request.request(variables.URL_Back + "/tale/all", ["Cookie:token=" + variables.cookie])

func render_tales():
	var tales_container = $ScrollContainer/Tales

	for tale in tales:
		var tale_comp = tale_component.instantiate()
		tale_comp.set_data(tale["name"], tale["description"], tale["externalId"])
		tales_container.add_child(tale_comp)
