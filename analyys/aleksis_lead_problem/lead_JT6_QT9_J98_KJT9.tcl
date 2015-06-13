source lib/utility.tcl
source lib/ddscore.tcl
source lib/counters.tcl
source lib/parscore.tcl
source format/none


set cellWidth 5
set numberPrecision 3
set firstCellWidth 5


set leads [ list "JS" "6S" "QH" "TH" "JD" "9D" "KC" "JC" ]
set rowLabels [ concat [list . ] $leads]
set colLabels [ list . 8 9 10 11 "x" sum sdev avg]
init s "Lead" $rowLabels $colLabels
init dealCount "Accepted deals"
init allDeals "All deals"

proc analyze { } {
        global leads
       
        foreach lead $leads { 
            set t [dds -leader west -trick $lead south hearts]
            while {$t == 0} {
                puts stderr "[south] [north] [west] [east] $t"
                set t [dds -leader west -trick $lead south hearts]
            }
            increment s $lead $t
            if {$t < 10} { increment s $lead "x" }
        } 
}

west is "JT6 QT9 J98 KJT9"

main {
	global dealCnt
        increment allDeals
        
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
        puts -nonewline stderr "\r$dealCnt: [south]" 

        increment dealCount
	analyze
	accept
}

deal_finished {
	puts stderr ""
	outputdb
}


