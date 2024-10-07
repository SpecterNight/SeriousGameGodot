extends PanelContainer

var container_dialogue: VBoxContainer
var is_response_processed: bool = false
var variables: Node
var avatar_name: String

var decision1
var decision2
var btnOk: Button
var btnError: Button
var isRecorded: bool = false
var attemps: int = 0
var isRecording: bool = false

var STT

func _ready():
	variables = get_node("/root/Variables")
	OS.request_permission("RECORD_AUDIO")
	if Engine.has_singleton("SpeechToText"):
		STT = Engine.get_singleton("SpeechToText")
		STT.setLanguage("es_US")
		STT.error.connect(_on_error)
		STT.listening_completed.connect(_on_listening_completed)
	get_avatar()	

func _process(delta):
	pass

func set_data(chr_name: String, character: String, dialogue, nextDialogue):
	avatar_name = character
	var chr_name_label = container_dialogue.get_node("CharacterName")
	var decision1L = container_dialogue.get_node("Decision1")
	var decision2L = container_dialogue.get_node("Decision2")
	chr_name_label.text = chr_name
	decision1 = dialogue
	decision2 = nextDialogue
	decision1L.text = dialogue["text"]
	decision2L.text = nextDialogue["text"]

func get_nodes():
	container_dialogue = get_node("VBoxContainer")
	btnOk = container_dialogue.get_node("BtnOk")
	btnError = container_dialogue.get_node("BtnBorrar")

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

func compareTranscript():
	var decision = {
		"text":"",
		"error":"",
		"duration":0,
		"consequence":""
	}
	var transcript = container_dialogue.get_node("Transcript").text.to_lower()
	var consequence = ""
	print("Transcribe ",transcript)
	decision["text"] = decision1["text"] + " o " + decision2["text"]
	if(transcript == decision1["text"].to_lower()):
		consequence = decision1["consequence"]
		isRecorded = true
	elif (transcript == decision2["text"].to_lower()):
		consequence = decision2["consquence"]
		isRecorded = true
	else:
		consequence = "ERROR"
		decision["error"] = transcript
		
	consequence = decision1["consequence"]	
	if(consequence != "ERROR"):
		var conseq = Label.new()
		conseq.text = consequence
		decision["consequence"] = consequence	
		conseq.add_theme_font_size_override("font_size",35)
		container_dialogue.add_child(conseq)
		isRecorded = true
		
	print(attemps)
	if(attemps == 5):
		print("cancela")
		isRecorded = true
	attemps += 1
	variables.add_decision(decision)

func _on_btn_borrar_pressed() -> void:
	if !isRecording:
		STT.listen()
		btnError.text = "Parar"
		isRecording = !isRecording
	else:
		btnError.text = "Grabar"
		STT.stop()
		isRecording = !isRecording


func _on_btn_ok_pressed() -> void:
	compareTranscript()

func _on_error(errorcode):
	print("Error",errorcode)

func _on_listening_completed(args):
	print("llega")
	var transcript = container_dialogue.get_node("Transcript")
	print(args)
	transcript.text = str(args)

func save_decision(decision):
	pass
