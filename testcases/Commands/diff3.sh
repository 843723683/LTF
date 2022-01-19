#!/usr/bin/env bash

#-----------------------------------------
#Filename:      diff3.sh
#Version:       2.0
#Date:          2021/12/28
#Author:        LZ yaoxiyao
#Email:         liuzuo@kylinos.com.cn yaoxiyao@kylinos.com.cn
#History:       Version 1.0 2021/06/17
#               Version 2.0 2021/12/28 "新框架复写"
#Function:      验证命令diff3能否使用
#Out:           
#               0 => TPASS
#               1 => TFAIL
#               other => TCONF
#-----------------------------------------

# 测试主题
Title_Env_LTFLIB="diff3 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="diff3"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	#创建临时文件
	testFile1="${TmpTestDir_LTFLIB}/file_diff3_a"
	echo "test ${testFile1}" >> ${testFile1}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile1}"

	testFile2="${TmpTestDir_LTFLIB}/file_diff3_b"

	testFile3="${TmpTestDir_LTFLIB}/file_diff3_c"
	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testFile1} ${testFile2} ${testFile3}"
	rm -rf ${testFile1} ${testFile2} ${testFile3}
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
	cp ${testFile1} ${testFile2}
	cp ${testFile1} ${testFile3}
	echo -n "${testFile1}:"
	cat ${testFile1}
	echo -n "${testFile2}:"
	cat ${testFile2}
	echo -n "${testFile3}:"
	cat ${testFile3}
	local tmpStr=`diff3 ${testFile1} ${testFile2} ${testFile3}`
	test -z "$tmpStr"
	CommRetParse_LTFLIB "diff3 ${testFile1} ${testFile2} ${testFile3}"
}



#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
