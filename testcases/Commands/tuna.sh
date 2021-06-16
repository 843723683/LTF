#!/usr/bin/env bash

#-----------------------------------------
#Filename:      tuna.sh 
#Version:       1.0
#Date:          2021/06/15
#Author:        Lz
#Email:         liuzuo@kylinos.com.cn
#History:
#               Version 1.0 2021/06/15
#Function:      验证命令ls能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------


#测试的命令
CMD="tuna"
#测试中使用的命令
CMD_IMPORTANT="ps"
#测试结果返回 ： 0 => 成功 1=>失败
RET=0
#测试中使用的全局变量
TESTPATH="/var/tmp"


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
                [ $? -ne 0 ] && { echo "ERROR:Command $command not exist!";exit $RET; }
        done
}


## TODO：显示线程信息列表 
#   Out： 0 => TPASS
#         1 => TFAIL
Command_Function1(){
	# 显示线程信息列表
	$CMD -P >/dev/null
	[ $? -ne 0 ] && { echo "ERROR:$CMD -P ";Command_Recycling;exit 1; }
}

## TODO：调整进程亲和性
#   Out： 0 => TPASS
#         1 => TFAIL
Command_Function2(){
        # 获取CPU个数
        local cpunum=$(cat /proc/cpuinfo | grep "processor" | wc -l)
        [ $? -ne 0 ] && { echo "[ FAIL ] : Get cpu num failed";return 1; }

	local filename="$(basename $0)"
	local tmplog=$(ps -eo "psr,pid,args" | grep "bash"| grep "${filename}" | head -n 1)
	[ $? -ne 0 ] && { echo "ERROR:获取 ${filename} 进程信息失败";Command_Recycling;exit 1; }
	local pid=$(echo "$tmplog" | awk '{print $2}')
	[ $? -ne 0 ] && { echo "ERROR:获取 ${pid} 进程信息失败";Command_Recycling;exit 1; }

	# 调整进程至0号CPU运行
	tuna --cpu 0 --threads ${pid} --move
	[ $? -ne 0 ] && { echo "ERROR:tuna --cpu 0 --threads ${pid} --move 失败";Command_Recycling;exit 1; }
	local tmplog=$(ps -eo "psr,pid,args" | grep "bash"| grep "${filename}" | head -n 1)
	echo ${tmplog}
	local psr_cur=$(echo "$tmplog" | awk '{print $1}')
	[ ${psr_cur} -ne 0 ] && { echo "ERROR: 进程亲和性调整为0失败，当前为${psr_cur}";Command_Recycling;exit 1; }

	# 调整进程至最后的CPU运行
	let local psr_set=$cpunum-1
	tuna --cpu ${psr_set} --threads ${pid} --move
	[ $? -ne 0 ] && { echo "ERROR:tuna --cpu ${psr_set} --threads ${pid} --move 失败";Command_Recycling;exit 1; }
	tmplog=$(ps -eo "psr,pid,args" | grep "bash"| grep "${filename}" | head -n 1)
	psr_cur=$(echo "$tmplog" | awk '{print $1}')
	echo ${tmplog}
	[ ${psr_cur} -ne ${psr_set} ] && { echo "ERROR: 进程亲和性调整为${psr_set}失败，当前为${psr_cur}";Command_Recycling;exit 1; }
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
        Command_Function1
        Command_Function2
        Command_Recycling
}


Command_Main
exit $RET
