#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="gzip"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }


# create file
FILE=/var/tmp/gzip-test.txt

cat > $FILE <<EOF
gzip-test of single file
EOF

$CMD $FILE
if [ $? -ne 0 ]
  then
  echo 'gzip failed'
  exit 1
fi

#run file through bzcat
gunzip ${FILE}.gz && cat ${FILE}  | grep -q 'gzip-test of single file'
if [ $? -ne 0 ]
  then
  echo 'gunzip failed'
  exit 1
fi

rm -rf $FILE*

exit 0




