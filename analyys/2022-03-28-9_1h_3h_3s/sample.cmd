./deal -i analyys/2022-03-28-9_1h_3h_3s/bidornot_KQ9753_3_42_A942.tcl 100

./deal -i analyys/2022-03-28-9_1h_3h_3s/bucketornot.tcl -W "KQ9753 3 42 A942" 100

cnt=1000; cat analyys/2022-03-28-9_1h_3h_3s/westInputs | while read west; do ./deal -i analyys/2022-03-28-9_1h_3h_3s/bucketornot.tcl -W "$west" $cnt; done | tee -a analyys/2022-03-28-9_1h_3h_3s/westResult$cnt | grep -v "Generated" | sort -k2