#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   rm 
# Version:    1.0
# Date:       2022/01/13
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/13
# Function:   rm 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="rm 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="rm cat ls"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-rm"
	
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
        echo "Test rm" > ${testFile}
	rm ${testFile}
	CommRetParse_LTFLIB "rm ${testFile}"

        echo "Test rm" > ${testFile}
	rm -rf ${testFile}
	CommRetParse_LTFLIB "rm -rf ${testFile}"
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
