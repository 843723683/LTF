#!/usr/bin/env bash

#-----------------------------------------
#Filename:      useradd.sh
#Version:       1.0
#Date:          2020/09/19
#Author:        HJQ
#Email:         hejiaqing@kylinos.com.cn
#History:
#               Version 1.0 2020/09/19
#Function:      验证命令useradd能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="useradd"
#测试中使用的命令
CMD_IMPORTANT="userdel cat grep"
#测试结果返回 ： 0 => 成功 1=>失败
RET=1
#测试中使用的全局变量
TESTUSER="ltf_$RANDOM"


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
	#添加用户
	useradd $TESTUSER &>/dev/null
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION CAN'T USE!";Command_Recycling;exit $RET; }
	#判断用户是否添加成功
	local etc_passwd_res=$(cat /etc/passwd|grep "$TESTUSER")
	local username=${etc_passwd_res%%:*}
	[ ${username} != $TESTUSER ] && { echo "ERROR:COMMAND FUNCTION ERROR!";Command_Recycling;exit $RET; }
	#标志位更新为成功
	RET=0
}


## TODO： 回收资源
#
Command_Recycling(){
	userdel -rf $TESTUSER &>/dev/null
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
