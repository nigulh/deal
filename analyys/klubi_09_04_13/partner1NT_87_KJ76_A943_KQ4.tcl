source lib/utility.tcl
source lib/ddscore.tcl

south is "87 KJ76 A943 KQ4"
set dealCnt 0
set 3NTCnt 0
set 4HCnt 0
set slamCnt 0
set heartCnt(8) 0
set heartCnt(9) 0
set heartCnt(10) 0
set heartCnt(11) 0
set heartCnt(12) 0
set heartCnt(13) 0
set notrumpCnt(8) 0
set notrumpCnt(9) 0
set notrumpCnt(10) 0
set notrumpCnt(11) 0
set notrumpCnt(12) 0
set notrumpCnt(13) 0

proc my_write_deal {  } {
	set line [list]
	set scores [list]
	foreach hand {north east west} {
		lappend line [join [$hand] "."]
	}
	set heartTricks [deal::tricks north hearts]
	set notrumpTricks [deal::tricks north notrump]
	lappend scores $notrumpTricks
	lappend scores $heartTricks
	global 3NTCnt 4HCnt slamCnt heartCnt notrumpCnt

	incr heartCnt($heartTricks)
	incr notrumpCnt($notrumpTricks)

	if { ($notrumpTricks >= $heartTricks) && ($notrumpTricks >= 9) } {incr 3NTCnt}
	if { ($notrumpTricks < $heartTricks) && ($heartTricks >= 10) } {incr 4HCnt}
	if { ($notrumpTricks >= 12) || ($heartTricks >= 12) } {incr slamCnt}

	puts "[join $line |]|[join $scores |]"
}

main {
	global dealCnt
	incr dealCnt
	if {![5CM_nt north 15 17]} {reject}
	if {([hearts north] < 4)} {reject}
	my_write_deal 
	accept
}

deal_finished {
	global dealCnt
	global heartCnt notrumpCnt slamCnt 3NTCnt 4HCnt
	puts "Total hearts  : $heartCnt(8) $heartCnt(9) $heartCnt(10) $heartCnt(11) $heartCnt(12) $heartCnt(13)"
	puts "Total notrumps: $notrumpCnt(8) $notrumpCnt(9) $notrumpCnt(10) $notrumpCnt(11) $notrumpCnt(12) $notrumpCnt(13)"
	puts "3NT good: $3NTCnt , 4H good: $4HCnt , slamgood: $slamCnt"
	puts "Generated $dealCnt deals"
}
