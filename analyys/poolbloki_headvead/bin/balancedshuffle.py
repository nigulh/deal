import random
import itertools
import sys

def popcount(n):
    return bin(n).count("1")

def translateFragment(n):
    return "".join(["AKQJT98765432"[i] for i in range(13) if n & (1 << i) != 0])

def generateFragments(length, count, cards=13):
    allCardsMask = 2**cards - 1
    availableCardsMask = 0
    for i in range(count):
        cardsMask = 0
        if (popcount(availableCardsMask) <= length):
            cardsMask = availableCardsMask
            availableCardsMask = allCardsMask
        while (popcount(cardsMask) < length):
            cardCandidates = availableCardsMask & ~cardsMask
            condition = True
            nextCard = 0
            while condition:
                nextCard = 2 ** random.randint(0, cards - 1)
                condition = (cardCandidates & nextCard) == 0
            availableCardsMask &= ~nextCard
            cardsMask |= nextCard
        fragment = translateFragment(cardsMask)
        sys.stderr.write(fragment + "\n")
        yield fragment

            


def generateHands(params):
    hand = [''] * 4
    fragments = [generateFragments(params[suit], params["count"], params["cards"]) for suit in ["spades", "hearts", "diamonds", "clubs"]]
    return ["-".join(hand) for hand in itertools.product(*fragments)]


if __name__ == "__main__":
    myParams = {"spades":6, "hearts":4, "diamonds":2, "clubs":1, "count":13, "cards":13}
    print "\n".join(generateHands(myParams))
                