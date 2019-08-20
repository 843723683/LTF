#!/bin/bash
# Author : Lz <lz843723683@163.com>

CMD="useradd usermod userdel"
USERNAME="usertest"
echo "$0 test ${CMD}"

retFunc(){
	[ $1 -ne 0 ]&& { userdel -rf $usertest;exit $1; }	
}

useraddFunc(){
	echo "Useradd  ${USERNAME}"
	useradd ${USERNAME}
	return $?
}

usermodFunc(){
	echo "Usermod  ${USERNAME}"
	usermod -c "test usermod" ${USERNAME}
	grep  "${USERNAME}" /etc/passwd | grep -q "test usermod"
	return $?
}

userdelFunc(){
	echo "Userdel  ${USERNAME}"
	userdel -r ${USERNAME}
	return $?
}

main(){
	for i in ${CMD}
	do
		#判断命令是否存在
		which ${i} >/dev/null 2>&1
		[ $? -ne 0 ]&&{ echo "No command :${CMD}";exit 1; }
	
		${i}Func 
		retFunc $?
	done

	exit 0

}

main
