#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="touch"
TEST_FILE="/var/tmp/touch-test"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }

touch "${TEST_FILE}"
ls ${TEST_FILE} > /dev/null 2>&1
ret=$?

rm ${TEST_FILE}
exit $ret
