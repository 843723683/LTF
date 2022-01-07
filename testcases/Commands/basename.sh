#!/usr/bin/env bash

#-----------------------------------------
#Filename:      basename.sh
#Version:       2.0
#Date:          2021/12/28
#Author:        LZ yaoxiyao
#Email:         liuzuo@kylinos.com.cn yaoxiyao@kylinos.com.cn
#History:		  Version 1.0 2021/06/17
#               Version 2.0 2021/12/28 "新框架复写"
#Function:      验证命令basename能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------

# 测试主题
Title_Env_LTFLIB="basename 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="basename"


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
	basename $0 | grep -q basename.sh
	CommRetParse_LTFLIB "basename $0 | grep -q basename.sh"

	basename /etc/hosts | grep -q hosts
	CommRetParse_LTFLIB "basename /etc/hosts | grep -q hosts"
}



#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
