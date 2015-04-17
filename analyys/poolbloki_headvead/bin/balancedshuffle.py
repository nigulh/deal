#!/usr/local/bin/python
import random
import itertools
import sys

def popcount(n):
    return bin(n).count("1")

def translateFragment(n):
    if n == 0:
        return "-"
    return "".join(["AKQJT98765432"[i] for i in range(13) if n & (1 << i) != 0])

def generateFragments(totalLength, suitCount, count, cards=13):
    allCardsMask = 2**cards - 1
    availableCardsMask = [0] * suitCount
    for i in range(count):
        cardsMask = [0] * suitCount;
        lengths = [0] * suitCount
        for j in range(totalLength):
            nextSuit = random.randint(0, cards * suitCount - 1 - j)
            suitIndex = 0
            while (cards - lengths[suitIndex] <= nextSuit):
                nextSuit -= cards - lengths[suitIndex]
                suitIndex += 1
            lengths[suitIndex] += 1
        lengths.sort(reverse=True)
        for suitIndex in range(suitCount):
            length = lengths[suitIndex]
            while (popcount(cardsMask[suitIndex]) < length):
                if (availableCardsMask[suitIndex] == 0):
                    availableCardsMask[suitIndex] = allCardsMask
                cardCandidates = availableCardsMask[suitIndex] & ~cardsMask[suitIndex]
                cardFound = False
                nextCard = 0
                while cardFound == False:
                    nextCard = 2 ** random.randint(0, cards - 1)
                    cardFound = (cardCandidates & nextCard) != 0
                availableCardsMask[suitIndex] &= ~nextCard
                cardsMask[suitIndex] |= nextCard
        fragment = " ".join(map(translateFragment, cardsMask));
        sys.stderr.write(fragment + "\n")
        yield fragment

            

def generateHands(lengths, counts):
    fragments = [generateFragments(sum(lengths[j]), len(lengths[j]), counts[j]) for j in range(len(lengths))];
    return [" ".join(hand) for hand in itertools.product(*fragments)]


if __name__ == "__main__":
    lengths = [[6], [7, 0, 0]]
    counts = [5, 3]
    for i in range(2):
        if len(sys.argv) > i + 1:
            counts[i] = int(sys.argv[i + 1])
    print "\n".join(generateHands(lengths, counts))
                
