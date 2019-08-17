#!/bin/bash

CMD="tclsh"
FILE="/var/tmp/test-tcl"
ret=1

which ${CMD}
[ $? -ne 0 ] && { echo "Not command ${CMD}!";exit 1; }

cat > $FILE <<EOF
puts "helloworld tclpackage"
EOF

tclsh $FILE | grep -q "helloworld tclpackage"
ret=$?

rm $FILE

exit $ret

