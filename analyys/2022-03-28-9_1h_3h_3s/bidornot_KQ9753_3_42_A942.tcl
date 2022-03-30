source lib/utility.tcl
source format/none
source lib/counters.tcl
source lib/ddscore.tcl

set dealCnt 0
set acceptedCnt 0
set heartLabels [list . sum avg 4 5 6 7 8 9 10 11 12 13 ]
set spadeLabels [ list . sum avg 2 3 4 5 6 7 8 9 10 11 12 13 ]
set hcpLabels [list . sum avg 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ]
init res "♥N   \\ ♠W" $heartLabels $spadeLabels
init hcpHearts "hcpE  \\ ♥N" $hcpLabels $heartLabels
init hcpSpades "hcpE  \\ ♠W" $hcpLabels $spadeLabels


proc writeDeal {} {
	#puts "[spades north]-[hearts north]-[diamonds north]-[clubs north]"
}

west is "KQ9753 3 42 A942"
# N:1H (natural) - S:3H (6-10 4-ne) - ?

main {
	global dealCnt
	incr dealCnt
        if {$dealCnt % 100000 == 0} {puts "$dealCnt $acceptedCnt"}
	global res
	global accceptedCnt
        set hcpn [hcp north]
        set hcps [hcp south]
        set hcpe [hcp east]
        if {($hcpn < 11 || 21 < $hcpn )} { reject}
        if {[hearts north] < 5} { reject }
        if {($hcps < 6 || 10 < $hcps )} { reject}
        if {[hearts south] < 4} { reject }
        incr acceptedCnt
        set nhtricks [deal::tricks north hearts] 
        set wstricks [deal::tricks west spades] 
        increment res $nhtricks $wstricks
        increment hcpHearts $hcpe $nhtricks
        increment hcpSpades $hcpe $wstricks
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

