#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   03-pam.sh
# Version:    1.0
# Date:       2021/06/28
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/28
# Function:   pam - 03 身份鉴别测试 - 禁止普通用户切换超级用户 
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------


Title_Env_LTFLIB="身份鉴别测试 - 禁止普通用户切换超级用户" 

testuser1_pam03="ltfpam03"
passwd1_pam03="olleH717.12.#$"
userip_pam03="localhost"
AddUserNames_LTFLIB="${testuser1_pam03}"
AddUserPasswds_LTFLIB="${passwd1_pam03}"

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

	# 配置免密登录
	SshAuto_OneConfig_LTFLIB "${userip_pam03}" "${testuser1_pam03}" "${passwd1_pam03}"
	TestRetParse_LTFLIB "配置免密登录" "True" "no" "yes"

	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){

	return $TPASS
}


## TODO  : 本地(localhost)用户(普通用户)执行命令        
#    In  : $1 => 执行命令                                                                     
#          $2 => 是否静默输出 yes -> 静默 no -> 打印输出 
#          $3 => 是否反转测试 yes -> 反转 no -> 不反转 
Local_Ord_Command(){                                                                     
        if [ $# -ne 3 ];then
		OutputRet_LTFLIB ${ERROR}
		TestRetParse_LTFLIB "NoAllowedCommand_SOPORD 参数错误"
        fi
	SshAuto_Command_LTFLIB "${userip_pam03}" "${testuser1_pam03}" "$1" "$2" "$3"

        return $? 
}


## TODO :
testcase_1(){
	Local_Ord_Command "su -" "no" "yes"
	CommRetParse_LTFLIB "普通用户 ${testuser1_pam03} 无法切换到root用户"
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
