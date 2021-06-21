#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   pathchk.sh 
# Version:    1.0
# Date:       2021/06/20
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/20
# Function:   pathchk 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

#测试的命令
CMD="pathchk"
#测试中使用的命令
CMD_IMPORTANT=""


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Init(){
	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Clean(){
	return $TPASS
}


## TODO : 测试用例
test1(){
	pathchk -p "<>"
	CommRetParse_LTFLIB "pathchk -p \"<>\"" "true" "yes"
}


## TODO : 测试用例
test2(){
	pathchk /var/tmp/1234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456
	CommRetParse_LTFLIB "pathchk /var/tmp/1234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456" "true" "yes"
}


## TODO : 测试用例
test3(){
	pathchk /var/tmp >/dev/null
	CommRetParse_LTFLIB "pathchk /var/tmp"
}


## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
RunAll(){
	test1

	test2

	test3

	return $TPASS
}


## TODO : 搭建运行环境
Register(){
	# 加载库函数
	local libfile="${LIB_ROOT}/ltfLib.sh"
	if [ -f "${libfile}" ];then
		source ${libfile}
	else
		TConf_LLE "Can't found file(${libfile}) !"
		exit ${TCONF}
	fi

	# 注册函数
	RegFunc_LTFLIB "Init" "RunAll" "Clean"

	# 判断命令是否存在
	Command_isExist	"${CMD}" ${CMD_IMPORTANT}
	TestRetParse_LTFLIB

	return ${TPASS}	
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
                [ $? -ne 0 ] && { TConf_LLE "Command $command not exist!";return ${TCONF}; }
        done

	return ${TPASS}
}


## TODO : 主函数
Main(){
	# 设置
	Register
	TestRetParse_LTFLIB

	# 调用主函数
	Main_LTFLIB
	TestRetParse_LTFLIB
}


Main $@
Exit_LTFLIB $?
