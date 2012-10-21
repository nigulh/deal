source lib/utility.tcl
source lib/ddscore.tcl

#south is "AKQJ J8 AK96 872"
south is "AJ832 65 65 KQT2"
set dealCnt 0
set 6CCnt 0
set 7CCnt 0
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
	global 6CCnt 7CCnt notrumpCnt
	set c [deal::tricks north clubs]
	#set nt [deal::tricks north notrump]
	lappend scores $c
	#lappend scores $nt
	
	#incr notrumpCnt($nt)
	if { $c >= 12} {incr 6CCnt }
	if { $c >= 13} {incr 7CCnt }

	puts "[join $line |]|[join $scores |]"
}

set mainCnt 0

defvector top3 1 1 1
defvector points 4 3 2 1
main {
	global dealCnt mainCnt
	incr dealCnt
	set hcpn [hcp north]
	if {($hcpn < 17) || ($hcpn > 18)} {reject}
	if {[clubs north] != 5} {reject}
	if {[spades north] != 1} {reject}
	if {[hearts north] < 3} { reject }
	if {[diamonds north] < 3} { reject }
	if {[points north spades] != 2 } { reject }
	my_write_deal 
	incr mainCnt 
	if { ($mainCnt % 100) == 0 } { puts stderr "$mainCnt" }
	accept
}

deal_finished {
	global dealCnt
	global notrumpCnt 6CCnt
	puts "Total notrumps: $notrumpCnt(8) $notrumpCnt(9) $notrumpCnt(10) $notrumpCnt(11) $notrumpCnt(12) $notrumpCnt(13)"
	puts "6C good: $6CCnt , 7C good: $7CCnt"
	puts "Generated $dealCnt deals"
}
