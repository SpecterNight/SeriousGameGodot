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

var decisionSelected: Object
var alternativeDecsion: Object

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

	var phrase_words = decisionSelected.text.to_lower().split(" ")
	var user_words = container_dialogue.get_node("Transcript").text.to_lower().split(" ")

	var letters_omitted = []
	var other_error = "Ninguno"

	var similarity_percentage = calculate_similarity(phrase_words, user_words)

	if similarity_percentage < 30:
		other_error = "Error en la frase completa: las frases no son similares"
	else:
		for i in range(phrase_words.size()):
			var word = phrase_words[i]
			var user_word = user_words[i] if i < user_words.size() else ""

			if user_word != word:
				if(has_omissions(word, user_word)):
					letters_omitted.append(word)
				else:
					other_error = "Hay un error que no es una omisión de letras"

	var decision = {
		"text":decisionSelected.text,
		"textAlternative": alternativeDecsion.text,
		"userText":container_dialogue.get_node("Transcript"),
		"lettersOmmited": letters_omitted,
		"consequence":decisionSelected.consequence,
		"otherError": other_error
	}
	variables.add_decision(decision)
	if(attemps == 5 || letters_omitted.size()==0):
		isRecorded = true
	

func calculate_similarity(text_words: Array, user_words:Array) -> float:
	var match_count = 0

	for word in text_words:
		if user_words.has(word):
			match_count += 1
	return (float(match_count) / text_words.size()) * 100

func has_omissions(correct_word:String, user_word:String)->bool:
	if user_word.length() >= correct_word.length():
		return false
	
	var i = 0
	var j = 0

	while i < correct_word.length() and j < user_word.length():
		if correct_word[i] == user_word[j]:
			j += 1
		i += 1
	return j == user_word.length()


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

