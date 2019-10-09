#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="gcc"
TEST_FILE="/var/tmp/gcc-test.c"
TEST_EXE="/var/tmp/gcc-test"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "${CMD} :Command not found";exit 1; }

cat > ${TEST_FILE}<<EOF
#include <stdio.h>

int main(int argc,char *argv[]){
	printf("helloworld\n");
	return 0;
}

EOF

${CMD} -o ${TEST_EXE} ${TEST_FILE}

${TEST_EXE} | grep -q "helloworld" 
ret=$?

rm ${TEST_EXE}
rm ${TEST_FILE}

exit $ret
