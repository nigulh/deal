source lib/utility.tcl
source lib/ddscore.tcl

north is "J954 543 KJ986 Q"
set dealCnt 0

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

proc my_write_deal { newdealer newsuit } {
	set line [list]
	set scores [list]
	foreach hand {north east south west} {
		lappend line [join [$hand] "."]
	}
	#lappend score [deal::tricks north notrump]
	lappend scores [ddscore {1 notrump} south nonvul]
	#[deal::tricks south notrump]]
	lappend scores [ddscore "2 $newsuit" $newdealer nonvul]
       	#[deal::tricks $newdealer $newsuit]]

	set diff [expr [lindex $scores 1] - [lindex $scores 0]]
	puts "[join $line |]|[join $scores |]|$newsuit|$diff"
}



main {
	global dealCnt
	incr dealCnt
	if {![weak_nt south 15 17]} {reject}
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

deal_finished {
	global dealCnt
	puts "Generated $dealCnt deals"
}
