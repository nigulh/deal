source lib/utility.tcl
source format/none
source lib/counters.tcl
source lib/ddscore.tcl

set dealCnt 0
set acceptedCnt 0
set heartLabels [list . sum avg 4 5 6 7 8 9 10 11 12 13 ]
set spadeLabels [ list . sum avg 2 3 4 5 6 7 8 9 10 11 12 13 ]
set hcpLabels [list . sum avg 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ]
#init res "♥N   \\ ♠W" $heartLabels $spadeLabels
#init hcpHearts "hcpE  \\ ♥N" $hcpLabels $heartLabels
#init hcpSpades "hcpE  \\ ♠W" $hcpLabels $spadeLabels
#init buckets "buckets" [ list . sum 0 1 2 3 4 5 6 7 ]

set bucketTable [ list \
  "00000000013333" \
  "00000000013333" \
  "00000000013333" \
  "00000000013333" \
  "00000000013333" \
  "00000000013333" \
  "00000000013333" \
  "00000000013333" \
  "00000000013333" \
  "00000000133333" \
  "00000001233333" \
  "00000001233333" \
  "00000001233333" \
  "00000001233333"
]
proc getBucket { we ns } {
    global bucketTable
    set row [ lindex $bucketTable $we ]
    set char [ string index $row $ns ]
    return $char
}

proc formatHands {} {
  foreach hand {north east south west} {
    set fmt($hand) "[$hand spades]-[$hand hearts]-[$hand diamonds]-[$hand clubs]"
  }
  return $fmt(west)
  #puts "\[Deal \"N:$fmt(north) $fmt(east) $fmt(south) $fmt(west)\"\]"
  #puts ""
}

proc writeDeal {} {
	global acceptedCnt
	set imps [ list -10 -2 0 8 ]
    if {$acceptedCnt == 1} {
        init buckets [formatHands] [ concat [list . avg ] $imps ]
    }
	#puts "[spades north]-[hearts north]-[diamonds north]-[clubs north]"
    set nhtricks [deal::tricks north hearts]
    set wstricks [deal::tricks west spades]
    #increment res $nhtricks $wstricks
    #increment hcpHearts $hcpe $nhtricks
    #increment hcpSpades $hcpe $wstricks
    set bucket [ getBucket $nhtricks $wstricks ]
    increment buckets [lindex $imps $bucket]
}

# west is "KQ9753 3 42 A942"
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

