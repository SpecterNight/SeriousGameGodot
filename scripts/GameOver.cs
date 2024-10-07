using Godot;
using System;
using System.Text;

public partial class GameOver : Control{
	public Label score;
	public Label time;
	public Variables variables;
	private bool isResponseProcessed = false;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready(){
		variables = GetNode<Variables>("/root/Variables");
		initializeResult();
		saveScore();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta){
	}

	public void _on_regresar_pressed(){
		GetTree().ChangeSceneToFile("res://scenes/Menu.tscn");
	}

	private void initializeResult(){
		score = GetNode<Label>("Score");
		score.Text = variables.score.ToString();
		time = GetNode<Label>("Time");
		time.Text =  Math.Round(variables.time,2).ToString()+" Segundos";
	}

	public void _on_http_request_request_completed(long result, long responseCode, string[] headers, byte[] body){
		if (isResponseProcessed){
            return;
        }
        isResponseProcessed = true;
		Godot.Collections.Dictionary msg = Json.ParseString(Encoding.UTF8.GetString(body)).AsGodotDictionary();
		GD.Print(msg);
	}

	public void saveScore(){
		Godot.Collections.Dictionary data = new Godot.Collections.Dictionary{
			{"points",variables.score.ToString()},
			{"time",Math.Round(variables.time,2)},
			{"activityID",variables.activityId}
		};
		string json = Json.Stringify(data);
		string[] headers = new string[] { "Content-Type: application/json","Cookie:token="+variables.cookie};
		HttpRequest httpRequest = GetNode<HttpRequest>("HTTPRequest");
		httpRequest.RequestCompleted += _on_http_request_request_completed;
		httpRequest.Request(variables.URL_Back+"score/new",headers,HttpClient.Method.Post, json);
	}
}
