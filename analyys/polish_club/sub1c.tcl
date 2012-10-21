source lib/utility.tcl
source format/none

set dealCnt 0
set subCnt(w) 0
set subCnt(c) 0
set subCnt(s) 0
set subCnt(sb) 0

proc writeSubCnt {} {
	global subCnt
	puts "Weak:   $subCnt(w)"
	puts "Clubs:  $subCnt(c)"
	puts "18-20 bal: $subCnt(sb)"
	puts "Strong: $subCnt(s)"
}

proc writeDeal {} {
	#puts [handPattern]
}
proc findSubType {} {
	if {[nt north 12 14]} {
		return w
	}
	if {[nt north 18 20]} {
		return sb
	}
	if {[hcp north] >= 20} {
		return s
	}
	if {[hcp north] >= 17 && ([spades north] > 5 || [hearts north] > 5)} {
		return s
	}
	if {![balanced north] && ([clubs north] + [hcp north] >= 21) && ([clubs north] >= 4)} {
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

