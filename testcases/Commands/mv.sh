#!/usr/bin/env bash

#-----------------------------------------
#Filename:      mv.sh
#Version:       1.0
#Date:          2020/10/09
#Author:        HJQ
#Email:         hejiaqing@kylinos.com.cn
#History:
#               Version 1.0 2020/10/09
#Function:      验证命令mv能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="mv"
#测试中使用的命令
CMD_IMPORTANT="ls cat rm"
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
#   in ： $CMD => 测试命令
#	  $CMD_IMPORTANT => 会用到的命令
#   Out： 0 => TPASS
#	  1 => TFAIL
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
        #添加测试文件
	cat > $TESTFILE << EOF
	command mv test
EOF
	#移动测试文件并判断是否执行成功
	$CMD $TESTFILE ${TESTFILE}_mv
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION CAN'T USE!";Command_Recycling;exit $RET; }
	#判断命令是否生效
	ls ${TESTFILE}_mv &>/dev/null
	[ $? -ne 0 ] && { echo "ERROR:COMMAND FUNCTION ERROR!";Command_Recycling;exit $RET; }
	#使用参数，判断是否执行成功
	$CMD -uf ${TESTFILE}_mv ${TESTFILE}_mv_test
	[ $? -ne 0 ] && { echo "ERROR:PARAMETERS CAN'T USE!";Command_Recycling;exit $RET; }
	#标志位更新为成功
	RET=0
}


## TODO： 回收资源
#
Command_Recycling(){
        rm -rf ${TESTFILE}_mv_test &>/dev/null
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
