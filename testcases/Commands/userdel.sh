#!/usr/bin/env bash

#-----------------------------------------
#Filename:      userdel.sh
#Version:       1.0
#Date:          2020/09/29
#Author:        HJQ
#Email:         hejiaqing@kylinos.com.cn
#History:
#               Version 1.0 2020/09/29
#Function:      验证命令userdel能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="userdel"
#测试中使用的命令
CMD_IMPORTANT="useradd"
#测试结果返回 ： 0 => 成功 1=>失败
RET=1
#测试中使用的全局变量
TESTUSER=""


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
		[ $? -ne 0 ] && { echo "ERROR:COMMAND $command  NOT EXIST!";exit $RET; }
	done
}


## TODO： 判断命令功能能否使用
#   Out： 0 => TPASS
#         1 => TFAIL
Command_Function(){
	#添加测试用户
	TESTUSER="ltf_$RANDOM"
	#删除测试用户并判断是否删除成功
	useradd $TESTUSER &>/dev/null
	userdel $TESTUSER &>/dev/null
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION CAN'T USE!";exit 2; }
	#添加测试用户并使用参数删除，判断是否执行成功
	useradd $TESTUSER &>/dev/null
	userdel -rf $TESTUSER &>/dev/null
	[ $? -ne 0 ] && { echo "ERROR:PARAMETERS CAN'T USE!";exit $RET; }
	#标志位更新为成功
	RET=0
}


## TODO： 回收资源
#
Command_Recycling(){
	true
}

## TODO： Main
#
Command_Main(){
	Command_UI
	Command_isExist $CMD $CMD_IMPORTANT
	Command_Function
	Command_Recycling
}


Command_Main
exit $RET
