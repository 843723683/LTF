#!/usr/bin/env bash

#-----------------------------------------
#Filename:      ip.sh
#Version:       1.0
#Date:          2020/10/20
#Author:        HJQ
#Email:         hejiaqing@kylinos.com.cn
#History:
#               Version 1.0 2020/10/20
#Function:      验证命令ip能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="ip"
#测试中使用的命令
CMD_IMPORTANT="ls grep rm"
#测试结果返回 ： 0 => 成功 1=>失败
RET=1
#测试中使用的全局变量


## TODO： UI界面提示
#
Command_UI(){
	echo "$0 test ${CMD}"
}


## TODO： 判断命令是否存在
#   in ： $CMD => 测试命令
#         $CMD_IMPORTANT => 会用到的命令
#   Out： 0 => TPASS
#         1 => TFAIL
Command_isExist(){
	local command=""
	for command in "$@"
	do
		which $command >/dev/null 2>&1
		[ $? -ne 0 ] && { echo "ERROR:COMMAND $command NOT EXIST!";exit $RET; }
	done
}


## TODO： 判断命令功能能否使用
#   Out： 0 => TPASS
#         1 => TFAIL
Command_Function(){
	#执行测试命令并判断是否成功
	$CMD a &>/dev/null
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION CAN'T USE!";Command_Recycling;exit $RET; }
	#添加参数并判断是否执行成功
	$CMD addr list &>/dev/null
	[ $? -ne 0 ] && { echo "ERROR:PARAMETERS CAN'T USE!";Command_Recycling;exit $RET; }
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
