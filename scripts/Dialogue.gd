extends PanelContainer

var container_dialogue: VBoxContainer
var is_response_processed: bool = false
var variables: Node
var avatar_name: String

func _ready():
	variables = get_node("/root/Variables")
	get_avatar()

func _process(delta):
	pass

func set_data(chr_name: String, character: String, text: String):
	avatar_name = character
	var chr_name_label = container_dialogue.get_node("CharacterName")
	var text_dialogue = container_dialogue.get_node("TextDialogue")
	chr_name_label.text = chr_name
	text_dialogue.text = text

func get_nodes():
	container_dialogue = get_node("VBoxContainer")

func _on_http_request_request_completed(result, response_code, headers, body):
	if is_response_processed:
		return
	is_response_processed = true
	load_avatar(body)

func load_avatar(body):
	var avatar = Image.new()
	var error = avatar.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")
	var image_texture = ImageTexture.create_from_image(avatar)

	var character_avatar = container_dialogue.get_node("Character")
	character_avatar.texture = image_texture

func get_avatar():
	var http_request = $HTTPRequest
	http_request.request(variables.URL_Back + "/avatar/id/" + avatar_name, ["Cookie:token=" + variables.cookie])
