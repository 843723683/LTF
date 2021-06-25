#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   04-acl.sh
# Version:    1.0
# Date:       2021/06/25
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/06/25
# Function:   acl - 04 客体缺省访问权限测试 
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------


Title_Env_LTFLIB="访问控制测试 -客体缺省访问权限测试" 

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
	rm -rf ${testDir_acl04} ${testFile1_acl04}

	return $TPASS
}


## TODO : 测试文件和文件夹默认权限
testcase_1(){
	# 创建临时文件1
	testFile1_acl04="${TmpTestDir_LTFLIB}/fileacl04"
	
	umask | grep 0022	
	CommRetParse_LTFLIB "umask | grep 0022"

	touch ${testFile1_acl04}
	CommRetParse_LTFLIB "touch ${testFile1_acl04}"

	ls -al ${testFile1_acl04} | grep "rw-r--r--"
	CommRetParse_LTFLIB "ls -al ${testFile1_acl04} | grep \"rw-r--r--\""
}


## TODO : 测试设置文件和文件夹
testcase_2(){
	# 创建临时文件1
	testFile2_acl04="${TmpTestDir_LTFLIB}/fileacl04_2"
	
	umask 0011	
	CommRetParse_LTFLIB "设置umask 为0011"

	umask | grep 0011
	CommRetParse_LTFLIB "umask | grep 0011"

	touch ${testFile2_acl04}
	CommRetParse_LTFLIB "touch ${testFile2_acl04}"

	ls -al ${testFile2_acl04}
	ls -al ${testFile2_acl04} | grep "rw-rw-rw-"
	CommRetParse_LTFLIB "ls -al ${testFile2_acl04} | grep \"rw-rw-rw-\""
}


## TODO : 运行测试集
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
