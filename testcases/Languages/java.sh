#!/usr/bin/env bash
# Author : Lz <lz843723683@gmail.com>

CMD_COMPILE="javac"
CMD_RUN="java"
TEST_EXE="javatest"
TEST_FILE="/var/tmp/${TEST_EXE}.java"
ret=1

echo "$0 test ${CMD_COMPILE} and ${CMD_RUN}"

# 判断命令是否存在
which ${CMD_COMPILE} &>/dev/null
[ $? -ne 0 ] && { echo "${CMD_COMPILE} :Command not found";exit 1; }
which ${CMD_RUN} &>/dev/null
[ $? -ne 0 ] && { echo "${CMD_RUN} :Command not found";exit 1; }

cat > ${TEST_FILE} <<EOF
public class javatest {
    public static void main(String[] args) {
        System.out.println("helloworld");
    }
}
EOF

cd ${TEST_FILE%/*}

${CMD_COMPILE} ${TEST_FILE##*/}
ret=$?
${CMD_RUN} -classpath . ${TEST_EXE} | grep -q "helloworld"
ret=$?

rm ${TEST_FILE%.*}*

cd - &>/dev/null

exit $ret
