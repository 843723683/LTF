#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="tar"
TMPFILE="/var/tmp/test-tar"

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

cat > ${TMPFILE} <<EOF
test tar
EOF

tar -cf ${TMPFILE}.tar ${TMPFILE}  &>/dev/null
[ $? -ne 0 ] && { echo "tar -cvf failed!";exit 1; }
rm ${TMPFILE}

tar -xf ${TMPFILE}.tar -C / &&  grep -q 'test tar' ${TMPFILE}
[ $? -ne 0 ] && { echo "tar -xvf failed!";exit 1; }

rm ${TMPFILE}* -rf

exit 0
