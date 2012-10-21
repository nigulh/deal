source lib/utility.tcl
source lib/ddscore.tcl

array set northtricks {
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
}

array set southtricks {
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

proc analyze { } {
	global northtricks
	global southtricks
	foreach hand { north } {
		set mosttricks [deal::tricks $hand notrump]
		foreach suit { spades hearts diamonds clubs } {
			if { [$suit north] + [$suit south] < 6 } { continue }
			set currenttricks [deal::tricks $hand $suit]
			if {$currenttricks > $mosttricks} { set mosttricks $currenttricks}
		}
		incr northtricks($mosttricks)
	}
}

main {
	global dealCnt
	incr dealCnt

	analyze

	if { $dealCnt % 100 == 0 } { puts "$dealCnt" }
	accept
}

deal_finished {
	global dealCnt
	global northtricks
	global southtricks
	for {set i 0} {$i<14} {incr i} {
		puts "$i $northtricks($i)"
	}
	puts "Generated $dealCnt deals"
}
