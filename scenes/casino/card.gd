extends Node2D

const CARD_WIDTH = 100
const CARD_HEIGHT = 144
const SHEET_PATH = "res://assets/casino/temp/CuteCards.png"

const SUIT_ORDER = {"S" : 0, "D": 1, "C": 2, "H": 3}
const VALUE_ORDER = {
	"A": 0, "2": 1, "3": 2, "4": 3, "5": 4, "6": 5, "7": 6,
	"8": 7, "9": 8, "10": 9, "J": 10, "Q": 11, "K": 12
}

func set_card(card_name: String) -> void:
	var parts : Array = card_name.split("_")
	var value : String = parts[0]
	var suit : String = parts[1]
	
	var atlas_texture : AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = preload(SHEET_PATH)
	atlas_texture.region = Rect2(VALUE_ORDER[value] * CARD_WIDTH, 
		SUIT_ORDER[suit] * CARD_HEIGHT, 
		CARD_WIDTH, 
		CARD_HEIGHT)
	self.texture = atlas_texture
