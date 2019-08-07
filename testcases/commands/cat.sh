#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="cat"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

TEST_FILE="/var/tmp/cat-test"
cat > ${TEST_FILE} <<EOF
test cat command
EOF

grep -q "test cat command" ${TEST_FILE}
ret=$?

rm -rf ${TEST_FILE}

exit $ret
