source lib/counters.tcl
source format/none
source lib/ddscore.tcl

set firstCellWidth 25

proc initdb {} {
    global dealCnt
    incr dealCnt
    if { $dealCnt != 1 } {
        return
    }

    set nh "[north]  [hcp north]"

    set colLabels [ list . 4 5 6 7 8 9 10 11 12 13 sum avg]
    set suits [list . "nt" "s" "h" "d" "c"] 
    init tricks "tricks" $suits $colLabels
    init game $nh [concat $suits avg]
}

proc analyze { } {
        set ctr [deal::tricks south clubs]
        set dtr [deal::tricks south diamonds]
        set htr [deal::tricks south hearts]
        set str [deal::tricks south spades]
        set ntr [deal::tricks south notrump]

        increment tricks "nt" $ntr
        if {$ntr >= 9} { 
            increment game "nt" 
        }
        increment tricks "s" $str
        if {$str >= 10} {
            increment game "s"
        }
        increment tricks "h" $htr
        if {$htr >= 10} {
            increment game "h"
        }
        increment tricks "d" $dtr
        if {$dtr >= 11} {
            increment game "d"
        }
        increment tricks "c" $ctr
        if {$ctr >= 11} {
            increment game "c"
        }

        set isgame 0
        if {$htr >= 10 || $str >= 10 || $ctr >= 11 || $dtr >= 11 || $ntr >= 9} { 
            set isgame 100
        }
        increment game $isgame
}       

shapecond precision.shape {($c>=5)&&($s==4||$h==4||$c>=6)}

proc open2c {hand min max} {
        if {[precision.shape $hand]} {
                set hcp [hcp $hand]
                return [expr {$hcp>=$min && $hcp<=$max}]
        }
        return 0
}


main {
        initdb

        if {[open2c south 10 15] == 0} { reject }
        puts -nonewline stderr "\r$dealCnt: [north]" 

	analyze
	accept
}

deal_finished {
	puts stderr ""
	outputdb
}


