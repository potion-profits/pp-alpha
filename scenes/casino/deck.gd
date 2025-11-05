extends Sprite2D

const suits : Array = ["D","H","C","S"]
const values : Array = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

var deck : Array = []

func _ready() -> void:
	refill()
	shuffle()

func refill() -> void:
	# TODO : if card in play, don't shuffle it back in
	deck.clear()
	for s : String in suits:
		for v : String in values:
			deck.append(v+"_"+s)

func shuffle() -> void:
	deck.shuffle()

func draw() -> String:
	if deck.is_empty():
		refill()
		shuffle()
	return deck.pop_back()
