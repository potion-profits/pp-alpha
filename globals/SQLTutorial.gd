extends Node

var database: SQLite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	database = SQLite.new()
	database.path="res://globals/data.db"
	database.open_db()
	database.query("select * from inventory;")
	var res :Array = database.query_result
	print("got from db: ", res)
	database.close_db()
	
