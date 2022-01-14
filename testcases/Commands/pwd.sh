#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   yes 
# Version:    1.0
# Date:       2022/01/13
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/01/13
# Function:   pwd 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="pwd 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="pwd"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testPath="${TmpTestDir_LTFLIB}"
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建目录失败${testPath}"

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
	cd $testPath
	local cmd_ret=`pwd`
	[ ${testPath} == ${cmd_ret} ]
	CommRetParse_LTFLIB "进入${testPath},pwd当前目录为${cmd_ret}"
}

## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
