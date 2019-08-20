#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="false"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }


echo "$0 test ${CMD}"
false
[ $? -eq 1 ]

exit $?
