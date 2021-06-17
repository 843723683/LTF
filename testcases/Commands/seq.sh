#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="seq"

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }

seq -s " " 5 | grep -q "1 2 3 4 5" && seq -s " " 6 8 | grep -q "6 7 8" && seq -s " " 8 2 12 | grep -q "8 10 12"

exit $?
