source lib/counters.tcl
source format/none
source lib/ddscore.tcl


set rowLabels [ list . 10 11 12 13 14 15 16 ]
set colLabels [ list . 4 5 6 7 8 9 10 11 12 13 sum avg]
set suitLength [ list . 0 1 2 3 4 5 6 7]
set isgame [ list . 0 1 "n9" "m10" "c11" avg]
init major_game "majorgame" $rowLabels $suitLength
init major_counts "major_counts" $rowLabels $suitLength
init club_game "clubgame" $rowLabels $suitLength
init club_counts "club_counts" $rowLabels $suitLength
init nsPoints "nsPoints" $rowLabels $rowLabels
init nttr "notrump tr" $rowLabels $colLabels
init game "game" $rowLabels $isgame
init northPoints "precPoints" $rowLabels
init southPoints "responderPoints" $rowLabels
init dealCount "Accepted deals"
init allDeals "Plus rejected deals"

proc analyze { } {
        set ctr [deal::tricks north clubs]
        set dtr [deal::tricks north diamonds]
        set htr [deal::tricks north hearts]
        set str [deal::tricks north spades]
        set ntr [deal::tricks north notrump]
        increment nttr [hcp south] $ntr
        if {$ntr >= 9} {
            increment game [hcp south] "n9"
        }
        if {$htr >= 10} {
            increment major_game [hcp south] [hearts south]
            increment game [hcp south] "m10"
        }
        increment major_counts [hcp south] [hearts south]
        if {$str >= 10} {
            increment major_game [hcp south] [spades south]
            if {$htr < 10} { increment game [hcp south] "m10" }
        }
        increment major_counts [hcp south] [spades south]
        if {$ctr >= 11} {
            increment club_game [hcp south] [clubs south]
            increment game [hcp south] "c11"
        }
        increment club_counts [hcp south] [clubs south]
        set isgame 0
        if {$htr >= 10 || $str >= 10 || $ctr >= 11 || $ntr >= 9} { 
            set isgame 1 
        }
        increment game [hcp south] $isgame
        increment northPoints [hcp north]
        increment southPoints [hcp south]
        increment nsPoints [hcp south] [hcp north]
}       

shapecond precisionadv {($c>=5)&&($s>=4||$h>=4||$c>=6)&&($s<=1||$h<=1||$d<=1||$c>=7)}
shapecond precision {($c>=5)&&($s==4||$h==4||$c>=6)}

proc open2c {hand min max} {
        if {[precision $hand]} {
                set hcp [hcp $hand]
                return [expr {$hcp>=$min && $hcp<=$max}]
        }
        return 0
}


main {
	global dealCnt
        increment allDeals
       
        if {[open2c north 10 15] == 0} { reject }
        if {[hcp south] < 10} {reject}
        if {[hcp south] > 16} {reject}
	
	incr dealCnt
        puts -nonewline stderr "\r$dealCnt: [south]" 

        increment dealCount
	analyze
	accept
}

deal_finished {
	puts stderr ""
	outputdb
}


