using Godot;
using System;
using System.Text;

public partial class CategorySelect : Control{
	private Godot.Collections.Array categories;
	private Variables variables;
	private bool isResponseProcessed = false;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready(){
		variables = GetNode<Variables>("/root/Variables");
		getCategories();
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
		categories = json;
		renderCategories();
	}

	private void getCategories(){
		HttpRequest httpRequest = GetNode<HttpRequest>("HTTPRequest");
		httpRequest.RequestCompleted += _on_http_request_request_completed;
		httpRequest.Request(variables.URL_Back+"category/list");
	}

	private void renderCategories(){
		HBoxContainer categoriesContainer = GetNode<ScrollContainer>("ScrollContainer").GetNode<HBoxContainer>("Categories");
		foreach (Godot.Collections.Dictionary category in categories){
			Button panel = new();
			VBoxContainer categoryVBox = new();
			panel.Name  = category["externalID"].ToString();
			Label nameCategory = new();
			Label descCategory = new();
			panel.CustomMinimumSize = new Vector2(200,100);
			nameCategory.Text = category["name"].ToString();
			descCategory.Text = category["description"].ToString();
			categoryVBox.AddChild(nameCategory);
			categoryVBox.AddChild(descCategory);
			panel.Pressed += () => ToSceneActivities(category["externalID"].ToString());
			panel.AddChild(categoryVBox);
			categoriesContainer.AddChild(panel);
		}
	}

	public void _on_btn_back_pressed(){
		GetTree().ChangeSceneToFile("res://scenes/Menu.tscn");
	}

	public void ToSceneActivities(string categoryId){
		variables.categoryId = categoryId;
		GetTree().ChangeSceneToFile("res://scenes/ActivitySelect.tscn");
	}
}
