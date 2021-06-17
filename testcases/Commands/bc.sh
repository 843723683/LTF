#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="bc"

#判断命令是否存在
${CMD} --version >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }


test `echo "5 + 6 * 5 / 10 - 1" | bc` -eq "7"
[ $? -ne 0 ]&&{ echo "Fail :5 + 6 * 5 / 10 - 1";exit 1; }

exit 0



