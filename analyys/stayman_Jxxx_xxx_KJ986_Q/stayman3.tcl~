source lib/utility.tcl
source lib/ddscore.tcl

set dealCnt 0
set successCnt 0
set failureCnt 0

proc weak_nt { hand min max } {
    set s [spades $hand]
    set h [hearts $hand]
    set d [diamonds $hand]
    set c [clubs $hand]
    set count(0) 0
    set count(1) 0
    set count(5) 0
    set count(6) 0
    set count(7) 0

    incr count($s)
    incr count($h)
    incr count($d)
    incr count($c)
    if {
	($count(1)==0) && 
	($count(0)==0) && 
	($count(7)==0)
    } {
	if {$count(5) > 1 || $s > 5 || $h > 5} { return 0 }

	set hcp [expr [hcp $hand] + $count(6)]
	return [expr {$hcp>=$min && $hcp<=$max}]
    }
    return 0	
}

proc my_write_deal { newdealer newcontract } {
	set line [list]
	set scores [list]
	foreach hand {north east south west} {
		#lappend line [join [$hand] "."]
	}
	foreach hand {north south} {
		lappend line [join [$hand shape] "."]
	}
	lappend scores [ddscore {1 notrump} south nonvul]
	lappend scores [ddscore $newcontract $newdealer nonvul]

	set diff [expr [lindex $scores 1] - [lindex $scores 0]]
	global successCnt failureCnt
	if {($diff > 0)} {incr successCnt}
	if {($diff < 0)} {incr failureCnt}
	puts "[join $line |]|[join $scores |]|$newcontract|$diff"
}



main {
	global dealCnt
	incr dealCnt
	if {![weak_nt south 11 13]} {reject}
	#if {![semibalanced east]} {reject}
	#if {![semibalanced west]} {reject}
	if {!([north pattern] == "5 4 3 1")} {reject}
	if {([clubs north] != 5)} {reject}
	if {([hcp north] > 9) || ([hcp north] < 6)} {reject}
	set sh [hearts south]
	set ss [spades south]
	set sd [diamonds south]
	set sc [clubs south]
	set nh [hearts north]
	set ns [spades north]
	set nc [clubs north]
	set nd [diamonds north]
	if { ($ss < 4) && ($sh < 4) && ($nd >= 4) } {
		set newcontract "2 diamonds"
		set newdealer south
	} elseif { ($sh + $nh >= 7 && $sh >= 3 && $nh >= 3) } {
		set newcontract "2 hearts"
		set newdealer north
		if { ($sh >= 4) } {set newdealer south}
	} elseif { ($ss + $ns >= 7 && $ss >= 3 && $ns >= 3 && ($sh < 4 || $ns>=4)) } {
		set newcontract "2 spades"
		set newdealer south
		if { ($sh >= 4) || ($ss == 3) } { set newdealer north }
	} elseif { ($sd + $nd <= $sc + $nc + 1) } {
		set newcontract "3 clubs"
		set newdealer south
	} else {
		set newcontract "3 diamonds"
		set newdealer south
	}
	my_write_deal $newdealer $newcontract
	accept
}

deal_finished {
	global dealCnt
	global successCnt failureCnt
	puts "success $successCnt ; failure $failureCnt"
	puts "Generated $dealCnt deals"
}
