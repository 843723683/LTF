#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   lsb_release 
# Version:    1.0
# Date:       2022/01/14
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/14
# Function:   lsb_release 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="lsb_release 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="lsb_release"


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
	lsb_release -i
	lsb_release -i | grep -q "Kylin"
	CommRetParse_LTFLIB "lsb_release -i | grep -q \"Kylin\""
}

testcase_2(){
	lsb_release -d
	lsb_release -d | grep -q "Kylin"
	CommRetParse_LTFLIB "lsb_release -d | grep -q \"Kylin\""
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
