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

set rowLabels [ list . "SJ" "HQ" "HT" "DJ" "D9" "CK" "CJ" ]
set colLabels [ list . "NO" 1 2 3 4 5 6 7 8 9 10 11 12 13 avg ]


# Initialize table with all the labels
proc initdb {} {
	global vulnList permIndexes rowLabels colLabels
	init s "Lead" $rowLabels $colLabels
}

proc analyze { } {
	global tricks suitPermutations vulnList permIndexes
        
        increment s "SJ" [dds -leader west -trick JS south hearts]
        increment s "HQ" [dds -leader west -trick QH south hearts]
        increment s "HT" [dds -leader west -trick TH south hearts]
        increment s "DJ" [dds -leader west -trick JD south hearts]
        increment s "D9" [dds -leader west -trick 9D south hearts]
        increment s "CK" [dds -leader west -trick KC south hearts]
        increment s "CJ" [dds -leader west -trick JC south hearts]
}

west is "JT6 QT9 J98 KJT9"

main {
	global dealCnt
        
        if {[hcp south] < 22} {reject}
        if {[hcp south] > 24} {reject}
        if {[hcp north] < 2} {reject}
        if {[hearts south] != 4} {reject}
        if {[hearts north] != 4} {reject}
        if {[spades north] >= 4} {reject}
        if {[diamonds south] < 2} {reject}
        if {[clubs south] < 2} {reject}
        if {[spades south] < 2} {reject}
	
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


