source lib/utility.tcl
source format/none

set maxSecondSuit 7
set dealCnt 0
set minFullCnt 0


proc initFullCnt { } {
	global maxSecondSuit
	global fullCnt
	for {set i 0} {$i < $maxSecondSuit} {incr i} {
    	for {set j 0} {$j < $maxSecondSuit} {incr j} {
			for {set k 0} {$k < $maxSecondSuit} {incr k} {
				set v [expr 13 - ($i+$j+$k)]
				if {$v >= 0} {
					for {set h 0} {$h < 40} {incr h} {
						set fullCnt([list $i $j $k $v $h]) 0
					}
				}
			}
		}
	}
}

initFullCnt

proc handPattern {} {
	return [lsort -integer [list [spades north] [hearts north] [diamonds north] [clubs north]]]
}

proc updateFullCnt {} {
	global fullCnt
	set handPattern [handPattern]
	lappend handPattern [hcp north]
	incr fullCnt($handPattern);
}

proc writeDeal {} {
	#puts [handPattern]
}

proc writeFullCnt {} {
	global maxSecondSuit
	global fullCnt minFullCnt
	set outputCnt 0
	for {set h -1} {$h < 40} {incr h} {
		set outputRow [list $h]
		for {set i 0} {$i < $maxSecondSuit} {incr i} {
			for {set j 0} {$j < $maxSecondSuit} {incr j} {
				for {set k 0} {$k < $maxSecondSuit} {incr k} {
					set v [expr 13 - ($i+$j+$k)]
					if {$i <= $j && $j <= $k && $k <= $v} {
						if {$h == -1} {
							lappend outputRow "$v-$k-$j-$i"
						} else {
							set d [list $i $j $k $v $h]
							if {$fullCnt($d) >= $minFullCnt} {
								lappend outputRow "$fullCnt($d)"
								incr outputCnt $fullCnt($d)
							}
						}
					}
				}
			}
		}
		puts [join $outputRow " "]
	}
	puts "Total output: $outputCnt"
}

main {
	global dealCnt
	incr dealCnt
	
	updateFullCnt
	writeDeal
	accept
}

deal_finished {
	global dealCnt
	writeFullCnt
	puts "Generated $dealCnt deals"
}

