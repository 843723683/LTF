#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   tuna
# Version:    1.0
# Date:       2021/06/25
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/01/12
# Function:   tuna 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="tuna 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="tuna head"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	# 显示线程信息列表
	tuna -P | head -n 5
	CommRetParse_LTFLIB "tuna -P"
}


testcase_2(){
        # 获取CPU个数
        local cpunum=$(cat /proc/cpuinfo | grep "processor" | wc -l)
	CommRetParse_FailDiy_LTFLIB ${ERROR} "Get cpu num failed"

	local filename="$(basename $0)"
	local tmplog=$(ps -eo "psr,pid,args" | grep "bash"| grep "${filename}" | head -n 1)
	CommRetParse_FailDiy_LTFLIB ${ERROR} "获取 ${filename} 进程信息失败"
	local pid=$(echo "$tmplog" | awk '{print $2}')
	CommRetParse_FailDiy_LTFLIB ${ERROR} "获取 ${pid} 进程信息失败"

	# 调整进程至0号CPU运行
	tuna --cpu 0 --threads ${pid} --move
	CommRetParse_LTFLIB "tuna --cpu 0 --threads ${pid} --move"
	local tmplog=$(ps -eo "psr,pid,args" | grep "bash"| grep "${filename}" | head -n 1)
	echo ${tmplog}
	local psr_cur=$(echo "$tmplog" | awk '{print $1}')
	if [ ${psr_cur} -eq 0 ];then
		OutputRet_LTFLIB ${TPASS}
		CommRetParse_LTFLIB "进程亲和性调整为0"
	else
		OutputRet_LTFLIB ${TFAIL}
		CommRetParse_LTFLIB "进程亲和性调整为0"
	fi

	# 调整进程至最后的CPU运行
	let local psr_set=$cpunum-1
	tuna --cpu ${psr_set} --threads ${pid} --move
	CommRetParse_LTFLIB "tuna --cpu ${psr_set} --threads ${pid} --move"
	tmplog=$(ps -eo "psr,pid,args" | grep "bash"| grep "${filename}" | head -n 1)
	psr_cur=$(echo "$tmplog" | awk '{print $1}')
	echo ${tmplog}
	if [ ${psr_cur} -eq ${psr_set} ];then
		OutputRet_LTFLIB ${TPASS}
		CommRetParse_LTFLIB "进程亲和性调整为${psr_set}"
	else
		OutputRet_LTFLIB ${TFAIL}
		CommRetParse_LTFLIB "进程亲和性调整为${psr_set}"
	fi
}


## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1
	testcase_2

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
