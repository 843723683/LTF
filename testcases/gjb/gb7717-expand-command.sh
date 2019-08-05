#!/bin/bash

readonly COMMANDS="alias bg command fc fg getopts hash jobs read type\
			ulimit umask unalias wait"

ret=0
retStr=""

sum=0
for i in $COMMANDS
do
	let sum=sum+1
        which ${i} > /dev/null 2>&1
        [ $? -eq 0 ] && continue
            
        type ${i} > /dev/null 2>&1
        [ $? -eq 0 ] && continue
            
        ret=1
        retStr="${retStr} ${i}"

done

[ "Z$retStr" != "Z" ] && echo "No find command : $retStr"
echo "Total : $sum"

exit $ret
