#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   wc
# Version:    1.0
# Date:       2021/06/25
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/25
#             Version 2.0, 2021/12/29
# Function:   wc 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="wc 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="wc"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-wc"
	cat << EOF > ${testFile}
1 2
3 4
5 6
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
# file should have 3 lines, 12 bytes, 12 characters, max line length of 3, and 6 words
testcase_1(){
	wc -l ${testFile} | grep -q 3
	CommRetParse_LTFLIB "wc -l ${testFile} | grep -q 3"
}

testcase_2(){
	wc -c ${testFile} | grep -q 12
	CommRetParse_LTFLIB "wc -c ${testFile} | grep -q 12"
}


testcase_3(){
	wc -m ${testFile} | grep -q 12
	CommRetParse_LTFLIB "wc -m ${testFile} | grep -q 12"
}

testcase_4(){
	wc -L ${testFile} | grep -q 3
	CommRetParse_LTFLIB "wc -L ${testFile} | grep -q 3"
}

testcase_5(){
	wc -w ${testFile} | grep -q 6
	CommRetParse_LTFLIB "wc -w ${testFile} | grep -q 6"
}

## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1
	testcase_2
	testcase_3
	testcase_4
	testcase_5

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
