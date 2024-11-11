extends PanelContainer

var container_dialogue: VBoxContainer
var is_response_processed: bool = false
var variables: Node
var avatar_name: String

var decision1
var decision2
var btnOk: Button
var btnGrabar: Button
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
	btnGrabar = container_dialogue.get_node("BtnGrabar")

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
	attemps += 1
	var decision = {
		"text":"",
		"textAlternative":"",
		"userText":"",
		"lettersOmmited": [],
		"consequence":""
	}
	var transcript = container_dialogue.get_node("Transcript").text.to_lower()
	var consequence = ""
	print("Transcribe ",transcript)
	decision["text"] = decision1["text"]
	decision["textAlternative"] = decision2["text"]
	
	var transcript_words = transcript.split(" ")
	var decision1_words = decision1["text"].to_lower().split(" ")
	var decision2_words = decision2["text"].to_lower().split(" ")
	
	var result = compare_words(transcript_words, decision1_words)
	
	if result ["match"]:
		consequence = decision1["consequence"]
		isRecorded = true
	else:
		result = compare_words(transcript_words, decision2_words)
		if result["match"]:
			consequence = decision2["consequence"]
			isRecorded = true
		else:
			consequence = "ERROR"
			decision["error"] = result["errors"]
		
	if(consequence != "ERROR"):
		var conseq = Label.new()
		conseq.text = consequence
		decision["consequence"] = consequence	
		conseq.add_theme_font_size_override("font_size",35)
		container_dialogue.add_child(conseq)
		isRecorded = true
		
	container_dialogue.get_node("Transcript").text = ""
	variables.add_decision(decision)
	
	if(attemps == 5):
		isRecorded = true

func compare_words(transcript_words, decision_words):
	if transcript_words.size() < decision_words.size():
		return {"match": false, "errors": decision_words}
	var errors = ""
	for i in range(decision_words.size()):
		if transcript_words[i] != decision_words[i]:
			errors += transcript_words[i] + " "
	return {"match": errors.strip_edges() == "", "errors": errors.strip_edges()}
	
func _on_btn_grabar_pressed() -> void:
	if !isRecording:
		STT.listen()
		btnGrabar.text = "Parar"
		isRecording = !isRecording
	else:
		btnGrabar.text = "Grabar"
		STT.stop()
		isRecording = !isRecording


func _on_btn_ok_pressed() -> void:
	if container_dialogue.get_node("Transcript").text != "":
		compareTranscript()

func _on_error(errorcode):
	print("Error",errorcode)

func _on_listening_completed(args):
	var transcript = container_dialogue.get_node("Transcript")
	transcript.text = str(args)

