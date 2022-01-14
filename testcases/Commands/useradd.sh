#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   useradd
# Version:    1.0
# Date:       2022/01/13
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/13
# Function:   useradd 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="useradd 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="useradd userdel cat grep"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	testUser="ltf_useradd_$RANDOM"

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
	useradd ${testUser}
	CommRetParse_LTFLIB "useradd ${testUser}"

	#判断用户是否添加成功
	local etc_passwd_res=$(cat /etc/passwd|grep "$testUser")
	local username=${etc_passwd_res%%:*}
	[ "Z${username}" == "Z${testUser}" ] 
	CommRetParse_LTFLIB "查看/etc/passwd 中是否存在用户${testUser}"

	userdel -rf ${testUser}
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
