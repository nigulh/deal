source lib/score.tcl

# Return score based on double-dummy play
# So might say
# % ddscore "2 spades doubled" south vul
proc ddscore { contract declarer vulword } {
	set denom [lindex $contract 1]
	return [score $contract $vulword [deal::tricks $declarer $denom]]
}
