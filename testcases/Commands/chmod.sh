#!/usr/bin/env bash

#-----------------------------------------
#Filename:      chmod.sh
#Version:       1.0
#Date:          2020/09/22
#Author:        HJQ
#Email:         hejiaqing@kylinos.com.cn
#History:
#               Version 1.0 2020/09/22
#Function:      验证命令chmod能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="chmod"
#测试中使用的命令
CMD_IMPORTANT="ls cat"
#测试结果返回 ： 0 => 成功 1=>失败
RET=1
#测试中使用的全局变量
TESTFILE="/var/tmp/${CMD}_test"


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
	#创建测试文件
	cat >${TESTFILE}<<EOF
	test chmod command
EOF
	#修改测试文件的权限并判断是否成功
	${CMD} 777  ${TESTFILE}
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION CAN'T USE!";Command_Recycling;exit $RET; }
	#获取测试文件的权限并判断是否修改正确
	local ls_res=$(ls -l "${TESTFILE}")
	local permission=${ls_res%%.*}
	[ $permission != "-rwxrwxrwx" ] && { echo "ERROR:COMMAND FUNCTION ERROR!";Command_Recycling;exit $RET; }
	#加入参数并判断是否成功
	$CMD 766 -v ${TESTFILE} &>/dev/null && $CMD 755 -f ${TESTFILE}
	[ $? -ne 0 ] && { echo "ERROR:PARAMETERS CAN'T USE!";Command_Recycling;exit $RET; }
	RET=0
}


## TODO： 回收资源
#
Command_Recycling(){
	rm -rf $TESTFILE
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
