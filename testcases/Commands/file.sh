#!/usr/bin/env bash

#-----------------------------------------
#Filename:      file.sh
#Version:       2.0
#Date:          2022/01/05
#Author:        LZ yaoxiyao
#Email:         liuzuo@kylinos.com.cn yaoxiyao@kylinos.com.cn
#History:       Version 1.0 2021/06/17
#               Version 2.0 2022/01/05 "新框架复写"
#Function:      验证命令file能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------

# 测试主题
Title_Env_LTFLIB="file 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="file"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	#创建临时文件
	testFile="${TmpTestDir_LTFLIB}/file_file"
	cat >${testFile} <<EOF
#!/bin/bash
EOF
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"
	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testFile}"
	rm -rf ${testFile}
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
	file ${testFile}
	file ${testFile} | grep -q "shell script"
	CommRetParse_LTFLIB "file ${testFile} | grep -q 'shell script'"
}



#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
