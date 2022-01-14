#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   mkdir 
# Version:    1.0
# Date:       2022/01/14
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/14
# Function:   mkdir 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------


# 测试主题
Title_Env_LTFLIB="mkdir 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="mkdir ls rm"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testDir="${TmpTestDir_LTFLIB}/test-mkdir"
	
	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	rm -rf ${testDir}
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	mkdir ${testDir}
	CommRetParse_LTFLIB "mkdir ${testDir}"

	ls ${testDir} -ald
	CommRetParse_LTFLIB "ls ${testDir}"
	
	mkdir -p ${testDir}/mkdir_testsec/mkdir_testthd
	CommRetParse_LTFLIB "mkdir -p ${testDir}/mkdir_testsec/mkdir_testthd"
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
