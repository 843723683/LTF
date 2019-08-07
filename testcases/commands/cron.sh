#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="run-parts"
TEST_FILE="/etc/cron.hourly/test.sh \
		/etc/cron.daily/test.sh \
		/etc/cron.weekly/test.sh"
ret=1

echo "$0 test ${CMD}"

#判断命令是否存在
which ${CMD} >/dev/null 2>&1 
[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }

for i in ${TEST_FILE}
do

cat > ${i}<<EOF
#!/bin/bash
echo 'test'
EOF
	
	chmod a+x $i >/dev/null	

	run-parts $(dirname $i) | grep -q "test"
	ret=$?
	rm ${i}

	[ $ret -ne 0 ]&& exit $ret

done

exit $ret
