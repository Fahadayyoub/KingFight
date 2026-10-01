extends Node

@onready var label_5: Label = $Label5

var score = 0

func add_point():
	score +=1
	label_5.text = "You collected " +str(score)+ " coins."
	print(score)
