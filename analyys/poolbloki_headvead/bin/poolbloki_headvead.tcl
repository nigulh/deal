source lib/utility.tcl
source lib/ddscore.tcl
source lib/counters.tcl
source lib/parscore.tcl
source format/none


set cellWidth 1
set numberPrecision 3
set firstCellWidth 1

proc normalizeCount { count totalCnt } {
	global dealCnt
	if {[string is integer -strict $count]} {
		return [expr 100.0 * $count / $dealCnt]
	}
	return $count
}

proc debug { line } {
	puts stderr $line
}

debug "Proovime analŸŸsida, kui efektiivne on meie Mast"
debug "Sisesta nŠidisjagu, mille esimene mast on analŸŸsitav Mast"
debug "Programm genereerib mastide permutatsioonid ja 4 erineva tsoonusega, et kui palju tuleks oma Masti pakkuda"
debug "-6..7 -- k›rgeim v›imalik Masti-leping, millega saab vŠhemalt par-tulemuse"
debug "NO -- par-tulemust selle masti lepinguga Ÿletada pole v›imalik"
debug "avg -- keskmine k›rgeim v›imalik leping"
debug "ParPos -- Par on Masti-lepingus, seejuures positiivne (hea leping, vastasel t›ket pole)"
debug "ParNeg -- Par on Masti-lepingus, seejuures negatiivne (hea t›ke)"
debug "noPar -- Selles Mastis Pari pole"
debug "b1xx -- NS mŠngivad Par lepingus"
debug "bx1x -- Par leping tuleb vŠlja"
debug "bxx1 -- Mast tuleks pildile saada"
debug "b000 -- Vastane v›idab lepingu"
debug "b001 -- Vastane v›idab lepingu, -1 Mastist on hea t›ke"
debug "b010 -- Vastane t›kestab, aga mitte meie Masti-lepingut"
debug "b011 -- Vastane t›kestab meie Masti-lepingut"
debug "b100 -- V›idame lepingu teises mastis"
debug "b101 -- V›idame lepingu selles mastis (ParPos)"
debug "b110 -- T›kestame vastast, aga teises mastis"
debug "b111 -- T›kestame vastast oma Mastiga (ParNeg)"
debug "Number nŠitab k›rgeimat v›imalikku lepingut, millega saab veel vŠhemalt par-tulemuse"
debug ""


set suitPermutations [ list [list clubs diamonds hearts spades] [list diamonds clubs hearts spades] [list clubs hearts diamonds spades]	[list diamonds hearts clubs spades] [list hearts clubs diamonds spades] [list hearts diamonds clubs spades] [list clubs diamonds spades hearts] [list diamonds clubs spades hearts] [list clubs hearts spades diamonds] [list diamonds hearts spades clubs] [list hearts clubs spades diamonds] [list hearts diamonds spades clubs] [list clubs spades diamonds hearts] [list diamonds spades clubs hearts] [list clubs spades hearts diamonds] [list diamonds spades hearts clubs] [list hearts spades clubs diamonds] [list hearts spades diamonds clubs] [list spades clubs diamonds hearts] [list spades diamonds clubs hearts] [list spades clubs hearts diamonds] [list spades diamonds hearts clubs] [list spades hearts clubs diamonds] [list spades hearts diamonds clubs] ]
set vulnList [ list "EW" "-" "All" "NS"]
set permIndexes [ list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 ]
#set permIndexes [list 9] # DHSC
set rowLabels [ list . ]
set colLabels [ list . "NO" -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 avg "ParPos" "ParNeg" "noPar" "b000" "b001" "b010" "b011" "b100" "b101" "b110" "b111" "b1xx" "bx1x" "bxx1" ]

# Initialize table with all the labels
proc initdb {} {
	global vulnList permIndexes rowLabels colLabels
	foreach permIndex $permIndexes {
		foreach vuln $vulnList {
			lappend rowLabels [ getRowLabel $permIndex $vuln ]
		}
	}
	init s "S H D C Bid Vul Combo OtherCombo HandPattern" $rowLabels $colLabels
}

proc analyze { } {
	global tricks suitPermutations vulnList permIndexes
	
	debug "Partner: [north]  Opps: [west] | [east]"
	foreach vulString $vulnList {
		#calculate tricks array
		set par [lindex [parscore south $vulString] 2]
		foreach permIndex $permIndexes {
			set parArray [parscore_permuteSuits south $vulString $permIndex]
			set par [lindex $parArray 2]
			foreach index [ list 0 1 2 3 ] { # search for the best suit index
				if { [ lindex [lindex $suitPermutations $permIndex ] $index ] == {spades} } { set spadeIndex $index }
			}
			set scoreDenom [ lindex [lindex $suitPermutations 0 ] $spadeIndex ]
			set rowLabel [getRowLabel $permIndex $vulString]

			# Calculate highest possible level of our suit to beat par
			set optimalLevel "NO"
			foreach level [list -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7] {
				if {$tricks(south:spades) >= 6 + $level && $level < 1} { continue }
				if { $level < 1} { set extra [expr {1 - $level} ] } else { set extra 0 }
				if {$tricks(south:spades)<6+$level} { 
				    set contract [list [expr {$level+$extra}] $scoreDenom doubled]
				} else { 
				    set contract [list $level $scoreDenom]
				}
				if {$vulString == "-" || $vulString == "EW"} { set vuln nonvul } else { set vuln vul}
				set scoresouthspades [score $contract $vuln [expr {$tricks(south:spades) + $extra}]]
				if { $scoresouthspades >= $par} { set optimalLevel $level }
			}

			set isPar false
			set parSign "noPar"
			if { [ lindex [lindex $parArray 0] 1 ] == $scoreDenom } {
				if { [lindex $parArray 1] == {north} || [lindex $parArray 1] == {south} } {
					if { $par > 0 } { set parSign "ParPos" } else { set parSign "ParNeg"}
				}
			}
			
			set nsPreSpadesCombo "b[lindex $parArray 4][lindex $parArray 5][lindex $parArray 6]"
                        increment s $rowLabel $optimalLevel
                        increment s $rowLabel $parSign
                        increment s $rowLabel $nsPreSpadesCombo
                        if {[lindex $parArray 4]} { increment s $rowLabel "b1xx"}
                        if {[lindex $parArray 5]} { increment s $rowLabel "bx1x"}
                        if {[lindex $parArray 6]} { increment s $rowLabel "bxx1"}
		}
	}
}


proc parscore_permuteSuits {dealer whovul permIndex} {
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

    global parscore tricks suitPermutations

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
	foreach denomIndex [ list 0 1 2 3 4 ] {
	    if {$denomIndex == 4} {
		set denom "notrump"
		set scoreDenom "notrump"
	    } else {
		set denom [ lindex [lindex $suitPermutations $permIndex] $denomIndex]
		set scoreDenom [ lindex [lindex $suitPermutations 0 ] $denomIndex]
	    }
	    # denom -- the suit for getting the number of tricks
	    # scoreDenom -- the suit for getting score
            set passcount 4
	    foreach declarer $hands {
                if {$denom == "notrump"} {
                  set fit 14
                } elseif { $denom == "spades" } { 
                  set fit 15 
                } else {
                  set fit [expr {[$denom $declarer]+[$denom [partner $declarer]]}]
                }
		incr passcount -1
		set cpair $parscore(pair:$declarer)
		if {$tricks($declarer:$denom)<6+$level} { 
		    set contract [list $level $scoreDenom doubled]
		} else { 
		    set contract [list $level $scoreDenom]
		}
		
		set mult $parscore(mult:$declarer)
		set newscore [score $contract $vul($cpair) $tricks($declarer:$denom)]
		#puts "Comparing [expr {$mult*$newscore}] in $contract by $declarer to $bestscore in $bestcontract by $bestdeclarer"
		if {$newscore>$mult*$bestscore || (($newscore==$mult*$bestscore) && $fit>$biggestfit) } {
                    set biggestfit $fit
		    set bestcontract $contract
		    set bestdeclarer $declarer
		    set bestscore [expr {$mult*$newscore}]
		    set besttricks $tricks($declarer:$denom)
		    #set level [lindex $contract 0]
		    #set suit [par_first_upper [lindex $contract 1]]
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
    
    set spadeIndex 0
    foreach denomIndex [ list 0 1 2 3 ] {
	if {[lindex [lindex $suitPermutations $permIndex] $denomIndex] == {spades}} {
	    set spadeIndex $denomIndex
	}
    }
    set isNS [ expr { $parscore(pair:$bestdeclarer) == {NS} } ]
    set isPre [ expr { [lindex $bestcontract 2] == {doubled}}]
    set isSpadesGood 0
    if { $isNS } {
	set isSpadesGood [expr {[lindex $bestcontract 1] == [ lindex [lindex $suitPermutations 0] $spadeIndex] }]
    } else {
    	if {$prevSpadesLevel > 0 && $prevSpadesScore >= $bestscore } { set isSpadesGood 1 }
    }
    list $bestcontract $bestdeclarer $bestscore $besttricks $isNS $isPre $isSpadesGood $prevSpadesScore
}

proc getRowLabel { permIndex vuln } {
	global suitPermutations
	set southHand ""
	set scoreDenom -1
	foreach denomIndex [ list 3 2 1 0 ] {
		set denom [ lindex [lindex $suitPermutations $permIndex] $denomIndex]
		set combo [ south $denom ]
		if { $denom == {spades} } {
			set scoreDenom $denomIndex
			set combo "($combo)"
		}
		#if { $combo == "" } { set combo "-"}
		append southHand $combo
		if { $denomIndex > 0 } { append southHand " "} else { append southHand " "}
	}
	append southHand [ lindex [list C D H S] $scoreDenom]
	append southHand " "
	set vulStr $vuln
	if { $vuln == "-"} { set vulStr "--" }
	if { $vuln == "All"} { set vulStr "++" }
	append southHand $vulStr
        append southHand " [south spades] [south hearts]-[south diamonds]-[south clubs]"
        append southHand " [spades south]-[hearts south]-[diamonds south]-[clubs south]"
	return $southHand
}

main {
	global dealCnt
	
	incr dealCnt
	if { $dealCnt == 1 } {
		initdb
		puts stderr "[south]"
	}
	analyze
	if { $dealCnt % 10 == 0 } { puts stderr "$dealCnt" }
	accept
}

deal_finished {
	global dealCnt
	puts stderr ""
	outputdb
	puts stderr "Generated $dealCnt deals"
}


