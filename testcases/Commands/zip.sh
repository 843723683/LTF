#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   zip 
# Version:    1.0
# Date:       2021/06/25
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/25
#             Version 2.0, 2021/12/29
# Function:   zip 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="zip 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="zip"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-zip"
        echo "Test zip" > ${testFile}
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"

	testZip="${TmpTestDir_LTFLIB}/test-zip.zip"
	
	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testFile} ${testZip}"
	rm -rf ${testFile} ${testZip}
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	zip -q ${testZip} ${testFile}
	CommRetParse_LTFLIB "zip -q ${testZip} ${testFile}/*" "true" "no"
	rm -rf ${testFile}

	unzip -q ${testZip} -d /
	CommRetParse_LTFLIB "unzip -q ${testZip} -d /" "true" "no"

	cat ${testFile} | grep -q "Test zip"
	CommRetParse_LTFLIB "cat ${testFile} | grep -q \"Test zip\"" "true" "no"
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
