#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   gzip 
# Version:    1.0
# Date:       2022/01/14
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/14
# Function:   gzip 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="gzip 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="gzip"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-gzip"
        echo "Test gzip" > ${testFile}
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"

	testGzip="${TmpTestDir_LTFLIB}/test-gzip.gz"
	
	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testFile} ${testGzip}"
	rm -rf ${testFile} ${testGzip}
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	gzip ${testFile}
	CommRetParse_LTFLIB "gzip ${testFile}"

	gunzip ${testGzip}
	CommRetParse_LTFLIB "gunzip ${testGzip}"

	cat ${testFile}
	CommRetParse_LTFLIB "cat ${testFile}"
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
