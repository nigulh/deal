source lib/utility.tcl
source format/none

set dealCnt 0
set subCnt(d) 0
set subCnt(wnt) 0
set subCnt(nt) 0
set subCnt(snt) 0
set subCnt(c) 0
set subCnt(t) 0

proc writeSubCnt {} {
	global subCnt
	puts "Diams:   $subCnt(d)"
        puts "4144: $subCnt(t)"
	puts "11-12NT:  $subCnt(wnt)"
        puts "13NT: $subCnt(nt)"
	puts "14-15NT: $subCnt(snt)"
	puts "4415/1: $subCnt(c)"
}

proc writeDeal {} {
	puts [north]
}
proc findSubType {} {
	if {[nt north 11 12]} {
		return wnt
	}
	if {[nt north 13 13]} {
		return nt
	}
	if {[nt north 14 15]} {
		return snt
	}
	if {[hcp north] < 11 || [hcp north] > 15} {
		return 
	}
        if {[diamonds north] <= [hearts north] * ([hearts north] >= 5) || [diamonds north] <= [spades north] * ([spades north] >= 5)} {
                return
        }
	if {[diamonds north] <= 1 && [clubs north] <= 5 && [hearts north] <= 4 && [spades north] <= 4} {
		return c
	}
        if {[clubs north] >= 6 || ([clubs north] == 5 && ([hearts north] >= 4 || [spades north] >= 4))} {
                return
        }
        if {[diamonds north] == 4 && [clubs north] == 4} {
                return t
        }
	if {[diamonds north] >= 5 || ([clubs north] >= 5 && [diamonds north] >= 4)} {
		return d
	}
        if {[diamonds north] == 4} {
                return d
        }
        puts [north]
	return
}
main {
	global dealCnt
	incr dealCnt
	global subCnt

	set type [findSubType]
	if {$type != ""} {
		incr subCnt($type)
		#writeDeal
		accept
	} else {
		reject
	}
}

deal_finished {
	global dealCnt
	writeSubCnt
	puts "Generated $dealCnt deals"
}

