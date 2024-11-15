extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_data(decision):
	print(decision)
	$VBoxContainer/LettersOmited.text =  " ".join(decision["lettersOmmited"])
	$VBoxContainer/Consequence.text = decision["consequence"]
	$VBoxContainer/UserText.text = decision["userText"]
	$VBoxContainer/Text.text = decision["text"]
