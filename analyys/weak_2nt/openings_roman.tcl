source lib/utility.tcl
source lib/ddscore.tcl
source lib/parscore.tcl

set dealCnt 0
set 1C 0
set 1D 0
set 1H 0
set 1S 0
set 1N 0
set 2C 0
set 2D 0
set 2H 0
set 2S 0
set 2N 0
set P 0
set X 0
set openingsCnt(0) 0
set openingsCnt(1) 0
set openingsCnt(2) 0
set openingsCnt(3) 0
set openingsCnt(4) 0
set openingsCnt(5) 0

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

	set parsc [parscore south ew]
	set ntsc [ddscore "2 notrump doubled" south nonvul]
	#set nt [deal::tricks north notrump]
	lappend scores $parsc
	lappend scores $ntsc

	puts "[join $line |]|[join $scores |]"
}

set mainCnt 0

main {
	global dealCnt
	global 1C 1D 1H 1S 1N 2C 2D 2H 2S 2N P
	incr dealCnt
	set done 0
	set hcp [hcp south]
	set h [hearts south]
	set s [spades south]
	set c [clubs south]
	set d [diamonds south]
	#if {[weak_nt south 14 15] && $h <= 3 && $s <= 3} {incr 2N ; incr done}
	if {[weak_nt south 14 15] && $c >= 3 && $d >= 3} {incr 2N ; incr done}
	#if {14 <= $hcp && $hcp <= 15 && $c >= 3 && $d >= 3 && $h <= 4 && $s <= 4} {incr 2N ; incr done}
	if {[weak_nt south 11 13]} {incr 1N ; incr done}
	if {$hcp > 16} {incr 1C}
	if {10 <= $hcp && $hcp <= 16 && [hearts south] >= 5} { incr 1H; incr done}
	if {10 <= $hcp && $hcp <= 16 && [spades south] >= 5} { incr 1S; incr done}
	if {10 <= $hcp && $hcp <= 16 && ($c >= 6 || $c == 5 && ($h == 4 || $s == 4)) } {incr 2C; incr done}
	if {11 <= $hcp && $hcp <= 16 && $done == 0} {incr 1D; incr done}
	if {6 <= $hcp && $hcp <= 10 && $h >= 5 && ($s >= 5 || $c >= 5 || $d >= 5)} {incr 2H; incr done}
	if {6 <= $hcp && $hcp <= 10 && $s >= 5 && ($c >= 5 || $d >= 5)} {incr 2S; incr done}
	if {6 <= $hcp && $hcp <= 10 && ($s >= 6 || $h >= 6)} {incr 2D; incr done}

	if {$done == 0} {incr P; incr done}
	if {$done > 2} {incr X}
	
	#my_write_deal 
	incr mainCnt 
	accept
}

deal_finished {
	global dealCnt
	global 1C 1D 1H 1S 1N 2C 2D 2H 2S 2N P
	puts "1C $1C"
	puts "1D $1D"
	puts "1H $1H"
	puts "1S $1S"
	puts "1N $1N"
	puts "2C $2C"
	puts "2D $2D"
	puts "2H $2H"
	puts "2S $2S"
	puts "2N $2N"
	puts "P $P"
	puts "X $X"
	puts "Generated $dealCnt deals"
}
