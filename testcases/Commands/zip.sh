#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="zip"
TMPDIR="/var/tmp/dirTar"
TMPFILE="${TMPDIR}/test-zip"

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

[ -d "${TMPDIR}" ] && rm -rf ${TMPDIR}
mkdir $TMPDIR

cat > ${TMPFILE} <<EOF
test zip
EOF

zip -q /var/tmp/test-zip.zip $TMPDIR/*
[ $? -ne 0 ] && { echo "zip failed!";exit 1; }
rm -rf $TMPDIR

unzip -q /var/tmp/test-zip.zip -d /
[ $? -ne 0 ] && { echo "unzip failed!";exit 1; }

cat $TMPFILE | grep -q "test zip"
[ $? -ne 0 ] && exit 1

rm ${TMPDIR} -rf
rm /var/tmp/test-zip.zip -rf

exit 0
