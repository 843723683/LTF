#!/bin/bash

readonly COMMANDS="ls m4 mailx make man md5sum mkdir mkfifo mknod \
			mktemp more mount msgfmt mv newgrp nice nl nohup \
			od passwd paste patch pathchk pax pidof pr printf \
			ps pwd renice rm rmdir sed sendmail seq sh shutdown \
			sleep sort split string strip stty su sync tail tar \
			tee test time touch tr true tsort tty umount uname \
			unexpand uniq useradd userdel usermod wc xargs zcat "
ret=0
retStr=""

sum=0
for i in $COMMANDS
do
	let sum=sum+1
	which ${i} > /dev/null 2>&1
	[ $? -eq 0 ] && continue
	
	type ${i} > /dev/null 2>&1
	[ $? -eq 0 ] && continue
	
	ret=1
	retStr="${retStr} ${i}"

done

[ "Z$retStr" != "Z" ] && echo "No find command : $retStr"
echo "Total : $sum"
exit $ret
