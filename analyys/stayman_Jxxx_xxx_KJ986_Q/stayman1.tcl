source lib/utility.tcl
source lib/score.tcl

north is "J954 543 KJ986 Q"

proc weak_nt { hand min max } {
    set s [spades $hand]
    set h [hearts $hand]
    set d [diamonds $hand]
    set c [clubs $hand]
    set count(0) 0
    set count(1) 0
    set count(2) 0
    set count(3) 0
    set count(4) 0
    set count(5) 0
    set count(6) 0
    set count(7) 0
    set count(8) 0
    set count(9) 0
    set count(10) 0
    set count(11) 0
    set count(12) 0
    set count(13) 0

    set count($s) [expr $count($s) + 1]
    set count($h) [expr $count($h) + 1]
    set count($d) [expr $count($d) + 1]
    set count($c) [expr $count($c) + 1]
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

proc my_write_deal { newdealer newsuit } {
	set line [list]
	set scores [list]
	foreach hand {north east south west} {
		lappend line [join [$hand] "."]
	}
	#lappend score [deal::tricks north notrump]
	lappend scores [score {1 notrump} nonvul [deal::tricks south notrump]]
	lappend scores [score "2 $newsuit" nonvul [deal::tricks $newdealer $newsuit]]

	set diff [expr [lindex $scores 1] - [lindex $scores 0]]
	puts "[join $line |]|[join $scores |]|$newsuit|$diff"
}

main {
	if {![weak_nt south 11 13]} {reject}
	if {![semibalanced east]} {reject}
	if {![semibalanced west]} {reject}
	set wh [hearts west]
	set eh [hearts east]
	#if {($wh < 7) || ($eh > 0)} {reject}
	set sh [hearts south]
	set ss [spades south]
	set sd [diamonds south]
	set sc [clubs south]
	set newsuit diamonds
	if {($ss >= 4)} {set newsuit spades}
	if {($sh >= 4)} {set newsuit hearts}
	my_write_deal south $newsuit
	accept
}



