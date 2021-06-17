#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="find"
TEST_FILE="/var/tmp/find"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }

[ -e "${TEST_FILE}" ]&& rm -rf${TEST_FILE}

touch ${TEST_FILE}
$CMD ${TEST_FILE} &>/dev/null
ret=$?

rm ${TEST_FILE}

exit $ret
