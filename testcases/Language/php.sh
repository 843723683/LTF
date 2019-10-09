#!/usr/bin/env bash
# Author : Lz <lz843723683@gmail.com>

CMD="php"
TEST_FILE="/var/tmp/php-test.php"
ret=1

echo "$0 test ${CMD}"

# 判断命令是否存在
which ${CMD} &>/dev/null
[ $? -ne 0 ] && { echo "${CMD} :Command not found";exit 1; }

cat > ${TEST_FILE} <<EOF
<?php
        echo("helloworld\n");
?>
EOF

${CMD} ${TEST_FILE} | grep -q "helloworld"
ret=$?

rm ${TEST_FILE}

exit $ret
