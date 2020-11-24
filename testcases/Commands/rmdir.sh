#!/usr/bin/env bash

#-----------------------------------------
#Filename:      rmdir.sh
#Version:       1.0
#Date:          2020/10/16
#Author:        HJQ
#Email:         hejiaqing@kylinos.com.cn
#History:
#               Version 1.0 2020/10/16
#Function:      验证命令rmdir能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="rmdir"
#测试中使用的命令
CMD_IMPORTANT="ls mkdir"
#测试结果返回 ： 0 => 成功 1=>失败
RET=1
#测试中使用的全局变量
TESTPATH="/var/tmp/${CMD}_test"


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
	#创建测试目录
	mkdir $TESTPATH
	#执行测试命令并判断是否成功
	$CMD $TESTPATH
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION CAN'T USE!";Command_Recycling;exit $RET; }
	#判断测试命令是否正确执行
	ls $TESTPATH &>/dev/null
	[ $? -eq 0 ] && { echo "ERROR:COMMAND FUNCTION FALSE!";Command_Recycling;exit $RET; }
	RET=0
}


## TODO： 回收资源
#
Command_Recycling(){
	if [ -d "${TESTPATH}" ];then
		rm -rf ${TESTPATH}
	fi
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
