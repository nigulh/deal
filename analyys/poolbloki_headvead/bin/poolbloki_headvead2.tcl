source lib/utility.tcl
source lib/ddscore.tcl
source lib/counters.tcl
source lib/parscore.tcl
source format/count


#south is "82 9754 K986532 -"

set cellWidth 6
set numberPrecision 3

proc normalizeCount { count } {
	global dealCnt
	if {[string is integer -strict $count]} {
		return [expr 100.0 * $count / $dealCnt]
	}
	return $count
}


puts "Proovime analüüsida, kui efektiivne on tõkestamine"
puts "Sisesta näidisjagu, mille esimene mast on tõkestamise mast"
puts "Programm genereerib mastide permutatsioonid ja 4 erineva tsoonusega, et kui palju tuleks oma masti pakkuda"
puts "NO tähendab, et me ei peaks kindlasti seda masti mängima -- skoorib rohkem"
puts "Number näitab kõrgeimat võimalikku lepingut, millega saab veel vähemalt par-tulemuse"

set suitPermutations [ list [list clubs diamonds hearts spades] [list diamonds clubs hearts spades] [list clubs hearts diamonds spades]	[list diamonds hearts clubs spades] [list hearts clubs diamonds spades] [list hearts diamonds clubs spades] [list clubs diamonds spades hearts] [list diamonds clubs spades hearts] [list clubs hearts spades diamonds] [list diamonds hearts spades clubs] [list hearts clubs spades diamonds] [list hearts diamonds spades clubs] [list clubs spades diamonds hearts] [list diamonds spades clubs hearts] [list clubs spades hearts diamonds] [list diamonds spades hearts clubs] [list hearts spades clubs diamonds] [list hearts spades diamonds clubs] [list spades clubs diamonds hearts] [list spades diamonds clubs hearts] [list spades clubs hearts diamonds] [list spades diamonds hearts clubs] [list spades hearts clubs diamonds] [list spades hearts diamonds clubs] ]
set vulnList [ list "EW" "-" "All" "NS"]
set permList [ list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 ]
set permList [ list 0 23 ]
set rowLabels [ list . ]

proc initdb {} {
	global vulnList
	global permList
	global rowLabels
	foreach perm $permList {
		foreach vuln $vulnList {
			lappend rowLabels [ getRowLabel $perm $vuln ]
		}
	}
	init s "Optimaalne pikima masti korrus" $rowLabels [ list . 1 2 3 4 5 6 7 avg "NO" "Par+" "Par-" "noPar" ]
}

proc analyze { } {
	global tricks
	global suitPermutations
	global vulnList
	global permList
	
	puts "Partner: [north]"
	foreach vulString $vulnList {
		#calculate tricks array
		set par [lindex [parscore south $vulString] 2]
		foreach perm $permList {
			set parArray [parscore_permuteSuits south $vulString $perm]
			set par [lindex $parArray 2]
			foreach index [ list 0 1 2 3 ] { # search for the best suit index
				if { [ lindex [lindex $suitPermutations $perm ] $index ] == {spades} } { set spadeIndex $index }
			}
			set scoreDenom [ lindex [lindex $suitPermutations 0 ] $spadeIndex ]

			set optimalLevel "NO"
			foreach level [list 1 2 3 4 5 6 7] {
				if {$tricks(south:spades)<6+$level} { 
				    set contract [list $level $scoreDenom doubled]
				} else { 
				    set contract [list $level $scoreDenom]
				}
				if {$vulString == "-" || $vulString == "EW"} { set vuln nonvul } else { set vuln vul}
				set scoresouthspades [score $contract $vuln $tricks(south:spades)]
				if { $scoresouthspades >= $par} { set optimalLevel $level }
			}
			increment s [getRowLabel $perm $vulString] $optimalLevel

			set isPar false
			set parSign "noPar"
			if { [ lindex [lindex $parArray 0] 1 ] == $scoreDenom } {
				if { [lindex $parArray 1] == {north} || [lindex $parArray 1] == {south} } {
					if { $par > 0 } { set parSign "Par+" } else { set parSign "Par-"}
				}
			}
			increment s [getRowLabel $perm $vulString] $parSign
			#puts $parArray
			#puts "$parSign $optimalLevel"
		}
	}
}


proc parscore_permuteSuits {dealer whovul suitPermutationIndex} {
    if {"$whovul"=="EW"} {
	set vul(EW) vul
        set vul(NS) nonvul
    } elseif {"$whovul"=="NS"} {
        set vul(EW) nonvul
	set vul(NS) vul
    } elseif {"$whovul"=="All"} {
	set vul(EW) vul
	set vul(NS) vul
    } else {
	set vul(EW) nonvul
	set vul(NS) nonvul
    }

    global parscore
    global tricks
    global suitPermutations

    set hands $parscore(order:$dealer)

    set bestcontract {Pass}
    set bestdeclarer {}
    set bestscore 0
    set besttricks ""
    set biggestfit 0
    
    set curSpadesLevel 0
    set curSpadesScore 0
    set prevSpadesLevel 0
    set prevSpadesScore 0

    for {set level 1} {$level<=7} {incr level} {
	set anymake 0
	foreach denomIndex [ list 0 1 2 3 4 ] {
	#foreach denom {clubs diamonds hearts spades notrump}
	    if {$denomIndex == 4} {
		set denom "notrump"
		set scoreDenom "notrump"
	    } else {
		set denom [ lindex [lindex $suitPermutations $suitPermutationIndex] $denomIndex]
		set scoreDenom [ lindex [lindex $suitPermutations 0 ] $denomIndex]
	    }
            set passcount 4
	    foreach declarer $hands {
                if {$denom == "notrump"} {
                  set fit 14
                } else {
                  set fit [expr {[$denom $declarer]+[$denom [partner $declarer]]}]
		  if { $denom == "spades" } { set fit 15 }
                }
		incr passcount -1
		set pair $parscore(pair:$declarer)
		if {$tricks($declarer:$denom)<6+$level} { 
		    set makes 0
		    set contract [list $level $scoreDenom doubled]
		} else { 
		    set makes 1
		    set anymake 1
		    set contract [list $level $scoreDenom]
		}
		
		set mult $parscore(mult:$declarer)
		set newscore [score $contract $vul($pair) $tricks($declarer:$denom)]
		#puts "Comparing [expr {$mult*$newscore}] in $contract by $declarer to $bestscore in $bestcontract by $bestdeclarer"
		if {$newscore>$mult*$bestscore || (($newscore==$mult*$bestscore) && $fit>$biggestfit) } {
                    set biggestfit $fit
		    set bestcontract $contract
		    set bestdeclarer $declarer
		    set bestscore [expr {$mult*$newscore}]
		    set besttricks $tricks($declarer:$denom)
		    set level [lindex $contract 0]
		    set suit [par_first_upper [lindex $contract 1]]
		    set prevSpadesLevel $curSpadesLevel
		    set prevSpadesScore $curSpadesScore
		}
		if { $declarer == {south} && $denom == {spades} } {
		    set curSpadesLevel $level
		    set curSpadesScore $newscore
		}
	    }
	}
    }
    
    if { pair:$bestdeclarer == NS } { set isNS true } else { set isNS false }
    if { lindex $bestcontract 2 == doubled } { set isPre true } else { set isPre false }
    set isSpadesGood false
    if { isNS } { set isSpadesGood [lindex $bestContract 1 == { spades }]}
    else if { $prevSpadesLevel > 0 && $prevSpadesScore >= $bestscore } { set isSpadesGood true }
    list $bestcontract $bestdeclarer $bestscore $besttricks $isNS $isPre $isSpadesGood
}

proc getRowLabel { suitPermutationIndex vuln } {
	global suitPermutations
	set southHand ""
	foreach denomIndex [ list 3 2 1 0 ] {
		set denom [ lindex [lindex $suitPermutations $suitPermutationIndex] $denomIndex]
		set combo [ south $denom ]
		#if { $combo == "" } { set combo "-"}
		append southHand $combo
		if { $denomIndex > 0 } { append southHand "-"} else { append southHand " "}
	}
	set vulStr $vuln
	if { $vuln == "-"} { set vulStr "--" }
	if { $vuln == "All"} { set vulStr "++" }
	append southHand $vulStr
	append southHand " $suitPermutationIndex"
	return $southHand
}



main {
	global dealCnt
	
	incr dealCnt
	if { $dealCnt == 1 } {
		initdb
		puts "[south]"
	}
	analyze
	if { $dealCnt % 100 == 0 } { puts "$dealCnt" }
	accept
}

deal_finished {
	global dealCnt
	
	outputdb
	puts "Generated $dealCnt deals"
	
	#puts $tab
}


