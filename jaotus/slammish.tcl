# Let h be maxhcp(NS, EW)
# Accept 0%, if h = 10 (impossible, h>=20)
# ...
# Accept 50%, if h = 20
# Accept 60%, if h = 22
# ...
# Accept 100%, if h = 30 (or more)

main {
   set n [hcp north]
   set s [hcp south]
   set h [expr $n+$s]
   if {$h < 20} { set h [expr 40-$h] }
   set h [expr ($h-10.0)/20]
   set r [expr rand()]
   accept if {$h > $r}
   reject
}

