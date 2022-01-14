#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   passwd 
# Version:    1.0
# Date:       2022/01/13
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/14
# Function:   passwd 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="passwd 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="passwd"

# 新增用户
UserName_passwd="ltf_passwd_$RANDOM"
AddUserNames_LTFLIB="$UserName_passwd"

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
	echo "Dzzf.#147" | passwd --stdin ${UserName_passwd}
	CommRetParse_LTFLIB "echo \"Dzzf.#147\" | passwd --stdin ${UserName_passwd}"
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
