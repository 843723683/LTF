#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   man.sh 
# Version:    1.0
# Date:       2021/06/21
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/21
# Function:   man 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="man 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="man ls head"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	true
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	true
}


## TODO : 测试用例
testcase_1(){
	man ls > /dev/null 
	CommRetParse_LTFLIB "man ls"
}

testcase_2(){
	man head  > /dev/null
	CommRetParse_LTFLIB "man head"
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
