import random

class CasinoPrize:
    def __init__(self, name, prize_type, price=0, entity=None):
        self.name = name
        self.prize_type = prize_type  # 'random' or 'direct'
        self.price = price
        self.entity = entity  # Could be a placeable entity or None

class Casino:
    def __init__(self):
        self.tokens = 0
        self.prizes = []

    def add_tokens(self, amount):
        self.tokens += amount

    def add_prize(self, prize):
        self.prizes.append(prize)

    def spin_wheel(self):
        """Randomized prize selection."""
        if self.tokens <= 0:
            return "Not enough tokens"
        self.tokens -= 1
        prize = random.choice(self.prizes)
        return prize

    def purchase_prize(self, prize_name):
        """Direct purchase of a prize."""
        prize = next((p for p in self.prizes if p.name == prize_name), None)
        if not prize:
            return "Prize not found"
        if self.tokens < prize.price:
            return "Not enough tokens"
        self.tokens -= prize.price
        return prize

class Player:
    def __init__(self, name):
        self.name = name
        self.casino = Casino()

    def earn_tokens(self, amount):
        self.casino.add_tokens(amount)

    def spin_for_prize(self):
        prize = self.casino.spin_wheel()
        if isinstance(prize, CasinoPrize):
            if prize.entity:
                return f"Congratulations! You won {prize.name}. Place it now!"
            else:
                return f"Congratulations! You won {prize.name}. Enjoy your prize!"
        return prize

    def buy_prize(self, prize_name):
        prize = self.casino.purchase_prize(prize_name)
        if isinstance(prize, CasinoPrize):
            return f"Congratulations! You bought {prize.name}."
        return prize

# Test cases

def test_casino():
    # Create prizes
    prize1 = CasinoPrize(name="Golden Statue", prize_type="random", price=10, entity="statue")
    prize2 = CasinoPrize(name="Mysterious Box", prize_type="direct", price=20)
    prize3 = CasinoPrize(name="Free Spin", prize_type="random")

    # Create player and add tokens
    player = Player("Jonathan")
    player.earn_tokens(100)

    # Add prizes to the casino
    player.casino.add_prize(prize1)
    player.casino.add_prize(prize2)
    player.casino.add_prize(prize3)

    # Test spin for random prize
    result = player.spin_for_prize()
    print(result)  # Expected output: prize name, possibly with "Place it now!" if entity

    # Test buy prize
    result = player.buy_prize("Mysterious Box")
    print(result)  # Expected output: congratulations message

# Run the test
test_casino()