#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename   :  utils.sh 
# Version    :  1.0
# Date       :  2021/06/22
# Author     :  Lz
# Email      :  lz843723683@gmail.com
# History    :     
#               Version 1.0, 2021/06/22
# Function   :  常用工具函数 
# ----------------------------------------------------------------------


## TODO： 判断命令是否存在
#   in ： $1 => 测试命令
#         $2 => 会用到的命令
#   Out： 0 => TPASS
#         1 => TFAIL
Command_isExist_utils(){
        local command_util=""
        for command_util in "$@"
        do
                which $command_util >/dev/null 2>&1
                [ $? -ne 0 ] && { TConf_LLE "Command $command_util not exist!";return ${TCONF}; }
        done

	return ${TPASS}
}


