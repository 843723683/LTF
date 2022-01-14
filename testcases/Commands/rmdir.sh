#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   rmdir 
# Version:    1.0
# Date:       2022/01/13
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/13
# Function:   rmdir 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="rmdir 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="rmdir"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testDir="${TmpTestDir_LTFLIB}/test-rmdir"
	mkdir $testDir
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建目录失败${testDir}"

	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testDir}"
	rm -rf ${testDir}
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	rmdir ${testDir}
	CommRetParse_LTFLIB "rmdir ${testDir}"

	ls -ald ${testDir}
	CommRetParse_LTFLIB "目录${testDir}已被删除" "false" "yes"

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
