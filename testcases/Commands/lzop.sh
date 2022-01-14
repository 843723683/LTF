#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   lzop 
# Version:    1.0
# Date:       2021/06/27
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/27
# Function:   lzop 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="lzop 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="lzop rm grep"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	file1_lzop="${TmpTestDir_LTFLIB}/file1_lzop.txt"
	file2_lzop="${TmpTestDir_LTFLIB}/file2_lzop.lzo"
	
	strlog_lzop="Hello LTF LZOP"
	echo "${strlog_lzop}" > ${file1_lzop}
	CommRetParse_FailDiy_LTFLIB "${ERROR}" "创建 ${file1_lzop} 失败"

	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	rm ${file1_lzop} ${file2_lzop}

	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	lzop -9 ${file1_lzop} -o ${file2_lzop}
	CommRetParse_LTFLIB "lzop -9 ${file1_lzop} -o ${file2_lzop}"

	rm ${file1_lzop}
	CommRetParse_LTFLIB "rm ${file1_lzop}"

	lzop -d ${file2_lzop} -o ${file1_lzop}
	CommRetParse_LTFLIB "lzop -9 ${file1_lzop} -o ${file2_lzop}"

	grep -nur "${strlog_lzop}" ${file1_lzop}
	CommRetParse_LTFLIB "grep -nur \"${strlog_lzop}\" file1_lzop"
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
