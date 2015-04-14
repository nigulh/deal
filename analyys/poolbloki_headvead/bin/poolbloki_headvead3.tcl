source lib/utility.tcl
source lib/ddscore.tcl
source lib/counters.tcl
source lib/parscore.tcl
source format/count


#south is "82 9754 K986532 -"

set cellWidth 6
set numberPrecision 3

proc normalizeCount { count totalCnt } {
	global dealCnt
	if {[string is integer -strict $count]} {
		return [expr 100.0 * $count / $dealCnt]
	}
	return $count
}


puts "Proovime analŸŸsida, kui efektiivne on meie Mast"
puts "Sisesta nŠidisjagu, mille esimene mast on analŸŸsitav Mast"
puts "Programm genereerib mastide permutatsioonid ja 4 erineva tsoonusega, et kui palju tuleks oma Masti pakkuda"
puts "-6..7 -- k›rgeim v›imalik Masti-leping, millega saab vŠhemalt par-tulemuse"
puts "NO -- par-tulemust selle masti lepinguga Ÿletada pole v›imalik"
puts "avg -- keskmine k›rgeim v›imalik leping"
puts "Par+ -- Par on Masti-lepingus, seejuures positiivne (hea leping, vastasel t›ket pole)"
puts "Par- -- Par on Masti-lepingus, seejuures negatiivne (hea t›ke)"
puts "noPar -- Selles Mastis Pari pole"
puts "1** -- NS mŠngivad Par lepingus"
puts "*1* -- Par leping tuleb vŠlja"
puts "**1 -- Mast tuleks pildile saada"
puts "000 -- Vastane v›idab lepingu"
puts "001 -- Vastane v›idab lepingu, -1 Mastist on hea t›ke"
puts "010 -- Vastane t›kestab, aga mitte meie Masti-lepingut"
puts "011 -- Vastane t›kestab meie Masti-lepingut"
puts "100 -- V›idame lepingu teises mastis"
puts "101 -- V›idame lepingu selles mastis (Par+)"
puts "110 -- T›kestame vastast, aga teises mastis"
puts "111 -- T›kestame vastast oma Mastiga (Par-)"

puts "Number nŠitab k›rgeimat v›imalikku lepingut, millega saab veel vŠhemalt par-tulemuse"


set suitPermutations [ list [list clubs diamonds hearts spades] [list diamonds clubs hearts spades] [list clubs hearts diamonds spades]	[list diamonds hearts clubs spades] [list hearts clubs diamonds spades] [list hearts diamonds clubs spades] [list clubs diamonds spades hearts] [list diamonds clubs spades hearts] [list clubs hearts spades diamonds] [list diamonds hearts spades clubs] [list hearts clubs spades diamonds] [list hearts diamonds spades clubs] [list clubs spades diamonds hearts] [list diamonds spades clubs hearts] [list clubs spades hearts diamonds] [list diamonds spades hearts clubs] [list hearts spades clubs diamonds] [list hearts spades diamonds clubs] [list spades clubs diamonds hearts] [list spades diamonds clubs hearts] [list spades clubs hearts diamonds] [list spades diamonds hearts clubs] [list spades hearts clubs diamonds] [list spades hearts diamonds clubs] ]
set vulnList [ list "EW" "-" "All" "NS"]
set permList [ list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 ]
#set permList [list 9] # DHSC
set rowLabels [ list . ]
set colLabels [ list . -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 avg "NO" "Par+" "Par-" "noPar" "_000" "_001" "_010" "_011" "_100" "_101" "_110" "_111" "_1**" "_*1*" "_**1" ]

# Initialize table with all the labels
proc initdb {} {
	global vulnList permList rowLabels colLabels
	foreach perm $permList {
		foreach vuln $vulnList {
			lappend rowLabels [ getRowLabel $perm $vuln ]
		}
	}
	#lappend rowLabels [ getSummaryRowLabel ]
	#lappend rowLabels sum
	init s "Optimaalne pikima masti korrus\n" $rowLabels $colLabels
}

proc analyze { } {
	global tricks suitPermutations vulnList permList
	
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
			set rowLabel [getRowLabel $perm $vulString]
			set summaryRowLabel [ getSummaryRowLabel ]

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
					if { $par > 0 } { set parSign "Par+" } else { set parSign "Par-"}
				}
			}
			
			set nsPreSpadesCombo "_[lindex $parArray 4][lindex $parArray 5][lindex $parArray 6]"
			foreach Label [list $rowLabel $summaryRowLabel] {
				increment s $Label $optimalLevel
				increment s $Label $parSign
				increment s $Label $nsPreSpadesCombo
				if {[lindex $parArray 4]} { increment s $Label "_1**"}
				if {[lindex $parArray 5]} { increment s $Label "_*1*"}
				if {[lindex $parArray 6]} { increment s $Label "_**1"}
			}
			#puts "$perm $parArray"
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
		set denom [ lindex [lindex $suitPermutations $suitPermutationIndex] $denomIndex]
		set scoreDenom [ lindex [lindex $suitPermutations 0 ] $denomIndex]
	    }
	    # denom -- the suit for getting the number of tricks
	    # scoreDenom -- the suit for getting score
            set passcount 4
	    foreach declarer $hands {
                if {$denom == "notrump"} {
                  set fit 14
                } else {
                  set fit [expr {[$denom $declarer]+[$denom [partner $declarer]]}]
		  if { $denom == "spades" } { set fit 15 }
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
	if {[lindex [lindex $suitPermutations $suitPermutationIndex] $denomIndex] == {spades}} {
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

proc getRowLabel { suitPermutationIndex vuln } {
	global suitPermutations
	set southHand ""
	foreach denomIndex [ list 3 2 1 0 ] {
		set denom [ lindex [lindex $suitPermutations $suitPermutationIndex] $denomIndex]
		set combo [ south $denom ]
		if { $denom == {spades} } { set combo "($combo)" }
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

proc getSummaryRowLabel {} {
	return [expr 1.0/96]
	set southHand ""
	append southHand "([ south spades ])"
	append southHand "-[south hearts]"
	append southHand "-[south diamonds]"
	append southHand "-[south clubs]"
	return $southHand
}

proc getRowIndex { suitPermutationIndex vuln } {
	global vulnList
	foreach i [list 0 1 2 3] {
		if { $vuln == [lindex $vulnList $i]} { set vulIndex $i }
	}
	return [expr {4 * $suitPermutationIndex + $vulIndex}]
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
}


