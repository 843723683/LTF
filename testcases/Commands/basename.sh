#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="basename"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }


echo "$0 testing ${basename}"

echo $0
basename $0 | grep -q basename.sh || exit 1
basename /etc/hosts | grep -q hosts

exit $?
