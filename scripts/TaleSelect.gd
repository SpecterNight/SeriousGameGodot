extends Control

var tales: Array
var variables: Node
var is_response_processed: bool = false

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
		var panel = Button.new()
		var tale_vbox = VBoxContainer.new()
		panel.name = tale["externalId"]
		var name_tale = Label.new()
		var desc_tale = Label.new()

		panel.custom_minimum_size = Vector2(200, 100)
		name_tale.text = tale["name"]
		name_tale.add_theme_font_size_override("normal", 45)
		desc_tale.text = tale["description"]
		tale_vbox.add_child(name_tale)
		tale_vbox.add_child(desc_tale)
		panel.connect("pressed", Callable(self, "_on_panel_pressed").bind(tale["externalId"]))
		panel.add_child(tale_vbox)
		tales_container.add_child(panel)

func _on_panel_pressed(tale_id):
	to_scene_activities(tale_id)

func to_scene_activities(tale_id):
	variables.tale_id = tale_id
	get_tree().change_scene("res://scenes/Tale.tscn")
