#!/bin/bash
# Author : Lz <lz843723683@gmail.com>

CMD="go"
TEST_FILE="/var/tmp/go-test.go"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "${CMD} :Command not found";exit 1; }

cat > ${TEST_FILE}<<EOF
package main
import "fmt"
func main() {
    fmt.Println("hello world")
}
EOF

${CMD} run ${TEST_FILE} | grep -q "hello world" 
ret=$?

rm ${TEST_FILE}

exit $ret
