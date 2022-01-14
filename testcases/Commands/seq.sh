#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   seq 
# Version:    1.0
# Date:       2022/01/13
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/13
# Function:   seq 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="seq 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="seq"


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
	seq -s " " 5 | grep -q "1 2 3 4 5"
	CommRetParse_LTFLIB "seq -s \" \" 5 | grep -q \"1 2 3 4 5\""

	seq -s " " 6 8 | grep -q "6 7 8"
	CommRetParse_LTFLIB "seq -s \" \" 6 8 | grep -q \"6 7 8\""

	seq -s " " 8 2 12 | grep -q "8 10 12"
	CommRetParse_LTFLIB "seq -s \" \" 8 2 12 | grep -q \"8 10 12\""
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
