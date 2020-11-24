#!/usr/bin/env bash

#-----------------------------------------
#Filename:      rm.sh
#Version:       1.0
#Date:          2020/09/29
#Author:        HJQ
#Email:         hejiaqing@kylinos.com.cn
#History:
#               Version 1.0 2020/09/29
#Function:      验证命令rm能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="rm"
#测试中使用的命令
CMD_IMPORTANT="cat ls"
#测试结果返回 ： 0 => 成功 1=>失败
RET=1
#测试中使用的全局变量
TESTPATH="/var/tmp"
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
                [ $? -ne 0 ] && { echo "ERROR:COMMAND $command NOT EXIST!";exit $RET; }
        done
}


## TODO： 判断命令功能能否使用
#   Out： 0 => TPASS
#         1 => TFAIL
Command_Function(){
	#创建测试文件，删除测试文件并判断是否删除成功
	cat > $TESTFILE << EOF
	command $CMD test
EOF
	$CMD $TESTFILE
	ls $TESTFILE &>/dev/null
	[ $? -eq 0 ] && { echo "ERROR:COMMAND FUNCTION CAN'T USE!";Command_Recycling;exit $RET; }
	#创建测试文件，加入参数并判断是否删除成功
	cat > $TESTFILE << EOF
	command $CMD test
EOF
	$CMD -rf $TESTFILE
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
