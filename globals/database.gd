extends Node

var database: SQLite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	database = SQLite.new()
	database.path="res://globals/data.db"
	database.open_db()
	
func query(sql:String)->Array[Dictionary]:
	if database.query(sql):
		return database.query_result
	return []

func query_with_bindings(sql:String,params:Array)->Array[Dictionary]:
	if database.query_with_bindings(sql, params):
		return database.query_result
	return []

func close() -> void:
	if database:
		database.close_db()
