#!/usr/bin/env bash

#-----------------------------------------
#Filename:      chkconfig.sh
#Version:       2.0
#Date:          2021/12/28
#Author:        LZ yaoxiyao
#Email:         liuzuo@kylinos.com.cn yaoxiyao@kylinos.com.cn
#History:		  Version 1.0 2021/06/17
#               Version 2.0 2021/12/28 "新框架复写"
#Function:      验证命令chkconfig能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------

# 测试主题
Title_Env_LTFLIB="chkconfig 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="chkconfig"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	return $TPASS 
}


## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1
	return $TPASS
}


## TODO : 测试用例
testcase_1(){
	chkconfig --list network
	chkconfig --list network 2>&1 | egrep -q "3:on|3:开|3:启用|3:关|3:off"
	CommRetParse_LTFLIB "chkconfig --list network 2>&1 | egrep '3:on|3:开|3:启用|3:关|3:off'"
}



#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
