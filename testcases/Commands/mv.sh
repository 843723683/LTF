#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   mv 
# Version:    1.0
# Date:       2022/01/14
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/14
# Function:   mv 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="mv 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="mv ls cat rm"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-mv"
	cat > $testFile<< EOF
	command mv test
EOF
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"
	
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
	mv $testFile ${testFile}_mv
	CommRetParse_LTFLIB "mv $testFile ${testFile}_mv"

	mv -uf ${testFile}_mv ${testFile}_mv_test
	CommRetParse_LTFLIB "mv -uf ${testFile}_mv ${testFile}_mv_test"
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
