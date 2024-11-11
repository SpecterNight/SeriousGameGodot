extends Node

var cookie: String
var URL_Back: String
var tale_id: String

var result: Dictionary = {
	"tale": "",
	"decisions": []
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	URL_Back = "http://localhost:3006/api/v1"
	#URL_Back = "http://192.168.43.186:3006/api/v1"
	#URL_Back = "http://192.168.3.40:3006/api/v1"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Función para actualizar el nombre en el JSON
func set_result_tale(tale: String) -> void:
	result["tale"] = tale

# Función para agregar una decisión al array de decisiones
func add_decision(decision: Dictionary) -> void:
	result["decisions"].append(decision)

func reset_data() -> void:
	result = {
		"tale": "",
		"decisions": []
	}
