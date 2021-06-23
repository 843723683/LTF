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

## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit(){
        # 判断是否存在免密登录库
        local sshautofile="${LIB_ROOT}/ssh-auto.sh"
        if [ -f "$sshautofile" ];then
                source $sshautofile
        else
                Error_LLE "$sshautofile : Can't found file !"
                return $ERROR
        fi

	# 创建临时目录
	testDir_acl02="${TmpTestDir_LTFLIB}/diracl02"
	mkdir ${testDir_acl02}
	[ ! -d "${testDir_acl02}" ] && return $TCONF

	# 创建临时文件
	testFile_acl02="${TmpTestDir_LTFLIB}/fileacl02"
	echo "Hello LTF" > ${testFile_acl02}
	[ ! -f "${testFile_acl02}" ] && return $TCONF

	testuser='ltfacl2'
	userpasswd='olleH717.12.#$'
	userip="localhost"
	# 测试用户
	useradd $testuser >/dev/null
	[ $? -ne 0 ] && { OutputRet_LTFLIB ${ERROR};TestRetParse_LTFLIB "useradd ${testuser}"; }
	
	# 设置密码
	echo ${userpasswd} | passwd --stdin ${testuser} >/dev/null
	[ $? -ne 0 ] && { OutputRet_LTFLIB ${ERROR};TestRetParse_LTFLIB "echo ${userpasswd} | passwd --stdin ${testuser}"; }

	# 配置免密登录
	SshAuto_OneConfig_LTFLIB "${userip}" "${testuser}" "${userpasswd}"
	TestRetParse_LTFLIB "配置免密登录"


	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean(){
	Debug_LLE "rm -rf ${testDir_acl02} ${testFile_acl02}"
	rm -rf ${testDir_acl02} ${testFile_acl02}

	userdel -rf $testuser

	return $TPASS
}

                                                                                               
## TODO  : 本地(localhost)用户(普通用户)执行命令                                               
#    In  : $1 => 执行命令                                                                      
#          $2 => 是否静默输出 yes -> 静默 no -> 打印输出                                       
#          $3 => 结果是否反转                                                                  
Local_Ord_Command(){                                                                     
        if [ $# -ne 3 ];then                                                                   
		OutputRet_LTFLIB ${ERROR}
		TestRetParse_LTFLIB "NoAllowedCommand_SOPORD 参数错误"
        fi                                                                                     
                                                                                               
        SshAuto_Command_LTFLIB "${userip}" "${testuser}" "$1" "$2" "$3"              
        return $?                                                                              
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
	TestRetParse_LTFLIB "chmod 700 ${testFile_acl02} ${testDir_acl02}"

	Local_Ord_Command "cat ${testFile_acl02}" "no" "yes"
	TestRetParse_LTFLIB "无权限查看文件 ${testFile_acl02}" "False"

	Local_Ord_Command "cd ${testDir_acl02}" "no" "yes"
	TestRetParse_LTFLIB "无权限进入目录 ${testFile_acl02}" "False"
}


## TODO : 测试设置文件和文件夹
testcase_3(){
	setfacl -m u:${testuser}:rwx ${testFile_acl02} ${testDir_acl02}
	TestRetParse_LTFLIB "setfacl -m u:${testuser}:rwx ${testFile_acl02} ${testDir_acl02}"

	Local_Ord_Command "cat ${testFile_acl02}" "no" "no"
	TestRetParse_LTFLIB "可以查看文件 ${testFile_acl02}" "False"

	Local_Ord_Command "cd ${testDir_acl02}" "no" "no"
	TestRetParse_LTFLIB "可以进入目录 ${testFile_acl02}" "False"
}


## TODO : 运行测试集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite(){
	testcase_1
	testcase_2
	testcase_3

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
