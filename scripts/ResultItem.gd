extends PanelContainer

const decision_component = preload("res://components/DecisionItem.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_data(date: String, decisions:Array):
	$HBoxContainer/Date.text = format_date(date)
	for decision in decisions:
		var dec_comp = decision_component.instantiate()
		dec_comp.set_data(decision)
		$HBoxContainer.add_child(dec_comp)

func format_date(date_str: String) -> String:
	var date = Time.get_datetime_dict_from_datetime_string(date_str, false)
	var date_formated = '%s:%02d %02d:%02d:%s' % [date["hour"], date["minute"], date["day"], date["month"], date["year"]]
	return date_formated
