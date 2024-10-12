extends PanelContainer

var variables: Node
var tale_externalId: String
# Called when the node enters the scene tree for the first time.
func _ready():
	variables = get_node("/root/Variables")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_data(tale_title: String, tale_desc: String, tale_ext: String):
	$HBoxContainer/Title.text = tale_title
	$HBoxContainer/Description.text = tale_desc
	tale_externalId = tale_ext

func _on_btn_play_pressed():
	variables.tale_id = tale_externalId
	get_tree().change_scene_to_file("res://scenes/Tale.tscn")

func _on_btn_res_pressed():
	variables.tale_id = tale_externalId
	get_tree().change_scene_to_file("res://scenes/Results.tscn")# Replace with function body.
