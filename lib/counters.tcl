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
		sum -
		avg -
		sdev { return 1 }
                default { return 0 }
	}
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
                        dict set db $var withRowStats 1
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
                        dict set db $var withRowStats 1
		} elseif { [isStatHeader $col] } {
			sdev $var,$row,avg
			sdev $var,sum,avg
                        dict set db $var withColumnStats 1
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
        dict set tab $var withRowStats 0
        dict set tab $var withColumnStats 0
	dict set tab $var totalCnt 0
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
	catch {dict set db $var data $row, [ expr [dict get $db $var data $row,] + 1]}
	if {[dict get $db $var withRowStats]} {catch {$var,avg, add $row}}
        dict set db $var totalCnt [ expr [dict get $db $var totalCnt] + 1]
}

proc incr2d { dbVar var row col } {
	upvar 1 $dbVar db
	catch {dict set db $var data $row,$col [ expr [ dict get $db $var data $row,$col ] + 1]}
        if {[dict get $db $var withColumnStats]} {
            catch {$var,$row,avg add $col}
            catch {$var,sum,avg add $col}
        }
        if {[dict get $db $var withRowStats]} {
            catch {$var,avg,$col add $row}
            catch {$var,avg,sum add $row}
        }   
        dict set db $var totalCnt [ expr [dict get $db $var totalCnt] + 1]
}

proc increment { var args } {
	global tab
	set dim [dict get $tab $var dim]
	if { $dim != [llength $args]} {
		return -code error "Variable $var is {$d}d, got $args"
	}
        switch [llength $args] {
	    0 { incr0d tab $var } 
            1 { incr1d tab $var [lindex $args 0] } 
            2 { incr2d tab $var [lindex $args 0] [lindex $args 1] }
        }
}



proc getStat { stat type minCount } {
	if { [ $stat count ] < $minCount } { return 0 }
	return [ $stat $type ]
}

proc normalizeCount { count totalCnt } {
	if {[string is integer -strict $count]} {
		return [expr 100.0 * $count / $totalCnt]
	}
	return $count
}

proc getOutputData { elem row col statsFlags } {
        set dataKey "[isStatHeader $row][isStatHeader $col],$row,$col"
        switch -glob $dataKey {
            *,.,. { return "" }
            *,.,* { return $col }
            *,*,. { return $row }
        }
	set var [dict get $elem var]
        switch $statsFlags {
            00 { set totalCnt 100 }
            10 { set totalCnt [$var,avg,$col count] }
            01 { set totalCnt [$var,$row,avg count] }
            11 { set totalCnt [dict get $elem totalCnt] }
        }
        
        switch -glob $dataKey {
            00,* { set ret [normalizeCount [ dict get $elem data $row,$col ] $totalCnt] } 
            11,sum,avg { set ret [ getStat $var,sum,avg average 1 ] }
            11,sum,sdev { set ret [ getStat $var,sum,avg sdev 2 ] }
            11,avg,sum { set ret [ getStat $var,avg,sum average 1 ] } 
            11,sdev,sum { set ret [ getStat $var,avg,sum sdev 2 ] } 
            11,* { return "" }
            10,sum,* { set ret [ normalizeCount [ $var,avg,$col count ] $totalCnt] } 
            10,avg,* { set ret [ getStat $var,avg,$col average 1 ] } 
            10,sdev,* { set ret [ getStat $var,avg,$col sdev 2 ] } 
            01,*,sum { set ret [ normalizeCount [ $var,$row,avg count ] $totalCnt] } 
            01,*,avg { set ret [ getStat $var,$row,avg average 1] } 
            01,*,sdev { set ret [ getStat $var,$row,avg sdev 2 ] } 
            default { return "??" }
        }
	return [ formatNumber $ret ]
}


proc output0d {elem} {
	puts "[dict get $elem desc]: [formatNumber [dict get $elem data]]"
}

proc output1d {elem} {
	puts "[dict get $elem desc]:"
	set data [dict get $elem data]
	set showAsRow true
        set statsFlags "[dict get $elem withRowStats][dict get $elem withColumnStats]"
	if { !$showAsRow } {
		foreach row [dict get $elem rows] {
			set data [getOutputData $elem $row "" $statsFlags]
			puts "[formatCell $row] [formatCell $data]"
		}
	} else {
		foreach row [dict get $elem rows] {
			puts -nonewline "[formatCell $row]"
		}
		puts ""
		foreach row [dict get $elem rows] {
			set data [getOutputData $elem $row "" $statsFlags]
			puts -nonewline "[formatCell $data]"
		}
		puts ""
	}
}

proc output2d {elem} {
	global firstCellWidth
	set isFirst true
        set statsFlags "[dict get $elem withRowStats][dict get $elem withColumnStats]"
	foreach desc [split [dict get $elem desc] "\n"] {
		if {!$isFirst} {puts ""}
		puts -nonewline [formatCell $desc $firstCellWidth]
		set isFirst false
	}
	foreach row [dict get $elem rows] {
		foreach col [dict get $elem cols] {
			set data [getOutputData $elem $row $col $statsFlags]
			if { $col == "." && $row == "." } { continue }
			if { $col == "." } { set width $firstCellWidth } else { set width -1 }
			puts -nonewline [formatCell $data $width]
		}
		puts ""
	}
	puts ""
}

proc output {key} {
	global tab
        set elem [ dict get $tab $key ]
        set dim [ dict get $elem dim ]
        switch $dim {
            0 { output0d $elem }
            1 { output1d $elem }
            2 { output2d $elem }
        }
}

proc outputdb { } {
	global tab
	foreach key [dict keys $tab] {
            output $key 
	}
}

set cellWidth 6
set numberPrecision 3
set firstCellWidth 30

proc formatNumber {data {precision -1}} {
	global numberPrecision
	if { $precision == -1 } { set precision $numberPrecision }
	if { $data == 0 } { return "0" } else {
		return [ string trimleft [ format "%-.*g" $precision $data ] 0 ]
	}
}

proc formatCell {data {width -1} } {
	global cellWidth
	if { $width == -1 } { set width $cellWidth }
	return [format "%-*s " $width $data]
}
