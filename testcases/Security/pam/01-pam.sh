#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-pam.sh
# Version:    1.0
# Date:       2019/12/10
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   pam - 01 身份鉴别测试 - PAM机制 
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------


Title_Env_LTFLIB="身份鉴别测试 - PAM机制"

## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){

	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){

	return $TPASS
}


## TODO : 测试文件和文件夹默认权限
testcase_1(){
	local file_pam01="/usr/bin/passwd"

	ldd ${file_pam01} |grep libpam.so.0
	CommRetParse_LTFLIB "ldd ${file_pam01} |grep libpam.so.0"

	ldd ${file_pam01} |grep libpam_misc.so.0
	CommRetParse_LTFLIB "ldd ${file_pam01} |grep libpam_misc.so.0"
}


## TODO : 运行测试集
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
