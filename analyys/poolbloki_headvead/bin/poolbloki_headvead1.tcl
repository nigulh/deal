source lib/utility.tcl
source lib/ddscore.tcl
source lib/counters.tcl
source format/count


#south is "82 9754 K986532 -"

set cellWidth 6
set numberPrecision 3

proc normalizeCount { count } {
	global dealCnt
	if {[string is integer -strict $count]} {
		return [expr 100.0 * $count / $dealCnt]
	}
	return $count
}


proc write_deal {} {
	global dealCnt
	if {$dealCnt == 1} {
		puts "[south]"
	}
}

puts "Proovime analŸŸsida, kui efektiivne on t›kestamine 2S"
puts "S10: padas on 10 tihi"
puts "911, NO, H10, D10, C10: padas pole 10 tihi"
puts "911: trumbitas on 9 tihi, voi C/D/H on 11 tihi"
puts "NO, H10, D10, C10: Ÿheski mastis pole 11 tihi, ega trumbitas 9 tihi"
puts "NO: yheski mastis pole 10 tihi"
puts "H10, D10, C10: selles mastis on 10 tihi (siin v6ib yhte jagu lugeda topelt)"
puts "H>S, D>S, C>S: selles mastis on rohkem tihisid, kui padas (v6ib lugeda topelt)"
init g "Dealeriks on syd voi west\n. Geimi voitmise t6enaosus" [ list . south west ] [ list . S10 911 H10 D10 C10 NO H>S D>S C>S cards]
init str "Sydi tihide saamise toensus" [ list . c d h s nt ] [list . 0 1 2 3 4 5 6 7 8 9 10 11 12 13 avg sdev ]
init wtr "Westi tihide saamise toensus" [ list . c d h s nt ] [list . 0 1 2 3 4 5 6 7 8 9 10 11 12 13 avg sdev ]

proc analyze { } {
	foreach dealer [list south west] {
		global tab
		set nt [deal::tricks $dealer nt]
		set st [deal::tricks $dealer spades]
		set ht [deal::tricks $dealer hearts]
		set dt [deal::tricks $dealer diamonds]
		set ct [deal::tricks $dealer clubs]
		
		if {$st >= 10} {
			increment g $dealer S10
		} else {
			if { $nt >= 9 || $ht >= 11 || $dt >= 11 || $ct >= 11 } {
				increment g $dealer 911
			} else {
				if { $ht == 10 } { increment g $dealer H10 }
				if { $dt == 10 } { increment g $dealer D10 }
				if { $ct == 10 } { increment g $dealer C10 }
			}
			if { $ht < 10 && $dt < 10 && $ct < 10 } {
				increment g $dealer NO
			}
		}
		
		if { $ht > $st } { increment g $dealer H>S }
		if { $dt > $st } { increment g $dealer D>S }
		if { $ct > $st } { increment g $dealer C>S }
		#dict set tab g data $dealer,cards "[south spades]"
		
		set tb wtr
		if {$dealer == "south" } {
			set tb str 
		}
		increment $tb c $ct
		increment $tb d $dt
		increment $tb h $ht
		increment $tb s $st
		increment $tb nt $nt
		
		#increment hcp [hcp north]
		#hcp,avg, add [hcp north]
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
	global dealCnt tab
	
	outputdb $tab
	puts "Generated $dealCnt deals"
	
	#puts $tab
}


