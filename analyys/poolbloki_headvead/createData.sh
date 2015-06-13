#!/bin/bash

dealCount=2
if [ "$#" -ge 1 ]; then dealCount=$1; fi
comboCount=5
if [ "$#" -ge 2 ]; then comboCount=$2; fi
otherComboCount=3
if [ "$#" -ge 3 ]; then otherComboCount=$3; fi
path="analyys/poolbloki_headvead"
datafile="data/data_"$dealCount"_"$(date +"%Y%m%d_%H%M%S")

generateHands() {
    args="$@"
    >&2 echo "Running $args"
   ./deal -i $path/bin/poolbloki_headvead.tcl -S "$args" $dealCount 2> /dev/null | awk '(NR == 1) {print $0, "Cnt";} (NR != 1 && $0 != "") {print $0, '$dealCount';}'
}
export -f generateHands
export dealCount
export path

echo $path/$datafile

python $path/bin/balancedshuffle.py $comboCount $otherComboCount | xargs -I {}  bash -c "generateHands {}" | awk '(NR == 1) {header = $0; print; } ($0 != header)' > $path/$datafile

cat $path/$datafile | r -q --vanilla -f $path/bin/sample.R
cat $path/$datafile | r -q --vanilla -e 'source("'$path/bin/sample.R'")'


