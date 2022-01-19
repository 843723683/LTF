#!/usr/bin/env bash

#-----------------------------------------
#Filename:      cp.sh
#Version:       2.0
#Date:          2021/12/28
#Author:        LZ yaoxiyao
#Email:         liuzuo@kylinos.com.cn yaoxiyao@kylinos.com.cn
#History:       Version 1.0 2021/06/17
#               Version 2.0 2021/12/28 "新框架复写"
#Function:      验证命令cp能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------

# 测试主题
Title_Env_LTFLIB="cp 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="cp diff"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	#创建临时文件
	testFile1="${TmpTestDir_LTFLIB}/file_cp1"
	echo "test ${testFile1}" >> ${testFile1}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile1}"

	testFile2="${TmpTestDir_LTFLIB}/file_cp2"
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


## TODO : 测试用例
testcase_1(){
	cp ${testFile1} ${testFile2}
	echo -n "${testFile1}:"
	cat ${testFile1}
	echo -n "${testFile2}:"
	cat ${testFile2}
	diff ${testFile1} ${testFile2}
	CommRetParse_LTFLIB "cp ${testFile1} ${testFile2}"
}


testcase_2(){
	cp -f ${testFile1} ${testFile2}
	CommRetParse_LTFLIB "cp -f ${testFile1} ${testFile2}"
}


testcase_3(){
	cp -p ${testFile1} ${testFile2}
	CommRetParse_LTFLIB "cp -p ${testFile1} ${testFile2}"
}


## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1
	testcase_2
	testcase_1
	return $TPASS
}



#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
