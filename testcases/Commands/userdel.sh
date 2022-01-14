#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   userdel
# Version:    1.0
# Date:       2021/06/25
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/25
#             Version 2.0, 2021/12/29
# Function:   userdel 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="userdel 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="userdel useradd"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	testUser="ltf_useradd_$RANDOM"
	useradd ${testUser}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建用户 ${testUser} 失败"

	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	cat /etc/passwd | grep ${testUser}
	if [ $? == 0 ];then
		userdel -rf ${testUser}
		Debug_LLE "userdel -rf ${testUser}"
	fi

	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	userdel -rf $testUser
	CommRetParse_LTFLIB "userdel -rf ${testUser}"

	cat /etc/passwd | grep ${testUser}
	CommRetParse_LTFLIB "/etc/passwd 中不存在用户 ${testUser}" "true" "yes"
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
