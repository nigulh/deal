source lib/utility.tcl
source format/none

set dealCnt 0
set subCnt(d) 0
set subCnt(wnt) 0
set subCnt(snt) 0
set subCnt(c) 0

proc writeSubCnt {} {
	global subCnt
	puts "Diams:   $subCnt(d)"
	puts "11-13NT:  $subCnt(wnt)"
	puts "14-15NT: $subCnt(snt)"
	puts "1444/1453: $subCnt(c)"
}

proc writeDeal {} {
	#puts [handPattern]
}
proc findSubType {} {
	if {[nt north 11 13]} {
		return wnt
	}
	if {[nt north 14 15]} {
		return snt
	}
	if {[hcp north] < 11 || [hcp north] > 15} {
		return 
	}
	if {[diamonds north] >= 5 || ([clubs north] >= 5 && [diamonds north] >= 4)} {
		return d
	}
	if {[diamonds north] <= 1 && [clubs north] <= 5 && [hearts north] <= 4 && [spades north] <= 4} {
		return c
	}
	return
}
main {
	global dealCnt
	incr dealCnt
	global subCnt

	set type [findSubType]
	if {$type != ""} {
		incr subCnt($type)
		accept
		writeDeal
	} else {
		reject
	}
}

deal_finished {
	global dealCnt
	writeSubCnt
	puts "Generated $dealCnt deals"
}

