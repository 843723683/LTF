#!/bin/bash

CMD="tclsh"
FILE="/var/tmp/test-tcl"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} &>/dev/null
[ $? -ne 0 ] && { echo "${CMD} :Command not found";exit 1; }

cat > $FILE <<EOF
puts "helloworld tclpackage"
EOF

${CMD} $FILE | grep -q "helloworld tclpackage"
ret=$?

rm $FILE

exit $ret

