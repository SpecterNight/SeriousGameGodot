extends Control

var words: Array
var variables:Node
var is_response_processed: bool = false

var number_words: int = 0
var word_count: int = 0

var position_letters: Array = []
var last_position: int = -1
var errors: int = 0
var corrects: int = 0

var incomplete_word: Array = []
var actual_word: Array = []
var actual_attemp: Array = []

const letter_component = preload("res://components/Letter.tscn")

func _ready():
	variables = get_node("/root/Variables")
	$Container_game/game_area/header_error/number_error.text = str(errors)
	get_words()
	$Container_game/game_area.hide()
	$Container_game/game_over.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")


func _on_btn_start_pressed():
	var input_words = $Container_game/header_area/number_words
	number_words = int(input_words.text)
	if(number_words > 0):
		render_word()
		$Container_game/header_area/btn_start.disabled = true
		$Container_game/game_area.show()
	else:
		print("Ingrese un número válido")

func get_words():
	var http_request = $HTTPRequest
	http_request.request(variables.URL_Back + "/minigame/all", ["Cookie:token=" + variables.cookie])

func _on_http_request_request_completed(result, response_code, headers, body):
	if is_response_processed:
		return
	is_response_processed = true
	var json = JSON.parse_string(body.get_string_from_utf8())
	words = json
	$Container_game/header_area/max_words.text = "Máximo de palabras: "+str(words.size())

func render_word():
	var word_container = $Container_game/game_area/word
	var letters_ui = word_container.get_children()
	for letter_ui in letters_ui:
		letter_ui.free()
		
	var word = words[word_count]
	var letters = word.word.to_lower().split("")

	actual_word = letters

	incomplete_word =  []
	var vowels = ["a", "e", "i", "o", "u"]

	for i in range(letters.size()):
		if letters[i] in vowels:
			position_letters.append(i)
			incomplete_word.append("_")
		else:
			incomplete_word.append(letters[i])

	actual_attemp = incomplete_word

	for i in range(incomplete_word.size()):
		var letter_comp = letter_component.instantiate()
		letter_comp.set_data(incomplete_word[i])
		letter_comp.name = "Letter_" + str(i)
		word_container.add_child(letter_comp)
	
func _on_vowel_pressed(extra_arg_0):
	var current_position = 0
	if(last_position==-1):
		current_position = position_letters[0]
	else:
		current_position = position_letters[last_position+1]
	
	actual_attemp[current_position] = extra_arg_0
	
	var letter_comp = $Container_game/game_area/word.get_node("Letter_"+str(current_position)).get_node("vowel")
	letter_comp.text = extra_arg_0
	last_position+=1
	
	if("_" not in actual_attemp):
		var correct_word =  "".join(actual_word).to_lower()
		var currect_attemp = "".join(actual_attemp).to_lower()
		if(correct_word == currect_attemp):
			corrects +=1
			$Container_game/game_area/header_ok/number_ok.text = str(corrects)
			word_count += 1
		else:
			errors += 1
			$Container_game/game_area/header_error/number_error.text = str(errors)
		if(word_count == number_words):
			$Container_game/game_area.hide()
			$Container_game/game_over.show()
		render_word() 		
	

func _on_vowel_delete_pressed():
	if(last_position!=-1):
		var letter_comp = $Container_game/game_area/word.get_node("Letter_"+str(position_letters[last_position])).get_node("vowel")
		letter_comp.text = "_"
		last_position+=-1
	


func _on_btn_gameover_pressed():
	$Container_game/header_area/btn_start.disabled = false
	$Container_game/game_over.hide()
