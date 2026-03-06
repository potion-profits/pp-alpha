import random

class Prize:
    def __init__(self, name, is_placeable=False):
        self.name = name
        self.is_placeable = is_placeable

    def __repr__(self):
        return f"Prize(name={self.name}, is_placeable={self.is_placeable})"

class Casino:
    def __init__(self):
        self.prizes = [
            Prize("Golden Statue", is_placeable=True),
            Prize("Luxury Car"),
            Prize("Mystery Box"),
            Prize("1000 Tokens")
        ]
        self.tokens = 1000

    def spin_wheel(self):
        prize = random.choice(self.prizes)
        return prize

    def buy_prize(self, prize_name):
        prize = next((p for p in self.prizes if p.name == prize_name), None)
        if prize:
            if prize_name == "1000 Tokens":
                return "You can't purchase tokens."
            else:
                return prize
        else:
            return "Prize not found."

    def handle_placeable_entity(self, prize):
        if prize.is_placeable:
            return f"Place the {prize.name} immediately."
        else:
            return f"Your next purchase from the entity shop is free."

def casino_game():
    casino = Casino()
    print("Spinning the wheel...")
    prize = casino.spin_wheel()
    print(f"You won: {prize.name}")
    print(casino.handle_placeable_entity(prize))

    prize_to_buy = "Mystery Box"
    print(f"\nAttempting to buy: {prize_to_buy}")
    prize = casino.buy_prize(prize_to_buy)
    if isinstance(prize, Prize):
        print(f"You purchased: {prize.name}")
        print(casino.handle_placeable_entity(prize))
    else:
        print(prize)

if __name__ == "__main__":
    casino_game()