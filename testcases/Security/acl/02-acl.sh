#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   02-acl.sh
# Version:    1.0
# Date:       2021/06/22
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/06/22
# Function:   acl - 02 自主访问控制有效性测试 
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------


Title_Env_LTFLIB="访问控制测试 - 自主访问控制有效性测试"

HeadFile_Source_LTFLIB="${LIB_SSHAUTO}"

testuser1_acl2="ltfacl2"
passwd1_acl2="olleH717.12.#$"
userip_acl2="localhost"
AddUserNames_LTFLIB="${testuser1_acl2}"
AddUserPasswds_LTFLIB="${passwd1_acl2}"

## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	# 创建临时目录
	testDir_acl02="${TmpTestDir_LTFLIB}/diracl02"
	mkdir ${testDir_acl02}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建目录失败${testDir_acl02}"

	# 创建临时文件
	testFile_acl02="${TmpTestDir_LTFLIB}/fileacl02"
	echo "Hello LTF" > ${testFile_acl02}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile_acl02}"

	# 配置免密登录
	SshAuto_OneConfig_LTFLIB "${userip_acl2}" "${testuser1_acl2}" "${passwd1_acl2}"
	TestRetParse_LTFLIB "配置免密登录" "True" "no" "yes"

        SshAuto_SetIpUser_LTFLIB "${userip_acl2}" "${testuser1_acl2}"
        TestRetParse_LTFLIB "设置默认IP和用户名" "True" "no" "yes"

	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testDir_acl02} ${testFile_acl02}"
	rm -rf ${testDir_acl02} ${testFile_acl02}

	return $TPASS
}

## TODO : 测试文件和文件夹默认权限
testcase_1(){
	ls -al ${testFile_acl02} | grep "rw-r--r--"
	CommRetParse_LTFLIB "ls -al ${testFile_acl02} | grep \"rw-r--r--\""

	ls -ald ${testDir_acl02} | grep "rwxr-xr-x"
	CommRetParse_LTFLIB "ls -ald ${testDir_acl02} | grep \"rwxr-xr-x\""
}


## TODO : 测试设置文件和文件夹
testcase_2(){
	chmod 700 ${testFile_acl02} ${testDir_acl02}
	CommRetParse_LTFLIB "chmod 700 ${testFile_acl02} ${testDir_acl02}"

	SshAuto_CmdDef_LTFLIB "cat ${testFile_acl02}" "no" "yes"
	TestRetParse_LTFLIB "无权限查看文件 ${testFile_acl02}" "False"

	SshAuto_CmdDef_LTFLIB "cd ${testDir_acl02}" "no" "yes"
	TestRetParse_LTFLIB "无权限进入目录 ${testFile_acl02}" "False"
}


## TODO : 测试设置文件和文件夹
testcase_3(){
	setfacl -m u:${testuser1_acl2}:rwx ${testFile_acl02} ${testDir_acl02}
	CommRetParse_LTFLIB "setfacl -m u:${testuser1_acl2}:rwx ${testFile_acl02} ${testDir_acl02}"

	SshAuto_CmdDef_LTFLIB "cat ${testFile_acl02}" "no" "no"
	TestRetParse_LTFLIB "可以查看文件 ${testFile_acl02}" "False"

	SshAuto_CmdDef_LTFLIB "cd ${testDir_acl02}" "no" "no"
	TestRetParse_LTFLIB "可以进入目录 ${testFile_acl02}" "False"
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
