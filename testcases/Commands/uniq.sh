#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   uniq 
# Version:    1.0
# Date:       2021/06/25
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/01/12
# Function:   uniq 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="uniq 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="uniq wc grep"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-uniq"
	cat > ${testFile} <<EOF
1
2
2
3
3
4
5
EOF
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"

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
	uniq -d ${testFile} | wc -l | grep -q "2"
	CommRetParse_LTFLIB "uniq -d ${testFile} | wc -l | grep -q \"2\""
}

testcase_2(){
	uniq -u ${testFile}| wc -l | grep -q "3"
	CommRetParse_LTFLIB "uniq -u ${testFile}| wc -l | grep -q \"3\""
}

## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1
	testcase_2

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
