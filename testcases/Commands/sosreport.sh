#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="sosreport"
TMPFILENAME="ltfsosreport"
TMPPATHNAME="/tmp"
# 可能存在sosreport-localhost-${TMPFILENAME}的情况，所以加上"*"
TMPSOSPATH="${TMPPATHNAME}/sosreport-*${TMPFILENAME}"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }

# echo -e  "\n", 解决sosreport报错：EOFError:EOF when reading a lin
echo -e "\n" | ${CMD} --name=${TMPFILENAME} --tmp-dir=${TMPPATHNAME}
[ $? -ne 0 ]&&{ echo "Failed : ${CMD} --name=${TMPFILENAME} --tmp-dir=${TMPPATHNAME}";exit 1; }

# 判断文件是否存在
ls ${TMPSOSPATH}*
[ $? -ne 0 ] && exit 1

rm ${TMPSOSPATH}*

exit $?
