#!/usr/bin/env bash

#-----------------------------------------
#Filename:      false.sh
#Version:       2.0
#Date:          2022/01/05
#Author:        LZ yaoxiyao
#Email:         liuzuo@kylinos.com.cn yaoxiyao@kylinos.com.cn
#History:       Version 1.0 2021/06/17
#               Version 2.0 2022/01/05 "新框架复写"
#Function:      验证命令false能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------

# 测试主题
Title_Env_LTFLIB="false 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="false"


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
	false
	CommRetParse_LTFLIB "false" "False" "yes"
}



#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
