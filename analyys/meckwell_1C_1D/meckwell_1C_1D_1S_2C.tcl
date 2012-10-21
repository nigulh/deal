source lib/utility.tcl
source lib/ddscore.tcl
source lib/parscore.tcl

set slamCnt 0
set dealCnt 0
set HCnt(9) 0
set HCnt(10) 0
set HCnt(11) 0
set HCnt(12) 0
set HCnt(13) 0

proc my_write_deal_2 {  } {
	set line [list]
	set scores [list]
	foreach hand {north} {
		lappend line [join [$hand] "."]
	}
	global slamCnt HCnt
	set c [deal::tricks south hearts]
	lappend scores $c
	
	if { $c >= 12} {incr slamCnt }
	incr HCnt($c)

	puts "[join $line |]|[join $scores |]"
}

proc my_write_deal { } {
	#set parscore [parscore north "EW"];
	#puts $parscore;
	set s [deal::tricks east spades]
	set h [deal::tricks west hearts]
	set d [deal::tricks south diamonds]
	set c [deal::tricks north clubs]

	puts "$s $h $d $c"
}

set mainCnt 0

defvector top3 1 1 1
defvector points 4 3 2 1
main {
	global dealCnt mainCnt
	incr dealCnt


	# south opens 1C - 1S
	set hcps [hcp south]
	if {($hcps < 16)} {reject}
	set ss [spades south]
	set sh [hearts south]
	if {($ss < 4)} {reject}
	if {($ss < $sh)} {reject}
	if {($ss == 4 && $sh == 4)} {reject}
	if {[balanced south]} {reject}
	# north responds 1D - 2C
	set hcpn [hcp north]
	if {($hcpn > 7)} {reject}
	if {($hcpn < 6)} {reject}
	if {[spades north] > 2} {reject}

	# my_write_deal 
	incr mainCnt 
	if { ($mainCnt % 100) == 0 } { puts stderr "$mainCnt" }
	accept
}

deal_finished {
	global dealCnt
	global slamCnt HCnt
	puts "slam good: $slamCnt"
	puts "H 9: $HCnt(9), H10: $HCnt(10), H11: $HCnt(11), H12: $HCnt(12), H13: $HCnt(13)"
	puts "Generated $dealCnt deals"
}
