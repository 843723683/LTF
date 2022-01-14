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

# 测试主题
Title_Env_LTFLIB="pathchk 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="pathchk"


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
	pathchk -p "<>"
	CommRetParse_LTFLIB "pathchk -p \"<>\"" "true" "yes"
}


## TODO : 测试用例
testcase_2(){
	pathchk /var/tmp/1234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456789012345678901234512345678901234567890123451234567890123456789012345123456
	CommRetParse_LTFLIB "pathchk /var/tmp/1234...." "true" "yes"
}


## TODO : 测试用例
testcase_3(){
	pathchk /var/tmp >/dev/null
	CommRetParse_LTFLIB "pathchk /var/tmp"
}


## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1

	testcase_2

	testcase_3

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
