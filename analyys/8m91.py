import commands

tot = 0
grand = 0

def main():
    combos = ["Q", "T98765", "J", "76543", "Q", "9876543", "JT987", ""]
    binom = [[0] * 10 for _ in range(10)]
    for i in range(10):
        binom[i][0] = 1
        for j in range(1, i+1):
            binom[i][j] = binom[i-1][j-1] + binom[i-1][j]
        
    east_hand = [0] * len(combos)
    def dive(cards_in, cards_out, combo):
        if cards_in > 13 or cards_out > 13:
            return
        if combo == len(combos):
            return analyze()
        maxlen = len(combos[combo])
        for pick_east in range(maxlen+1):
            east_hand[combo] = pick_east
            dive(cards_in + pick_east, cards_out + maxlen - pick_east, combo + 1)

    def analyze():
        global tot
        global grand
        cur_binomial = 1
        for i in range(len(combos)):
            cur_binomial *= binom[len(combos[i])][east_hand[i]]
        tot += cur_binomial
        east_string = " ".join(["{" + combos[2*i][:east_hand[2*i]] + combos[2*i+1][:east_hand[2*i+1]] + "}" for i in range(4)])
        cmd = './deal -i analyys/dd.tcl -i format/none -S "AJ2 K2 AKJT KQ32" -N "K43 AQT98 2 A654" -E "' + east_string + '" 1'
        if commands.getstatusoutput(cmd)[1] == '13':
            grand += cur_binomial
        else:
            print east_string
        print grand, "/", tot


    dive(0, 0, 0)
    print 1.0 * grand / tot

main()
