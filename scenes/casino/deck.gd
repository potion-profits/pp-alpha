extends Sprite2D

## Handles card management in a simulated deck
##
## Can shuffle, draw from the deck, and replenish the deck. 

const suits : Array = ["D","H","C","S"]
const values : Array = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

var deck : Array = []	## Holds string representations of the cards currently in the deck

func _ready() -> void:
	refill()
	shuffle()

## Creates a brand new deck with every combination of suit and value, 
## one for every card in a real deck. The deck is unshuffled after this function.
func refill() -> void:
	# TODO : if card in play, don't shuffle it back in
	deck.clear()
	for s : String in suits:
		for v : String in values:
			deck.append(v+"_"+s)

## Shuffles the positions of each card in the deck
func shuffle() -> void:
	deck.shuffle()

## Consumes and returns a string representation of the card at the back of the deck.
func draw() -> String:
	if deck.is_empty():
		refill()
		shuffle()
	return deck.pop_back()
