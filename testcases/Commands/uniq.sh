#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="uniq"
TEST_FILE="/var/tmp/uniq-test"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

cat > ${TEST_FILE} <<EOF
1
2
2
3
3
4
5
EOF

uniq -d ${TEST_FILE} | wc -l | grep -q "2" && uniq -u ${TEST_FILE}| wc -l | grep -q "3"
ret=$?

rm ${TEST_FILE}
exit $ret
