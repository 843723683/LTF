#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   xargs 
# Version:    1.0
# Date:       2021/06/26
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/26
# Function:   Template 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="xargs 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="xargs find"


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
	find ${TmpTestDir_LTFLIB} | xargs ls -d 
	CommRetParse_LTFLIB "find ${TmpTestDir_LTFLIB} | xargs ls -d "
}

## TODO : 测试用例
testcase_2(){
	find ${TmpTestDir_LTFLIB} -print0 | xargs -0 ls -d 
	CommRetParse_LTFLIB "find ${TmpTestDir_LTFLIB} -print0 | xargs -0 ls -d "
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
