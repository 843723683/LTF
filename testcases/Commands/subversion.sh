#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="svn"

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }

${CMD} --version &>/dev/null

exit $?
