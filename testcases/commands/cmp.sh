#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="cmp"
TESTFILE="/var/tmp/cmp-test"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

cat > ${TESTFILE}a <<EOF
This is some text to play with
EOF

cat > ${TESTFILE}b <<EOF
This is some test to play with
EOF

cmp ${TESTFILE}a ${TESTFILE}b | egrep -q  "第 16 字节，第 1 行|byte 16, line 1"
ret=$?


rm ${TESTFILE}a ${TESTFILE}b

exit $ret
