source lib/utility.tcl
source lib/ddscore.tcl

set dealCnt 0
set mainCnt [list 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]

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

proc getIndex { a b } {
	set ret [expr 13 * $a + $b]
	return $ret
}


defvector top3 1 1 1
defvector points 4 3 2 1
main {
	global dealCnt mainCnt
	incr dealCnt
	if {[hearts east] < 7} {reject}
	if {[spades south] != 5} {reject}
	set a [hearts south]
	set b [spades east]

	set i [getIndex $a $b]

	lset mainCnt $i [ expr [lindex $mainCnt $i] + 1]	

	incr cnt
	if { ($cnt % 10000) == 0 } { puts stderr "$cnt" }
	accept
}

deal_finished {
	global dealCnt mainCnt

	puts "[join $mainCnt ,]"
	puts "Generated $dealCnt deals"
}
