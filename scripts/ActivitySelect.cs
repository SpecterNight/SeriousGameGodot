using Godot;
using System;
using System.Text;

public partial class ActivitySelect : Control
{
	private Godot.Collections.Array activities;
	private Variables variables;
	private bool isResponseProcessed = false;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready(){
		variables = GetNode<Variables>("/root/Variables");
		getActivities();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public void _on_http_request_request_completed(long result, long responseCode, string[] headers, byte[] body){
		if (isResponseProcessed){
            return;
        }
        isResponseProcessed = true;
		Godot.Collections.Array json = Json.ParseString(Encoding.UTF8.GetString(body)).AsGodotArray();
		activities = json;
		renderActivities();
	}

	private void getActivities(){
		HttpRequest httpRequest = GetNode<HttpRequest>("HTTPRequest");
		httpRequest.RequestCompleted += _on_http_request_request_completed;
		httpRequest.Request(variables.URL_Back+"activity/list/"+variables.categoryId,new string[]{"Cookie:token="+variables.cookie});
	}

	private void renderActivities(){
		HBoxContainer activitiesContainer = GetNode<ScrollContainer>("ScrollContainer").GetNode<HBoxContainer>("Activities");
		foreach (Godot.Collections.Dictionary activity in activities){
			Button panel = new();
			VBoxContainer activityVBox = new();
			panel.Name  = activity["externalID"].ToString();
			Label descActivity = new();
			panel.CustomMinimumSize = new Vector2(200,100);
			descActivity.Text = activity["description"].ToString();
			activityVBox.AddChild(descActivity);
			panel.AddChild(activityVBox);
			panel.Pressed += ()=>LoadActivity(activity["externalID"].ToString());
			variables.activityId = activity["externalID"].ToString();
			activitiesContainer.AddChild(panel);
		}
	}

	public void _on_btn_back_pressed(){
		GetTree().ChangeSceneToFile("res://scenes/CategorySelect.tscn");
	}

	public void LoadActivity(string externalID){
		variables.activityId = externalID;
		GetTree().ChangeSceneToFile("res://scenes/Activity.tscn");
	}
}
