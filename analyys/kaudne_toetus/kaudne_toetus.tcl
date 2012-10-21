source lib/utility.tcl
source lib/ddscore.tcl

south is "JT8765 3 AQ963 5"
set HCnt [list [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0] [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0]]
set suppCnt [list [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0] [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0]]
set dealCnt 0
set trickCnt [list 0 0]
set totSupp [list 0 0]
set mainCnt [list 0 0]
set cnt 0

proc my_write_deal { p1 p2 } {
	set line [list]
	set scores [list]
	foreach hand {north} {
		lappend line [join [$hand] "."]
	}
	global HCnt trickCnt suppCnt totSupp mainCnt
	set c [deal::tricks south spades]
	lappend scores $c
	set prob [list $p1 $p2]

	for {set i 0} {$i < 2} {incr i} {	
		set p [lindex $prob $i]
		set _HCnt [lindex $HCnt $i]
		set _trickCnt [lindex $trickCnt $i]
		set _suppCnt [lindex $suppCnt $i]
		set _totSupp [lindex $totSupp $i]
		lset _HCnt $c [expr [lindex $_HCnt $c] + $p]
		set _trickCnt [expr $_trickCnt + $c * $p]
		lset _suppCnt [spades north] [expr [lindex $_suppCnt [spades north]] + $p]
		set _totSupp [expr $_totSupp + $p * [spades north]]
		lset HCnt $i $_HCnt
		lset trickCnt $i $_trickCnt
		lset suppCnt $i $_suppCnt
		lset totSupp $i $_totSupp 
		lset mainCnt $i [expr [lindex $mainCnt $i] + $p]
	}

	#puts "[join $line |]|[join $scores |]"
}


defvector top3 1 1 1
defvector points 4 3 2 1
main {
	global dealCnt mainCnt
	incr dealCnt
	if {[hcp west] < 11} {reject}
	if {[hcp east] < 10} {reject}
	if {[hearts west] < 5} {reject}
	if {[hearts west] <= [spades west]} {reject}
	if {[clubs east] <= [spades east] && [diamonds east] <= [spades east]} {reject}
	if {[clubs east] < 4 && [diamonds east] < 4} {reject}
	set c 0
	if {[clubs east] > [diamonds east]} { incr c }
	if {[clubs east] >= [diamonds east]} { incr c}

	my_write_deal [expr {$c / 2.0}] [expr {1 - ($c / 2.0)}]
	incr cnt
	if { ($cnt % 100) == 0 } { puts stderr "$cnt" }
	accept
}

deal_finished {
	global dealCnt trickCnt mainCnt suppCnt HCnt totSupp
	for {set i 0} {$i < 2} {incr i} {	
		puts "[lindex $mainCnt $i] deals"
		puts "[join [lindex $HCnt $i] ,]"
		#puts "Tricks: [lindex $trickCnt $i]"
		set avg [expr 1.0 * [lindex $trickCnt $i] / [lindex $mainCnt $i]]
		puts "  avg tricks: $avg"
		puts "[join [lindex $suppCnt $i] ,]"
		set avgsupp [expr 1.0 * [lindex $totSupp $i] / [lindex $mainCnt $i]]
		puts "  avg supp: $avgsupp"
		puts ""
	}
	puts "Generated $dealCnt deals"
}
