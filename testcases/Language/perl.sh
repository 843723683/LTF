#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="perl"
TEST_FILE="/var/tmp/perl-test.pl"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

cat > ${TEST_FILE}<<EOF
print "helloworld"
EOF

perl ${TEST_FILE} | grep -q "helloworld" 
ret=$?

rm ${TEST_FILE}

exit $ret
