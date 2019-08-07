#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="cut"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

echo "$0: test ${CMD}"
test $(echo "1 2 3" | cut -f 2 -d " ") -eq 2

exit $?
