source lib/utility.tcl
source lib/ddscore.tcl

array set nttricks {
	0 0
	1 0
	2 0
	3 0
	4 0
	5 0
	6 0
	7 0
	8 0
	9 0
	10 0
	11 0
	12 0
	13 0
	14 0
	15 0
	16 0
	17 0
	18 0
	19 0
	20 0
	21 0
	22 0
	23 0
	24 0
	25 0
	26 0
	27 0
	28 0
	29 0
	30 0
	31 0
	32 0
	33 0
	34 0
	35 0
	36 0
	37 0
	38 0
	39 0
	40 0
	41 0
	42 0
	43 0
	44 0
	45 0
	46 0
	47 0
	48 0
	49 0
}

proc my_write_deal {  } {
	set line [list]
	set scores [list]
	foreach hand {north east south west} {
		lappend line [join [$hand] "."]
		lappend scores [deal::tricks $hand notrump]
	}

	puts "[join $line |]|[join $scores |]"
}

main {
	global dealCnt
	incr dealCnt
	global nttricks
	if { [spades south] > 0} {reject}
	if { [hearts west] > 0} {reject}
	if { [diamonds north] > 0} {reject}
	if { [clubs east] > 0} {reject}
	set nttot [expr [deal::tricks north notrump] + [deal::tricks east notrump] + [deal::tricks south notrump] + [deal::tricks west notrump]]
	if {$nttot > 30} { my_write_deal }
	if {$nttot < 20} { my_write_deal }
	incr nttricks($nttot)
	accept
}

deal_finished {
	global dealCnt
	global nttricks
	for {set i 20} {$i<30} {incr i} {
		puts "$i $nttricks($i)"
	}
	puts "Generated $dealCnt deals"
}
