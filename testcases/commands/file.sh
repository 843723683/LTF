#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="file"
TEST_FILE="/var/tmp/file-test"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

cat >${TEST_FILE} <<EOF
#!/bin/bash
EOF

file ${TEST_FILE} | grep -q "shell script"
ret=$?

rm ${TEST_FILE}

exit $ret
