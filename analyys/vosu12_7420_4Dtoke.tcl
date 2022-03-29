source lib/utility.tcl
source lib/ddscore.tcl
source lib/counters.tcl
source format/count


south is "82 9754 K986532 -"

set cellWidth 6
set numberPrecision 3

#proc normalizeCount { count } {
#	global dealCnt
#	return [expr 100.0 * $count / $dealCnt]
#}


set rows [list . 0 1 2 3 4 5 6 7 8 9 10 11 12 13 sum avg sdev]

init diamondgame "Diamond games"
init heartgame "Heart games"
init diamtricks "Diamond tricks" $rows
init hearttricks "Heart tricks" $rows
init dh "\nDiamond-heart trick matrix" $rows $rows
init dhtricks "\nDiamond/heart tricks array" [list . d h] $rows
unset rows


proc analyze { } {
	set dtr [deal::tricks south diamonds]
	set htr [deal::tricks south hearts]
	increment dh $dtr $htr
	if { $dtr >= 11 } { increment diamondgame }
	if { $htr >= 10 } { increment heartgame }
	increment diamtricks $dtr
	increment hearttricks $htr
	increment dhtricks d $dtr
	increment dhtricks h $htr
}	

main {
	global dealCnt
	if { [hcp east] < 16 } { reject }
	
	incr dealCnt
	analyze
	if { $dealCnt % 1000 == 0 } { puts "$dealCnt" }
	accept
}

deal_finished {
	global dealCnt tab
	
	outputdb 
        #$tab
	puts "Generated $dealCnt deals"
	
	#puts $tab
}


