#!/usr/bin/env bash

#-----------------------------------------
#Filename:      acl.sh
#Version:       2.0
#Date:          2021/12/28
#Author:        LZ yaoxiyao
#Email:         liuzuo@kylinos.com.cn yaoxiyao@kylinos.com.cn
#History:		  Version 1.0 2021/06/17
#               Version 2.0 2021/12/28 "新框架复写"
#Function:      验证命令acl能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------

# 测试主题
Title_Env_LTFLIB="acl 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="setfacl getfacl"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	testFile="${TmpTestDir_LTFLIB}/file_acl"
	echo "test ${testFile}" > ${testFile}
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
	setfacl -m user:nobody:r-- ${testFile}
	CommRetParse_LTFLIB "setfacl -m user:nobody:r-- ${testFile}"

	getfacl -p ${testFile} | grep -q 'user:nobody:r--'
	CommRetParse_LTFLIB "getfacl -p ${testfile} | grep -q 'user:nobody:r--'"
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
