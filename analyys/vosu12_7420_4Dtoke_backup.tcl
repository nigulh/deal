source lib/utility.tcl
source lib/ddscore.tcl

south is "82 9754 K986532 -"

array set tab {}
set rows [list . 0 1 2 3 4 5 6 7 8 9 10 11 12 13 s]
set cols [list . 0 1 2 3 4 5 6 7 8 9 10 11 12 13 s]

foreach row $rows { foreach col $cols { set tab($row,$col) 0 } }
foreach row $rows { set tab($row,.) $row }
foreach col $cols { set tab(.,$col) $col }

sdev diams
set diamondgame 0
set heartgame 0
set diamondtricks 0
set hearttricks 0
proc analyze { } {
	global tab
	global diamondgame heartgame diamondtricks hearttricks
	global diams
	
	set dtr [deal::tricks south diamonds]
	set htr [deal::tricks south hearts]
	foreach row [list s $dtr] { foreach col [list s $htr] { incr tab($row,$col) } }
	if { $dtr >= 11 } { incr diamondgame }
	if { $htr >= 10 } { incr heartgame }
	set diamondtricks [ expr $diamondtricks + $dtr ]
	set hearttricks [ expr $hearttricks + $htr ]
	diams add $dtr
}	

main {
	global dealCnt
	if { [hcp east] < 16 } { reject }
	
	incr dealCnt
	analyze
	if { $dealCnt % 1000 == 0 } { puts "$dealCnt" }
	accept
}

proc formatcell {arg} {
	if { $arg == 0 } { return "." } else {
		return [ string trimleft [ format "%-.3g" $arg ] 0 ]
	}
}

deal_finished {
	global dealCnt
	global tab
	global diamondgame heartgame diamondtricks hearttricks diams
	
	set width 6
	puts "SŸdis on 82 9754 K986532 -"
	puts "Ostil on 16+"
	puts "Kas ost peaks nŠitama Šrtut v›i pakkuma ruutut nagu jaksab?"
	puts "Veergudes: Šrtutihide arv, Tulpades ruututihide arv, sisu: toensus"
	foreach row $rows {
		foreach col $cols {
			set v $tab($row,$col)
			if { $row != "." && $col != "." } {
				set v [formatcell [expr 100.0 * $v / $dealCnt]]
			}
			puts -nonewline [format "%-*s " $width $v]
		}
		puts ""
	}
	puts "Generated $dealCnt deals"
	puts "Diamond game: $diamondgame, average [expr 1.0 * $diamondtricks / $dealCnt] tricks"
	puts "Heart game: $heartgame, average [expr 1.0 * $hearttricks / $dealCnt] tricks"
	puts "[diams count] [diams average] [diams sdev]"
	
}
