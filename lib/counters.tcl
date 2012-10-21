## These provides counters for statistics
##
## global variables
##	tab - database
##	cellWidth
##	numberPrecision
##
## global methods
## 	init
## 	increment
##	output
##

proc isStatHeader { header } {
	switch $header {
		sum { return true }
		avg { return true }
		sdev { return true }
	}
	return false
}

proc init0d { dbVar var } {
	upvar 1 $dbVar db
	dict set db $var data 0
}

proc init1d { dbVar var rows } {
	upvar 1 $dbVar db
	dict set db $var rows $rows
	foreach row $rows {
		if { [isStatHeader $row] } {
			sdev $var,avg,
		} else {
			dict set db $var data $row, 0
		}
	}
	
}

proc init2d { dbVar var rows cols } {
	upvar 1 $dbVar db
	dict set db $var rows $rows
	dict set db $var cols $cols
	foreach row $rows { foreach col $cols {
		if { [isStatHeader $row] } {
			sdev $var,avg,$col
			sdev $var,avg,sum
		} elseif { [isStatHeader $col] } {
			sdev $var,$row,avg
			sdev $var,sum,avg
		} else {
			dict set db $var data $row,$col 0
		}
	} }
}

proc init { var desc args } {
	global tab
	dict set tab $var desc $desc
	dict set tab $var var $var
	dict set tab $var dim [llength $args]
	switch [llength $args] {
		0 { init0d tab $var }
		1 { init1d tab $var [lindex $args 0] }
		2 { init2d tab $var [lindex $args 0] [lindex $args 1] }
	}
}



proc incr0d { dbVar var } {
	upvar 1 $dbVar db
	dict set db $var data [ expr [dict get $db $var data] + 1]
}

proc incr1d { dbVar var row } {
	upvar 1 $dbVar db
	
	dict set db $var data $row, [ expr [dict get $db $var data $row,] + 1]
	catch {$var,avg, add $row}
}

proc incr2d { dbVar var row col } {
	upvar 1 $dbVar db
	catch {dict set db $var data $row,$col [ expr [ dict get $db $var data $row,$col ] + 1]}
	catch {$var,$row,avg add $col}
	catch {$var,avg,$col add $row}
	catch {$var,sum,avg add $col}
	catch {$var,avg,sum add $row}
}

proc increment { var args } {
	global tab
	set dim [dict get $tab $var dim]
	if { $dim != [llength $args]} {
		return -code error "Variable $var is {$d}d, got $args"
	}
	if { [llength $args] == 0 } {
		incr0d tab $var
	} elseif { [llength $args] == 1 } {
		incr1d tab $var [lindex $args 0]
	} elseif { [llength $args] == 2 } {
		incr2d tab $var [lindex $args 0] [lindex $args 1]
	}
}



proc getStat { stat type minCount } {
	if { [ $stat count ] < $minCount } { return 0 }
	return [ $stat $type ]
}

proc getOutputData { elem row col } {
	if { $row == "." && $col == "."} { return "" }
	if { $row == "."} { return $col }
	if { $col == "."} { return $row }
	if { ![isStatHeader $row] && ![isStatHeader $col] } { 
		set ret [normalizeCount [ dict get $elem data $row,$col ]]
	} else {
		set var [dict get $elem var]
		if { $row == "sum" && $col == "avg" } { set ret [ getStat $var,sum,avg average 1 ] 
		} elseif { $row == "sum" && $col == "sdev" } { set ret [ getStat $var,sum,avg sdev 2 ] 
		} elseif { $row == "avg" && $col == "sum" } { set ret [ getStat $var,avg,sum average 1 ] 
		} elseif { $row == "sdev" && $col == "sum" } { set ret [ getStat $var,avg,sum sdev 2 ] 
		} elseif { [isStatHeader $row] && [isStatHeader $col] } { return "" 
		# Now there is only one statistical row/col
		} elseif { $row == "sum" } { set ret [ normalizeCount [ $var,avg,$col count ]]
		} elseif { $row == "avg" } { set ret [ getStat $var,avg,$col average 1 ] 
		} elseif { $row == "sdev" } { set ret [ getStat $var,avg,$col sdev 2 ] 
		} elseif { $col == "sum" } { set ret [ normalizeCount [ $var,$row,avg count ]] 
		} elseif { $col == "avg" } { set ret [ getStat $var,$row,avg average 1] 
		} elseif { $col == "sdev" } { set ret [ getStat $var,$row,avg sdev 2 ] 
		} else { return "??" }
	}
	return [ formatNumber $ret ]
}



proc output0d {elem} {
	puts "[dict get $elem desc]: [formatNumber [normalizeCount [dict get $elem data]]]"
}

proc output1d {elem} {
	puts "[dict get $elem desc]:"
	set data [dict get $elem data]
	set showAsRow true
	if { !$showAsRow } {
		foreach row [dict get $elem rows] {
			set data [getOutputData $elem $row ""]
			puts "[formatCell $row] [formatCell $data]"
		}
	} else {
		foreach row [dict get $elem rows] {
			puts -nonewline "[formatCell $row]"
		}
		puts ""
		foreach row [dict get $elem rows] {
			set data [getOutputData $elem $row ""]
			puts -nonewline "[formatCell $data]"
		}
		puts ""
	}
}

proc output2d {elem} {
	puts -nonewline [formatCell [dict get $elem desc] 30 ]
	foreach row [dict get $elem rows] {
		foreach col [dict get $elem cols] {
			set data [getOutputData $elem $row $col]
			if { $col == "." } { if { $row == "."} { set width 30 } else { set width 32 } } else { set width -1 }
			puts -nonewline [formatCell $data $width]
		}
		puts ""
	}
	
}

proc outputdb { } {
	global tab
	foreach key [dict keys $tab] {
		set val [ dict get $tab $key ]
		set dim [ dict get $val dim ]
		switch $dim {
			0 { output0d $val }
			1 { output1d $val }
			2 { output2d $val }
		}
	}
}

set cellWidth 6
set numberPrecision 3

proc formatNumber {data {precision -1}} {
	global numberPrecision
	if { $precision == -1 } { set precision $numberPrecision }
	if { $data == 0 } { return "." } else {
		return [ string trimleft [ format "%-.*g" $precision $data ] 0 ]
	}
}

proc formatCell {data {width -1} } {
	global cellWidth
	if { $width == -1 } { set width $cellWidth }
	return [format "%-*s " $width $data]
}
