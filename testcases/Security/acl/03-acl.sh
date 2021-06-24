#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   03-acl.sh
# Version:    1.0
# Date:       2021/06/24
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/06/24
# Function:   acl - 03 测试细粒度授权
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------


Title_Env_LTFLIB="访问控制测试 -测试细粒度授权" 

testuser1_acl3="ltfacl3"
passwd1_acl3="olleH717.12.#$"
userip_acl3="localhost"
AddUserNames_LTFLIB="${testuser1_acl3}"
AddUserPasswds_LTFLIB="${passwd1_acl3}"

## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 判断是否存在免密登录库
        local sshautofile="${LIB_ROOT}/ssh-auto.sh"
        if [ -f "$sshautofile" ];then
                source $sshautofile
        else
                Error_LLE "$sshautofile : Can't found file !"
                return $ERROR
        fi

	# 创建临时目录
	testDir_acl03="${TmpTestDir_LTFLIB}/diracl03"
	mkdir ${testDir_acl03}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建目录失败${testDir_acl03}"

	# 创建临时文件
	testFile_acl03="${TmpTestDir_LTFLIB}/fileacl03"
	echo "Hello LTF" > ${testFile_acl03}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile_acl03}"

	# 配置免密登录
	SshAuto_OneConfig_LTFLIB "${userip_acl3}" "${testuser1_acl3}" "${passwd1_acl3}"
	TestRetParse_LTFLIB "配置免密登录" "True" "no" "yes"

	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testDir_acl03} ${testFile_acl03}"
	rm -rf ${testDir_acl03} ${testFile_acl03}

	return $TPASS
}

                                                                                               
## TODO  : 本地(localhost)用户(普通用户)执行命令        
#    In  : $1 => 执行命令                                                                     
#          $2 => 是否静默输出 yes -> 静默 no -> 打印输出 
Local_Ord_Command(){                                                                     
        if [ $# -ne 3 ];then                                                                   
		OutputRet_LTFLIB ${ERROR}
		TestRetParse_LTFLIB "NoAllowedCommand_SOPORD 参数错误"
        fi
	SshAuto_Command_LTFLIB "${userip_acl3}" "${testuser1_acl3}" "$1" "$2" "$3"              
        return $? 
}


## TODO : 测试文件和文件夹默认权限
testcase_1(){
	setfacl -m u:${testuser1_acl3}:--- ${testFile_acl03} ${testDir_acl03}
	CommRetParse_LTFLIB "setfacl -m u:${testuser1_acl3}:rwx ${testFile_acl03} ${testDir_acl03}"

	Local_Ord_Command "echo \"echo hello\" > ${testFile_acl03}" "no" "yes"
	TestRetParse_LTFLIB "无权限写文件 ${testFile_acl03}" "False"
	Local_Ord_Command "cat ${testFile_acl03}" "no" "yes"
	TestRetParse_LTFLIB "无权限查看文件 ${testFile_acl03}" "False"
	Local_Ord_Command "bash ${testFile_acl03}" "no" "yes"
	TestRetParse_LTFLIB "无权限执行文件 ${testFile_acl03}" "False"

	Local_Ord_Command "cd ${testDir_acl03}" "no" "yes"
	TestRetParse_LTFLIB "无权限进入目录 ${testFile_acl03}" "False"
	Local_Ord_Command "touch ${testDir_acl03}/testfile" "no" "yes"
	TestRetParse_LTFLIB "无权限向目录 ${testFile_acl03} 中创建文件" "False"
	Local_Ord_Command "ls ${testDir_acl03}" "no" "yes"
	TestRetParse_LTFLIB "无权限查看目录内容 ${testFile_acl03}" "False"
}


## TODO : 测试设置文件和文件夹
testcase_2(){
	setfacl -m u:${testuser1_acl3}:rwx ${testFile_acl03} ${testDir_acl03}
	CommRetParse_LTFLIB "setfacl -m u:${testuser1_acl3}:rwx ${testFile_acl03} ${testDir_acl03}"

	Local_Ord_Command "echo \"echo hello\"> ${testFile_acl03}" "no" "no"
	TestRetParse_LTFLIB "可以写文件 ${testFile_acl03}" "False"
	Local_Ord_Command "cat ${testFile_acl03}" "no" "no"
	TestRetParse_LTFLIB "可以查看文件 ${testFile_acl03}" "False"
	Local_Ord_Command "bash ${testFile_acl03}" "no" "no"
	TestRetParse_LTFLIB "可以执行文件 ${testFile_acl03}" "False"

	Local_Ord_Command "cd ${testDir_acl03}" "no" "no"
	TestRetParse_LTFLIB "可以进入目录 ${testFile_acl03}" "False"
	Local_Ord_Command "touch ${testDir_acl03}/testfile" "no" "no"
	TestRetParse_LTFLIB "可以向目录 ${testFile_acl03} 中创建文件" "False"
	Local_Ord_Command "ls ${testDir_acl03}" "no" "no"
	TestRetParse_LTFLIB "可以查看目录内容 ${testFile_acl03}" "False"
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
