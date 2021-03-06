source lib/utility.tcl
source lib/ddscore.tcl

#south is "AKQJ J8 AK96 872"
south is "AKJ2 J8 AK96 Q87"
set dealCnt 0
set 3NTCnt 0
set 4HCnt 0
set 4SCnt 0
set 5CCnt 0
set 5DCnt 0
set gameCnt 0
set slamCnt 0
set notrumpCnt(7) 0
set notrumpCnt(8) 0
set notrumpCnt(9) 0
set notrumpCnt(10) 0
set notrumpCnt(11) 0
set notrumpCnt(12) 0
set notrumpCnt(13) 0

proc my_write_deal {  } {
	set line [list]
	set scores [list]
	foreach hand {north} {
		lappend line [join [$hand] "."]
	}
	foreach denom {clubs diamonds hearts spades notrump} {
		lappend scores [deal::tricks south $denom]
	}
	global 3NTCnt 4HCnt 4SCnt 5CCNT 5DCnt slamCnt gameCnt
	
	set c [lindex $scores 0]
	set d [lindex $scores 1]
	set h [lindex $scores 2]
	set s [lindex $scores 3]
	set nt [lindex $scores 4]
	incr notrumpCnt($nt)
	if { $nt >= 9 } { incr 3NTCnt }
	if { $s >= 10} {incr 4SCnt }
	if { $h >= 10} {incr 4HCnt }
	if { $d >= 11} {incr 5DCnt }
	if { $c >= 11} {incr 5CCnt }
	if { ($nt >= 9) || ($s >= 10) || ($h >= 10) || ($d >=11) || ($c >= 11) } { incr gameCnt }
	if { ($nt >= 12) || ($s >= 12) || ($h >= 12) || ($d >=12) || ($c >= 12) } { incr slamCnt }

	puts "[join $line |]|[join $scores |]"
}

set mainCnt 0

main {
	global dealCnt mainCnt
	incr dealCnt
	if {[hcp north]!=8} {reject}
	my_write_deal 
	incr mainCnt 
	if { ($mainCnt % 100) == 0 } { puts stderr "$mainCnt" }
	accept
}

deal_finished {
	global dealCnt
	global heartCnt notrumpCnt slamCnt 3NTCnt 4HCnt 4SCnt 5CCnt 5DCnt gameCnt
	puts "Total notrumps: $notrumpCnt(8) $notrumpCnt(9) $notrumpCnt(10) $notrumpCnt(11) $notrumpCnt(12) $notrumpCnt(13)"
	puts "3NT good: $3NTCnt , 4H good: $4HCnt 4S good: $4SCnt , 5C: $5CCnt , 5D: $5DCnt , game: $gameCnt , slamgood: $slamCnt"
	puts "Generated $dealCnt deals"
}
