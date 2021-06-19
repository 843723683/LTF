#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   Template 
# Version:    1.0
# Date:       2021/06/19
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/19
# Function:   Template - 01 XXX功能描述 
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Init(){
	TESTPATH="${TMP_ROOT_LTF}"
	TESTFILE="${TESTPATH}/ltf_command_man"
	touch ${TESTFILE}
	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Clean(){
	rm ${TESTFILE}
	return $TPASS
}


## TODO : 测试用例
test1(){
	man ls > /dev/null
	TestRetParse_LTFLIB "man ls"

	return $TPASS
}


## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
RunAll(){
	test1
	TestRetParse_LTFLIB

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
