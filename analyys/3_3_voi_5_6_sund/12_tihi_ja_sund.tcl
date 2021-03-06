source lib/utility.tcl
source lib/ddscore.tcl
source lib/parscore.tcl

south is "AKQ6 T982 AKQ 32"
north is "432 AK65 32 AKQJ"
set grandCnt 0
set dealCnt 0

proc my_write_deal { } {
	global grandCnt
	set c [deal::tricks north notrump]
	if { $c >= 13} {incr grandCnt }
}

set mainCnt 0

defvector top3 1 1 1
defvector points 4 3 2 1
main {
	global dealCnt mainCnt
	incr dealCnt

	my_write_deal 
	incr mainCnt 
	if { ($mainCnt % 100) == 0 } { puts stderr "$mainCnt" }
	accept
}

deal_finished {
	global dealCnt
	global grandCnt
	puts "slam good: $grandCnt"
	puts "Generated $dealCnt deals"
}
