extends Control

var variables: Node
# Called when the node enters the scene tree for the first time.
func _ready():
	variables = get_node("/root/Variables")# Replace with function body.
	set_data()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_data():
	var errors = cont_errors() 
	var message = $PanelContainer/VBoxContainer/Errors.text
	$PanelContainer/VBoxContainer/Errors.text = message + str(errors)

func _on_button_pressed():
	variables.reset_data()
	get_tree().change_scene_to_file("res://scenes/TaleSelect.tscn") # Replace with function body.

func cont_errors() -> int:
	var decisions = variables.result["decisions"]
	var errors = 0
	for decision in decisions:
		if(decision["lettersOmmited"].size()>0):
			errors += 1
	return errors
