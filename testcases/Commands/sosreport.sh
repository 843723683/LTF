#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="sosreport"
TMPFILENAME="ltfsosreport"
TMPPATHNAME="/tmp"
TMPSOSPATH="${TMPPATHNAME}/sosreport-${TMPFILENAME}"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

echo "" | ${CMD} --name=${TMPFILENAME} --tmp-dir=${TMPPATHNAME}
[ $? -ne 0 ]&&{ echo "Failed : ${CMD} --name=${TMPFILENAME} --tmp-dir=${TMPPATHNAME}";exit 1; }

# 判断文件是否存在
ls ${TMPSOSPATH}*
[ $? -ne 0 ] && exit 1

rm ${TMPSOSPATH}*

exit $?
