#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="g++"
TEST_FILE="`mktemp`"
TEST_EXE="`mktemp`"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "${CMD} :Command not found";exit 1; }

cat > ${TEST_FILE} <<EOF
#include <iostream>

int main(int argc, char** argv) {
        std::cout << "helloworld" << std::endl;
}

EOF

g++ -x c++ -o ${TEST_EXE} ${TEST_FILE}

${TEST_EXE} | grep -q "helloworld" 
ret=$?

rm ${TEST_EXE}
rm ${TEST_FILE}

exit $ret
