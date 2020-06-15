#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="clisp"
TEST_FILE="/var/tmp/clisp-test.lisp"
TEST_FILE_FAS="/var/tmp/clisp-test.fas"
TEST_FILE_LIB="/var/tmp/clisp-test.lib"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "${CMD} :Command not found";exit 1; }

cat > ${TEST_FILE}<<EOF
(
   format t "helloworld"
)

EOF

${CMD} -c ${TEST_FILE}

${CMD} ${TEST_FILE_FAS} | grep -q "helloworld" 
ret=$?

rm ${TEST_FILE}
rm ${TEST_FILE_FAS}
rm ${TEST_FILE_LIB}

exit $ret
