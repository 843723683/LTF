#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-acl.sh
# Version:    1.0
# Date:       2019/12/10
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   acl - 01 设置和查看文件、目录设置访问权限
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------


Title_Env_LTFLIB="访问控制测试 - 自主访问控制授权机制测试"

## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	# 创建临时目录
	testDir_acl01="${TmpTestDir_LTFLIB}/diracl01"
	mkdir ${testDir_acl01}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建目录失败${testDir_acl01}"

	# 创建临时文件
	testFile_acl01="${TmpTestDir_LTFLIB}/fileacl01"
	touch ${testFile_acl01}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile_acl01}"

	# 测试用户
	testuser='nobody'
	cat /etc/passwd | grep "$testuser" > /dev/null
	CommRetParse_FailDiy_LTFLIB ${ERROR} "未知的用户名${testuser}"

	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testDir_acl01} ${testFile_acl01}"
	rm -rf ${testDir_acl01} ${testFile_acl01}

	return $TPASS
}


## TODO : 测试文件和文件夹默认权限
testcase_1(){
	ls -al ${testFile_acl01}
	ls -al ${testFile_acl01} | grep -q "rw-r--r--"
	CommRetParse_LTFLIB "ls -al ${testFile_acl01} | grep \"rw-r--r--\""

	ls -ald ${testDir_acl01}
	ls -ald ${testDir_acl01} | grep -q "rwxr-xr-x"
	CommRetParse_LTFLIB "ls -ald ${testDir_acl01} | grep \"rwxr-xr-x\""
}


## TODO : 测试设置文件和文件夹
testcase_2(){
	chmod 777 ${testFile_acl01} ${testDir_acl01}
	CommRetParse_LTFLIB "chmod 777 ${testFile_acl01} ${testDir_acl01}"

	ls -al ${testFile_acl01} | grep "rwxrwxrwx"
	CommRetParse_LTFLIB "ls -al ${testFile_acl01} | grep \"rwxrwxrwx\""

	ls -ald ${testDir_acl01} | grep "rwxrwxrwx"
	CommRetParse_LTFLIB "ls -ald ${testDir_acl01} | grep \"rwxrwxrwx\""
}


## TODO : 
testcase_3(){
	getfacl -p ${testFile_acl01} ${testDir_acl01}
	CommRetParse_LTFLIB "getfacl -p ${testFile_acl01} ${testDir_acl01}"
	
	setfacl -m u:${testuser}:--- ${testFile_acl01} ${testDir_acl01}
	CommRetParse_LTFLIB "setfacl -m u:${testuser}:--- ${testFile_acl01} ${testDir_acl01}"

	getfacl -p ${testFile_acl01} | grep "user:${testuser}:---"
	CommRetParse_LTFLIB "getfacl -p ${testFile_acl01} | grep \"user:${testuser}:---\""

	getfacl -p ${testDir_acl01} | grep "user:${testuser}:---"
	CommRetParse_LTFLIB "getfacl -p ${testDir_acl01} | grep \"user:${testuser}:---\""
}


## TODO : 运行测试集
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
