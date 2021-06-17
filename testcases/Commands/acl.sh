#!/usr/bin/env bash

#-----------------------------------------
#Filename:      acl.sh 
#Version:       1.0
#Date:          2021/06/17
#Author:        Lz
#Email:         liuzuo@kylinos.com.cn
#History:
#               Version 1.0 2021/06/17
#Function:      验证命令acl能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="setfacl"
#测试中使用的命令
CMD_IMPORTANT="getfacl"
#测试结果返回 ： 0 => 成功 1=>失败
RET=0
#测试中使用的全局变量
TESTPATH="/var/tmp"
TESTFILE="${TESTPATH}/ltf_command_acl"


## TODO： UI界面提示
#
Command_UI(){
        echo "$0 test ${CMD}"
}


## TODO： 判断命令是否存在
#   in ： $1 => 测试命令
#         $2 => 会用到的命令
#   Out： 0 => TPASS
#         1 => TFAIL
Command_isExist(){
        local command=""
        for command in "$@"
        do
                which $command >/dev/null 2>&1
                [ $? -ne 0 ] && { echo "ERROR:Command $command not exist!";exit 2; }
        done
}


## TODO: 初始化
Command_init(){
	if [ -f "${TESTFILE}" ];then
		rm -rf ${TESTFILE}
	fi
	touch ${TESTFILE}
}


## TODO： 设置和获取acl
#   Out： 0 => TPASS
#         1 => TFAIL
Command_Function1(){
	setfacl -m user:nobody:r-- ${TESTFILE}
	[ $? -ne 0 ] && { echo "ERROR: setfacl -m user:nobody:r-- ${TESTFILE}";Command_Recycling;exit 1; }

	getfacl -p ${TESTFILE} | grep -q 'user:nobody:r--'
	[ $? -ne 0 ] && { echo "ERROR: getfacl ${TESTFILE} | grep -q 'user:nobody:r--'";Command_Recycling;exit 1; }
}


## TODO： 回收资源
#
Command_Recycling(){
	if [ -f "${TESTFILE}" ];then
		rm -rf ${TESTFILE}
	fi
}


## TODO： Main
#
Command_Main(){
        Command_UI
        Command_init
        Command_isExist $CMD $CMD_IMPORTANT
        Command_Function1
        Command_Recycling
}


Command_Main
exit $RET
