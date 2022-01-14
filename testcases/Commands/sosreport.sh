#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   sosreport
# Version:    1.0
# Date:       2022/01/13
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/13
# Function:   sosreport 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="sosreport 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="sosreport"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	testFileName="ltfsosreport"
	testPath=${TmpTestDir_LTFLIB}
	# 可能存在sosreport-localhost-${TMPFILENAME}的情况，所以加上"*"
        testFile="${testPath}/sosreport-*${testFileName}"

	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testFile}"
	rm -rf ${testFile}
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	echo -e "\n" | sosreport --name=${testFileName} --tmp-dir=${testPath}
	CommRetParse_LTFLIB "sosreport --name=${testFileName} --tmp-dir=${testPath}"

	ls ${testFile}* -al
	CommRetParse_LTFLIB "ls ${testFile}"
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
