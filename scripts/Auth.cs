using Godot;
using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

public partial class Auth : Control
{
	private LineEdit username;
	private LineEdit password;

	private Variables variables;

	private bool isResponseProcessed = false;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		username = GetNode<VBoxContainer>("VBoxContainer").GetNode<LineEdit>("txtUsuario");
		password = GetNode<VBoxContainer>("VBoxContainer").GetNode<LineEdit>("txtClave");
		variables = GetNode<Variables>("/root/Variables");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{

	}


	public void _on_login_req_request_completed(long result, long responseCode, string[] headers, byte[] body)
	{
		if (isResponseProcessed)
		{
			return;
		}
		isResponseProcessed = true;

		string cookie = headers[4];
		string pattern = @"token=([^;]+)";
		Match match = Regex.Match(cookie, pattern);
		string token = match.Groups[1].Value;
		variables.cookie = token;
		string payload = token.Split('.')[1];
		string jsonString = Marshalls.Base64ToUtf8(convertBase64(payload));
		Godot.Collections.Dictionary account = Json.ParseString(jsonString).AsGodotDictionary();
		GD.Print(account);
		if (account.ContainsKey("role"))
		{
			GetTree().ChangeSceneToFile("res://scenes/Menu.tscn");
		}
	}


	private string convertBase64(string base64)
	{
		int mod = base64.Length % 4;
		if (mod > 0)
		{
			base64 = base64.PadRight(base64.Length + (4 - mod), '=');
		}
		return base64.Replace("-", "+").Replace("_", "/");
	}
	private void Login()
	{
		Godot.Collections.Dictionary data = new Godot.Collections.Dictionary{
			{"email",username.Text},
			{"password",password.Text}
		};
		string json = Json.Stringify(data);
		string[] headers = new string[] { "Content-Type: application/json" };
		HttpRequest httpRequest = GetNode<HttpRequest>("loginReq");
		httpRequest.RequestCompleted += _on_login_req_request_completed;
		httpRequest.Request(variables.URL_Back + "/account/login", headers, HttpClient.Method.Post, json);
	}

	public void _on_tbn_iniciar_sesion_pressed()
	{
		Login();
	}


}
