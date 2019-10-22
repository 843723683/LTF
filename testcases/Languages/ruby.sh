#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="ruby"
TEST_FILE="/var/tmp/ruby-test.rb"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "${CMD} :Command not found";exit 1; }

cat > ${TEST_FILE}<<EOF
#!/usr/bin/ruby
# Hello world ruby program
puts "helloworld";
EOF

${CMD} ${TEST_FILE} | grep -q "helloworld" 
ret=$?

rm ${TEST_FILE}

exit $ret
