#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="sosreport"
TMPFILENAME="ltfsosreport"
TMPSOSPATH="/var/tmp/sosreport-${TMPFILENAME}"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

echo "" | ${CMD} --name=${TMPFILENAME}
[ $? -ne 0 ]&&{ echo "Failed : ${CMD} --name=${TMPFILENAME}";exit 1; }

# 判断文件是否存在
ls ${TMPSOSPATH}*
ret=$?

rm ${TMPSOSPATH}*

exit $?
