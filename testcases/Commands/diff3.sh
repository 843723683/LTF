#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="diff3"
TESTFILE="/var/tmp/${CMD}-test"
ret=1
tmpStr=""

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }

cat > ${TESTFILE}a <<EOF
Check files are the same
EOF

cp ${TESTFILE}a ${TESTFILE}b
cp ${TESTFILE}a ${TESTFILE}c

tmpStr=$($CMD ${TESTFILE}a ${TESTFILE}b ${TESTFILE}c)
test -z "$tmpStr"
ret=$?


rm ${TESTFILE}a ${TESTFILE}b ${TESTFILE}c

exit $ret
