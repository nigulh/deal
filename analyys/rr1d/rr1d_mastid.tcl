source lib/utility.tcl
source format/none
source lib/counters.tcl

set dealCnt 0
set acceptedCnt 0
set subCnt(d) 0
set subCnt(wnt) 0
set subCnt(snt) 0
set subCnt(c) 0

init len "" [list "c" "d" "h" "s" ] [ list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 avg ]


proc writeSubCnt {} {
	global subCnt
	puts "Diams:   $subCnt(d)"
	puts "11-13NT:  $subCnt(wnt)"
	puts "14-15NT: $subCnt(snt)"
	puts "1444/1453: $subCnt(c)"
}

proc writeDeal {} {
	#puts "[spades north]-[hearts north]-[diamonds north]-[clubs north]"
}
proc findSubType {} {
	if {[nt north 11 13]} {
		return wnt
	}
	if {[nt north 14 15]} {
		#return snt
	}
	if {[hcp north] < 11 || [hcp north] > 15} {
		return 
	}
	if {[diamonds north] <= 5 && ([hearts north] >= 5 || [spades north] >= 5)} {
		return
	}
	if {[clubs north] >= 6 && [diamonds north] < 4 } {
		return	
	}
	if {[clubs north] >= 5 && ([hearts north] >= 4 || [spades north] >= 4)} {
		return	
	}
	if {[diamonds north] >= 5 || ([clubs north] >= 5 && [diamonds north] >= 4)} {
		return d
	}
	if {[diamonds north] <= 1 && [clubs north] <= 5 && [hearts north] <= 4 && [spades north] <= 4} {
		return c
	}
	return d
}
main {
	global dealCnt
	incr dealCnt
	global subCnt
	global len
	global accceptedCnt

	set type [findSubType]
	if {$type != ""} {
		incr subCnt($type)
		incr acceptedCnt
		increment len "c" [clubs north]
	        increment len "d" [diamonds north]	
		increment len "h" [hearts north]
	        increment len "s" [spades north]	
		writeDeal
		accept
	} else {
		reject
	}
}

proc normalizeCount { count } {
	global acceptedCnt
	if {[string is integer -strict $count]} {
		return [expr 100.0 * $count / $acceptedCnt]
	}
	return $count
}

deal_finished {
	global dealCnt
	global len
	puts "Generated $dealCnt deals"
	writeSubCnt
	outputdb
}

