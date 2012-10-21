source lib/utility.tcl
source lib/ddscore.tcl
source lib/parscore.tcl

set dealCnt 0
set notrumpCnt(7) 0
set notrumpCnt(8) 0
set notrumpCnt(9) 0
set notrumpCnt(10) 0
set notrumpCnt(11) 0
set notrumpCnt(12) 0
set notrumpCnt(13) 0

proc max {args} {
	if {[llength $args] < 1} {
		error "not enough args"
	}
	set ret [lindex $args 0]
	foreach el [lrange $args 1 end] {
		if {$el > $ret} { set ret $el}
	}
	return $ret
}

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

proc my_write_deal {  } {
	set line [list]
	set scores [list]
	foreach hand {north east south west} {
		lappend line [join [$hand] "."]
	}

	#set parsc [parscore south ew]
	#set ntsc [ddscore "2 notrump doubled" south nonvul]
	#set nt [deal::tricks north notrump]
	lappend scores [ddscore "2 notrump" south nonvul]
	lappend scores [ddscore "3 clubs" north nonvul]
	lappend scores [ddscore "3 diamonds" north nonvul]
	lappend scores [max [ddscore "3 hearts" north nonvul] -[ddscore "3 hearts" east nonvul]]
	lappend scores [max [ddscore "3 spades" north nonvul] -[ddscore "3 spades" east nonvul]]

	puts "[join $line |]|[join $scores |]"
}

set mainCnt 0

defvector top3 1 1 1
defvector points 4 3 2 1
main {
	global dealCnt mainCnt
	incr dealCnt
	if {![weak_nt south 14 15]} {reject}
	if {[clubs south] < 3 || [diamonds south] < 3 || [hearts south] < 2 || [spades south] < 2} {reject}
	if {![weak_nt north 0 10]} {reject}
	
	my_write_deal 
	incr mainCnt 
	if { ($mainCnt % 100) == 0 } { puts stderr "$mainCnt" }
	accept
}

deal_finished {
	global dealCnt
	puts "Total notrumps: $notrumpCnt(8) $notrumpCnt(9) $notrumpCnt(10) $notrumpCnt(11) $notrumpCnt(12) $notrumpCnt(13)"
	puts "Generated $dealCnt deals"
}
