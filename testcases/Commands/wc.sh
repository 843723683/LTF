#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="wc"
TEST_FILE="/var/tmp/wc-test"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }

cat << EOF > /var/tmp/wc-test
1 2
3 4
5 6
EOF

# file should have 3 lines, 12 bytes, 12 characters, max line length of 3, and 6 words
wc -l /var/tmp/wc-test | grep -q 3 && wc -c /var/tmp/wc-test | grep -q 12 && wc -m /var/tmp/wc-test | grep -q 12 && wc -L /var/tmp/wc-test | grep -q 3 && wc -w /var/tmp/wc-test | grep -q 6

ret=$?

rm ${TEST_FILE}
exit $ret
