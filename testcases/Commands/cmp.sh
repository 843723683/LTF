#!/usr/bin/env bash

#-----------------------------------------
#Filename:      cmp.sh
#Version:       2.0
#Date:          2021/12/28
#Author:        LZ yaoxiyao
#Email:         liuzuo@kylinos.com.cn yaoxiyao@kylinos.com.cn
#History:		  Version 1.0 2021/06/17
#               Version 2.0 2021/12/28 "新框架复写"
#Function:      验证命令cmp能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------

# 测试主题
Title_Env_LTFLIB="cmp 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="cmp"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	#创建临时文件
	testFile1="${TmpTestDir_LTFLIB}/file_cmp1"
	echo "This is some text to play with" >> ${testFile1}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile1}"

	testFile2="${TmpTestDir_LTFLIB}/file_cmp2"
	echo "This is some test to play with" >> ${testFile2}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile2}"
	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testFile1} ${testFile2}"
	rm -rf ${testFile1} ${testFile2}
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
	echo -n "${testFile1}:"
	cat ${testFile1}
	echo -n "${testFile2}:"
	cat ${testFile2}
	cmp ${testFile1} ${testFile2}

	cmp ${testFile1} ${testFile2} | egrep -q  "第 16 字节，第 1 行|byte 16, line 1"
	CommRetParse_LTFLIB "cmp ${testFile1} ${testFile2} | egrep -q  \"第 16 字节，第 1 行|byte 16, line 1\""
}



#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
