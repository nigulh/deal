#source format/none

shapecond precision.shape {($c>=5)&&($s==4||$h==4||$c>=6)}

proc open2c {hand min max} {
        if {[precision.shape $hand]} {
                set hcp [hcp $hand]
                return [expr {$hcp>=$min && $hcp<=$max}]
        }
        return 0
}

proc write_deal {} {
	puts "[south]"
	puts stderr "[south]"
}

main {
	if {[hcp south] < 10 } { reject }
	if {[hcp south] > 16 } { reject }
	if {![open2c north 10 15]} { reject }
	accept
}
