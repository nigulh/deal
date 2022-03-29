#/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ls -tr $DIR/../data | tail -1 | xargs -I {} cat $DIR/../data/{}
