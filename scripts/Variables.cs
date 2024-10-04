using Godot;
using System;

public partial class Variables : Node{
	// Called when the node enters the scene tree for the first time.
	
	public string cookie;
	public string URL_Back;
	public string categoryId;
	public string activityId;
	public int score;
	public double time;
	public override void _Ready(){
		URL_Back = "http://localhost:3006/api/v1";
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
