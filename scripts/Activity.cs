using Godot;
using System;
using System.Text;

public partial class Activity : Node2D{
	private bool isResponseProcessed = false;
	private bool isImageLoaded = false;
	private Godot.Collections.Dictionary activity;
	private double time;
	public Label timer;
	public Variables variables;

	public Godot.Collections.Array textures_image;
	private int totalImages = 0;
    private int loadedImages = 0;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready(){
		variables = GetNode<Variables>("/root/Variables");
		initializeActivity();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta){
		time += delta;
		timer.Text = Math.Round(time,0).ToString();
	}

	public void _on_http_request_request_completed(long result, long responseCode, string[] headers, byte[] body){
		if (isResponseProcessed){
            return;
        }
		isResponseProcessed = true;
		Godot.Collections.Dictionary json = Json.ParseString(Encoding.UTF8.GetString(body)).AsGodotDictionary();
        activity = json;
		getImage();
	}

	public void getActivity(){
		HttpRequest httpRequest = GetNode<HttpRequest>("HTTPRequest");
		httpRequest.RequestCompleted += _on_http_request_request_completed;
		httpRequest.Request(variables.URL_Back+"activity/get/"+variables.activityId,new string[]{"Cookie:token="+variables.cookie});
	}

	private void initializeActivity(){
		variables.score = 0;
		time = 0.0;
		timer = GetNode<Label>("Timer");
		variables = GetNode<Variables>("/root/Variables");
		textures_image=new();
		getActivity();
	}
	public void LoadResources(){
		int aux = 0;
		HBoxContainer hBoxContainer = GetNode<ScrollContainer>("ScrollContainer").GetNode<HBoxContainer>("HBoxContainer");
		foreach (Godot.Collections.Dictionary media_resource in Json.ParseString(activity["media_resources"].ToString()).AsGodotArray()){
			/*float positionX = float.Parse(media_resource["positionX"].ToString());
			positionX = Math.Abs((positionX*1095)/650);
			float positionY = float.Parse(media_resource["positionY"].ToString());
			positionY = Math.Abs((positionY*617)/238);*/
			Label score = new();
			LineEdit lineEdit = new();
			VBoxContainer resource_Cont = new();
			resource_Cont.Name = "vbox"+media_resource["id"].ToString();
			resource_Cont.CustomMinimumSize = new Vector2(250,250);
			score.Name = "value"+media_resource["id"].ToString();
			score.Text = "Valor "+media_resource["value"].ToString();
			lineEdit.Name = media_resource["id"].ToString();
			//resource_Cont.SetPosition(new Vector2(positionX,positionY));
			TextureRect textureRect = new();
			textureRect.CustomMinimumSize = new Vector2(250,250);
			textureRect.ExpandMode = TextureRect.ExpandModeEnum.IgnoreSize;
			hBoxContainer.AddChild(resource_Cont);
			resource_Cont.AddChild(textureRect);
			textureRect.Texture = (ImageTexture)textures_image[aux];
			resource_Cont.AddChild(score);
			resource_Cont.AddChild(lineEdit);
			hBoxContainer.AddChild(resource_Cont);
			aux++;
		} 

	}

	public void getImage(){
		foreach (Godot.Collections.Dictionary media_resource in Json.ParseString(activity["media_resources"].ToString()).AsGodotArray()){
			totalImages++;
			HttpRequest httpImage;
			httpImage = new();
			httpImage.RequestCompleted += imageObtained;
			AddChild(httpImage);
			httpImage.Request(media_resource["url"].ToString());
		}
	}

	private void imageObtained(long result, long responseCode, string[] headers, byte[] body){
		Image image = new();
		Error error = image.LoadJpgFromBuffer(body);
		if (error != Error.Ok)
		{
			GD.PushError("Couldn't load the image.");
		}
		ImageTexture texture = ImageTexture.CreateFromImage(image);
		textures_image.Add(texture);
		loadedImages++;
		if (loadedImages == totalImages) {
            // All images are loaded, now we can call LoadResources
            LoadResources();
        }
	}

	public void _on_button_pressed(){
		variables.time = time;
		foreach (Godot.Collections.Dictionary media_resource in Json.ParseString(activity["media_resources"].ToString()).AsGodotArray()){
			LineEdit input = GetNode<ScrollContainer>("ScrollContainer").GetNode<HBoxContainer>("HBoxContainer").GetNode<VBoxContainer>("vbox"+media_resource["id"].ToString()).GetNode<LineEdit>(media_resource["id"].ToString());
			if(input.Text== media_resource["name"].ToString()){
				variables.score += media_resource["value"].ToString().ToInt();
			}
		}
		GetTree().ChangeSceneToFile("res://scenes/GameOver.tscn");
	}
}
