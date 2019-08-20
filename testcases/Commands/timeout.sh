#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="timeout"

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

timeout 1 sleep 2
test $? -eq 124 && timeout 2 sleep 1

exit $?
