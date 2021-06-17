#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="bzip2"
#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 2; }


# create file
FILE=/var/tmp/bzip2-test.txt

cat > $FILE <<EOF
bzip2-test of single file
EOF

# run file through bzip2
bzip2 $FILE
#just to make sure
rm -rf $FILE

#run file through bzcat
bzcat ${FILE}.bz2 | grep -q 'bzip2-test of single file'
if [ $? == 1 ]
  then
  echo 'bzcat failed'
  exit 1
fi

#run file through bunzip2
bunzip2 $FILE.bz2

#checking file contents
grep -q 'bzip2-test of single file' $FILE
ret=$?

#reversing changes
rm -rf $FILE*

exit $ret




