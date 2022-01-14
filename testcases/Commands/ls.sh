#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   ls.sh 
# Version:    1.0
# Date:       2021/06/21
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/21
# Function:   ls 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="ls 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="ls"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-ls"
        echo "Test ls" > ${testFile}
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"

	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	true
}


## TODO : 测试用例
testcase_1(){
	ls ${testFile}
	CommRetParse_LTFLIB "ls ${testFile}"
}


testcase_2(){
	ls -a ${testFile}
	CommRetParse_LTFLIB "ls -a ${testFile}"
}


testcase_3(){
	ls -l ${testFile} 
	CommRetParse_LTFLIB "ls -l ${testFile}"
}


## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1
	testcase_2
	testcase_3

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
