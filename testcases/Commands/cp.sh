#!/usr/bin/env bash

#-----------------------------------------
#Filename:      cp.sh
#Version:       1.0
#Date:          2020/09/21
#Author:        HJQ
#Email:         hejiaqing@kylinos.com.cn
#History:
#               Version 1.0 2020/09/21
#Function:      验证命令cp能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="cp"
#测试中使用的命令
CMD_IMPORTANT="cat ls diff"
#测试结果返回 ： 0 => 成功 1=>失败
RET=1
#测试中使用的全局变量
TESTFILE="/var/tmp/${CMD}_test"


## TODO： UI界面提示
#
Command_UI(){
	echo "$0 test $CMD"
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
	#创建一个测试文件
	cat>${TESTFILE}<<EOF
	test cp command
EOF
	#复制测试文件并判断是否复制成功
	$CMD ${TESTFILE} ${TESTFILE}_backup
	ls ${TESTFILE}_backup &>/dev/null
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION CAN'T USE!";Command_Recycling;exit $RET; }
	#判断复制是否出错并更新标志位
	diff ${TESTFILE} ${TESTFILE}_backup
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION ERROR!";Command_Recycling;exit $RET; }
	#加入参数并判断是否成功
	$CMD -f ${TESTFILE} ${TESTFILE}_backup && $CMD -p ${TESTFILE} ${TESTFILE}_bkup
	[ $? -ne 0 ] && { echo "ERROR:COMMAND PARAMETER ERROR!";Command_Recycling;exit $RET; }
	RET=0
}


## TODO： 回收资源
#
Command_Recycling(){
	rm -rf ${TESTFILE} ${TESTFILE}_backup ${TESTFILE}_bkup &>/dev/null
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
