#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   yes 
# Version:    1.0
# Date:       2021/06/25
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/25
# Function:   yes 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="yes 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="yes"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件
        testFile1_yes="${TmpTestDir_LTFLIB}/fileyes01"
        echo "Hello LTF" > ${testFile1_yes}
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile_acl03}"

        testFile2_yes="${TmpTestDir_LTFLIB}/fileyes02"
        echo "Hello LTF" > ${testFile2_yes}
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile_acl03}"
	
	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	yes | rm -i ${testFile1_yes} ${testFile2_yes}
	CommRetParse_LTFLIB "yes | rm -i ${testFile1_yes} ${testFile2_yes}" "true" "no"
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
