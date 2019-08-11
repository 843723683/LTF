#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="passwd"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

userdel -rf passtest &>/dev/null
useradd passtest  &>/dev/null
echo passtest | passwd --stdin passtest &>/dev/null

ret=$?
userdel -rf passtest &>/dev/null

exit $?
