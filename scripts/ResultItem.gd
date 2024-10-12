extends PanelContainer

const decision_component = preload("res://components/DecisionItem.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_data(date: String, decisions:Array):
	$HBoxContainer/Date.text = date
	for decision in decisions:
		var dec_comp = decision_component.instantiate()
		dec_comp.set_data(decision)
		$HBoxContainer.add_child(dec_comp)
