extends Control

var username: LineEdit
var password: LineEdit
var variables: Node
var is_response_processed: bool = false

func _ready():
	username = $VBoxContainer/txtUsuario
	password = $VBoxContainer/txtClave
	variables = get_node("/root/Variables")

func _process(delta):
	pass

func _on_login_req_request_completed(result, response_code, headers, body):
	if is_response_processed:
		return
	is_response_processed = true

	var cookie = headers[4]
	var pattern = "token=([^;]+)"
	var regex = RegEx.new()
	regex.compile(pattern)
	var match = regex.search(cookie)
	if match:
		var token = match.get_string(1)
		variables.cookie = token
		var payload = token.split(".")[1]
		var json_string = Marshalls.base64_to_utf8(convert_base64(payload))
		var account = JSON.parse_string(json_string)
		print(account)
		if "role" in account:
			get_tree().change_scene_to_file("res://scenes/TaleSelect.tscn")

func convert_base64(base64: String) -> String:
	var mod = base64.length() % 4
	if mod > 0:
		for i in range(4 - mod):
			base64 += "="
	return base64.replace("-", "+").replace("_", "/")

func login():
	var data = {
		"email": username.text,
		"password": password.text
	}
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	var http_request = $loginReq
	http_request.request(variables.URL_Back + "/account/login", headers, HTTPClient.METHOD_POST, json)

func _on_tbn_iniciar_sesion_pressed():
	login()
