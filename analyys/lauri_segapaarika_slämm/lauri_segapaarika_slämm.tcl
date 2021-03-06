source lib/utility.tcl
source lib/ddscore.tcl

south is "AKT83 AQ94 2 AK3"
set slamCnt 0
set dealCnt 0
set HCnt(9) 0
set HCnt(10) 0
set HCnt(11) 0
set HCnt(12) 0
set HCnt(13) 0

proc my_write_deal {  } {
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

set mainCnt 0

defvector top3 1 1 1
defvector points 4 3 2 1
main {
	global dealCnt mainCnt
	incr dealCnt
	set hcpn [hcp north]
	if {($hcpn != 11)} {reject}
	if {! [balanced north]} {reject}
	if {[hearts north]!=4} {reject}
	my_write_deal 
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
