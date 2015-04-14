source lib/utility.tcl
source format/none
source lib/counters.tcl
source lib/ddscore.tcl

set dealCnt 0
set acceptedCnt 0
set heartLabels [list . sum 4 5 6 7 8 9 10 11 12 avg ] 
set spadeLabels [ list . sum 2 3 4 5 6 7 8 9 10 11 avg ]
set hcpLabels [list . sum 13 14 15 avg ]
init res "hearts   \\ spades" $heartLabels $spadeLabels 
init hcpHearts "hcp  \\ hearts" $hcpLabels $heartLabels
init hcpSpades "hcp  \\ spades" $hcpLabels $spadeLabels


proc writeDeal {} {
	#puts "[spades north]-[hearts north]-[diamonds north]-[clubs north]"
}

south is "QT964 QT9 A4 T42"

main {
	global dealCnt
	incr dealCnt
        if {$dealCnt % 100000 == 0} {puts "$dealCnt $acceptedCnt"}
	global res
	global accceptedCnt
        set hcpn [hcp north]
        if {($hcpn < 13 || $hcpn > 15)} { reject}
        if {[hearts north] < 5} { reject }
        if {[spades north] != 1} {reject}
        if {[diamonds north] < 3} { reject}
        if {[clubs north] < 3} {reject}
        if {[spades west] < 3 || [spades east] < 3} {reject}
        if {[hcp east] < 12} {reject}
        if {[hcp north spades] > 1} {reject}
        incr acceptedCnt
        set nhtricks [deal::tricks north hearts] 
        set wstricks [deal::tricks west spades] 
        increment res $nhtricks $wstricks
        increment hcpHearts $hcpn $nhtricks 
        increment hcpSpades $hcpn $wstricks
        writeDeal
        accept
}

deal_finished {
	global dealCnt
	global acceptedCnt
	puts "Generated $dealCnt deals"
	outputdb 
        ##$acceptedCnt
}

