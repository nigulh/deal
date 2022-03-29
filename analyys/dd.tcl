source format/compact

#east is "Q853 AJ962 T74 K"
#south is "AJ962 T74 K Q853"
#west is "T74 K Q853 AJ962"
#north is "K Q853 AJ962 T74"

main {
	set tricks [deal::tricks south notrump]
	puts "$tricks"
        accept
}
