#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename   :  ltfLib.sh
# Version    :  1.0
# Date       :  2020/05/26
# Author     :  Lz
# Email      :  lz843723683@gmail.com
# History    :     
#               Version 1.0, 2020/05/26
# Function   :  定义用于LTF测试常用变量和函数
# ----------------------------------------------------------------------

## TODO: 用户界面
#    In: $1 => 字符串文字
USAGE_LTFLIB(){
	local tmpsign_ltflib="###############################################"
	printf "\033[1m\033[;35m%s \033[0m\n" "${tmpsign_ltflib}"
	printf "\033[1m\033[;35m#  %s \033[0m\n" "$1"
	printf "\033[1m\033[;35m%s \033[0m\n\n" "${tmpsign_ltflib}"
}


## TODO : 环境检测,用户探测当前环境中特殊设置
#	 标题变量:Title_Env_LTFLIB
#	 命令判断变量:CmdsExist_Env_LTFLIB
#	 新增用户变量:AddUserNames_LTFLIB
#	 新增用户密码:AddUserPasswds_LTFLIB
EnvTest_LTFLIB(){
	source "${LIB_UTILS}"


	# 打印标题
	if [ "Z${Title_Env_LTFLIB}" != "Z" -a "Z${Title_Env_LTFLIB}" != "Z " ];then
		USAGE_LTFLIB "${Title_Env_LTFLIB}"
	fi

	# 判断命令是否存在
	if [ "Z${CmdsExist_Env_LTFLIB}" != "Z" -a "Z${CmdsExist_Env_LTFLIB}" != "Z " ];then
		Command_isExist_utils ${CmdsExist_Env_LTFLIB}
		TestRetParse_LTFLIB
	fi

	# 判断是否需要新建用户
	if [ "Z${AddUserNames_LTFLIB}" != "Z" -a "Z${AddUserNames_LTFLIB}" != "Z " ];then

		# 密码字符串转化为数组
		local passwdArr_ltflib=()
		if [ "Z${AddUserPasswds_LTFLIB}" != "Z" -a "Z${AddUserPasswds_LTFLIB}" != "Z " ];then
			local i_ltflib=""
			for i_ltflib in ${AddUserPasswds_LTFLIB}
			do
				passwdArr_ltflib[${#passwdArr_ltflib[@]}]=${i_ltflib}
			done
		fi 

		local user_ltflib=""
		local count_ltflib=0
		for user_ltflib in ${AddUserNames_LTFLIB[@]} 
		do
		        sudo useradd ${user_ltflib}>/dev/null
        		CommRetParse_FailDiy_LTFLIB ${ERROR} "sudo useradd ${user_ltflib}"
			if [ "${#passwdArr_ltflib[@]}" -ne 0 ];then
			        # 设置密码
				local passwd_ltflib=${passwdArr_ltflib[${count_ltflib}]}
				unset passwdArr_ltflib[${count_ltflib}]
			        echo ${passwd_ltflib} | sudo passwd --stdin ${user_ltflib} >/dev/null
			        CommRetParse_FailDiy_LTFLIB ${ERROR} "echo ${passwd_ltflib} | sudo passwd --stdin ${user_ltflib}"
			fi
			let count_ltflib=count_ltflib+1
		done
	fi
}

## TODO : 注册函数，用于注册：Init,Run,Clean 函数
#    $1 : Init函数名,用于初始化调用
#    $2 : Run函数名，测试用例集调用
#    $3 : Clean函数名，垃圾回收调用
RegFunc_LTFLIB(){
        # 判断是否提供三个函数
        if [ $# -ne "3" ];then
                TConf_LLE "RegisterFunc_LTFLIB 参数传递错误"
                return $TCONF;
        fi

        readonly regInitFunc_ltflib="$1"
        readonly regRunFunc_ltflib="$2"
        readonly regClnFunc_ltflib="$3"

        return $TPASS;
}


## TODO : 测试主函数
Main_LTFLIB(){
	# 环境检测
	EnvTest_LTFLIB
	TestRetParse_LTFLIB

	# 注册函数
	RegFunc_LTFLIB "TestInit_LTFLIB" "Testsuite_LTFLIB" "TestClean_LTFLIB"
	TestRetParse_LTFLIB

	# 初始化
	Init_LTFLIB
	TestRetParse_LTFLIB

	# 运行测试用例集
	Run_LTFLIB
	TestRetParse_LTFLIB

	# 垃圾回收
	# Clean_LTFLIB

	# 执行退出
	Exit_LTFLIB 
}


## TODO ：运行测试
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Run_LTFLIB(){
        # 判断是否指定测试用例集
        if [ "Z${regRunFunc_ltflib}" == "Z" ];then
                TConf_LLE "未指定测试用例集"
		return $TCONF
        else
                # 执行运行测试用例集
                eval ${regRunFunc_ltflib}
		return $?
        fi
}


## TODO : 测试前的初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Init_LTFLIB(){
	# 判断root用户
#	if [ `id -u` -ne 0 ];then
#		TConf_LEE "Must use root ！"
#		exit ${TCONF}
#	fi

	# 信号捕获ctrl+c
	trap 'OnCtrlC_LTFLIB' INT

	# 创建临时测试目录
	local testfile_ltflib=$(basename ${0})
	TmpTestDir_LTFLIB="${TMP_ROOT_LTF}/ltf_${testfile_ltflib%%.sh}"
	if [ -d  ${TmpTestDir_LTFLIB} ];then
		rm -rf ${TmpTestDir_LTFLIB}
	fi
	mkdir -p ${TmpTestDir_LTFLIB}
	chmod 777 ${TmpTestDir_LTFLIB}
	export TmpTestDir_LTFLIB

	# 结果判断
	RetFlag_LTFLIB=${TPASS}

        # 判断是否指定初始化函数
        if [ "Z${regInitFunc_ltflib}" == "Z" ];then
                TConf_LLE "未指定初始化函数"
		return $TCONF
        else
                # 执行初始化函数
                eval ${regInitFunc_ltflib}
		return $?
        fi
}


## TODO: 清除操作
#
Clean_LTFLIB(){
	# 判断是否指定清除操作
	if [ "Z${regClnFunc_ltflib}" == "Z" ];then
		TConf_LLE "未指定清除函数"
	else
		# 执行清除函数
		eval ${regClnFunc_ltflib}		
	fi
	
	# 删除临时目录
	if [ -d  ${TmpTestDir_LTFLIB} ];then
		rm -rf ${TmpTestDir_LTFLIB}
	fi

	# 删除用户
	if [ "Z${AddUserNames_LTFLIB}" != "Z" -a "Z${AddUserNames_LTFLIB}" != "Z " ];then
		local user_ltflib=""
		for user_ltflib in ${AddUserNames_LTFLIB[@]} 
		do
			sudo cat /etc/passwd | grep ${user_ltflib} > /dev/null
			if [ $? -eq 0 ];then
		        	sudo userdel -rf  ${user_ltflib}>/dev/null
			fi
		done
	fi
}


## TODO : 测试前的初始化 
#     In: $1 => 清除函数名
SetFuncOnCtrlC_LTFLIB(){
	regClnFunc_ltflib="$1"
}


## TODO: ctrl+c之后自动步骤
#   Out: 
#       Success => TPASS 
#       Failed  => TFAIL
#       Conf    => TCONF
OnCtrlC_LTFLIB(){
	Error_LLE "异常终止,正在优雅的退出..."

	# ctrl+c退出
	Exit_LTFLIB ${ERROR}
}


## TODO: 终止退出函数
#    In: $1 => 调用脚本结果值
Exit_LTFLIB(){
	local retflag_ltflib=${RetFlag_LTFLIB}
	# 结果标示复位
	RetFlag_LTFLIB=${TPASS}

	# 调用清除函数
	Clean_LTFLIB

	if [ $# -eq "1" -a "$1" != "${TPASS}" ];then
		exit ${1}
	fi
	
	if [ ${retflag_ltflib} != ${TPASS} ];then
		exit ${retflag_ltflib}
	fi

	exit ${TPASS}
}


## TODO: 解析 执行命令返回值，用于处理外部执行命令。如果结果非0则转化为其他断言状态
#  In  : $1 => 转化后的状态(ERROR、TCONF等) 
#        $2 => log日志
#        $3 => 是否退出测试，False->不退出,其他->退出。默认为true退出程序
CommRetParse_FailDiy_LTFLIB(){
	# 必须第一行
	local ret_ltflib=$?
	
	local diy_ltflib=""
	local logstr_ltflib=""
	local exitflag_ltflib="true"
	if [ $# -eq 1 ];then
		diy_ltflib=$1	
	elif [ $# -eq 2 ];then
		diy_ltflib=$1
		logstr_ltflib=$2
	elif [ $# -eq 3 ];then
		diy_ltflib=$1
		logstr_ltflib=$2
		exitflag_ltflib=$3
	else
		OutputRet_LTFLIB ${ERROR}
		TestRetParse_LTFLIB "FailToOther_LTFLIB参数错误:$@"
	fi

	if [ ${ret_ltflib} -ne 0 ];then
		OutputRet_LTFLIB ${diy_ltflib}
		TestRetParse_LTFLIB "${logstr_ltflib}" "${exitflag_ltflib}"
	fi
}


## TODO: 解析 执行命令返回值，用于处理外部执行命令，0->成功，其他->失败。与TestRetParse_LTFLIB不同在于只判断对错。
#  In  : $1 => log
#        $2 => 是否退出测试，False->不退出,其他->退出。默认为true退出程序
#        $3 => 结果是否反转测试,yes->反转,no->不反转,默认为no不反转.(TPASS->TFAIL ,TFAIL-TPASS)
CommRetParse_LTFLIB(){
	# 必须第一位
	local ret_ltflib=$?

	local logstr_ltflib=""
	local exitflag_ltflib="true"
	local reverse_ltflib="no"

	if [ $# -eq 0 ];then
		true
	elif [ $# -eq 1 ];then
		logstr_ltflib="$1"
	elif [ $# -eq 2 ];then
		logstr_ltflib="$1"
		exitflag_ltflib="$2"
	elif [ $# -eq 3 ];then
		logstr_ltflib="$1"
		exitflag_ltflib="$2"
		reverse_ltflib="$3"
	else
		Error_LLE "TestRetParse_LTFLIB :invalid option -- $*($#)"
		# 退出
		Exit_LTFLIB ${ERROR}
	fi

	if [ "Z${reverse_ltflib}" == "Zyes" -a "Z${ret_ltflib}" == "Z0" ];then
		ret_ltflib=${TFAIL}
	elif [ "Z${reverse_ltflib}" == "Zyes" -a "Z${ret_ltflib}" != "Z0" ];then
		ret_ltflib=${TPASS}
	elif [ "Z${reverse_ltflib}" != "Zyes" -a "Z${ret_ltflib}" == "Z0" ];then
		ret_ltflib=${TPASS}
	else
		ret_ltflib=${TFAIL}
	fi

	if [ $ret_ltflib -eq ${TPASS} ];then
		# 成功
		TPass_LLE "${logstr_ltflib}"
		return ${TPASS}
	else
		RetFlag_LTFLIB=${TFAIL}		
		# 失败
		TFail_LLE "${logstr_ltflib}"
	fi
	
	if [ "Z${exitflag_ltflib}" == "ZFalse"  ];then
		# 继续执行
		return ${ret_ltflib}
	else
		# 退出
		Exit_LTFLIB ${ret_ltflib}
	fi
}

## TODO: 解析 函数返回值,用于处理内部函数或命令，$?只能是LTF中注册状态${TPASS}等。
#  In  : $1 => log
#        $2 => 是否退出测试，False->不退出,其他->退出.默认为true退出程序
#        $3 => 结果是否反转测试,yes->反转,no->不反转,默认为no不反转.(TPASS->TFAIL ,TFAIL-TPASS)
#        $4 => 是否静默输出 yes -> 静默 no -> 打印输出.默认为no
TestRetParse_LTFLIB(){
	# 必须第一位
	local ret_ltflib=$?

	local logstr_ltflib=""
	local exitflag_ltflib="true"
	local reverse_ltflib="no"
	local quiet_ltflib="no"

	if [ $# -eq 0 ];then
		true
	elif [ $# -eq 1 ];then
		logstr_ltflib="$1"
	elif [ $# -eq 2 ];then
		logstr_ltflib="$1"
		exitflag_ltflib="$2"
	elif [ $# -eq 3 ];then
		logstr_ltflib="$1"
		exitflag_ltflib="$2"
		reverse_ltflib="$3"
	elif [ $# -eq 4 ];then
		logstr_ltflib="$1"
		exitflag_ltflib="$2"
		reverse_ltflib="$3"
		quiet_ltflib="$4"
	else
		Error_LLE "TestRetParse_LTFLIB :invalid option -- $*($#)"
		# 退出
		Exit_LTFLIB ${ERROR}
	fi

	if [ "Z${reverse_ltflib}" == "Zyes" -a "Z${ret_ltflib}" == "Z${TPASS}" ];then
		ret_ltflib=${TFAIL}
	elif [ "Z${reverse_ltflib}" == "Zyes" -a "Z${ret_ltflib}" == "Z${TFAIL}" ];then
		ret_ltflib=${TPASS}
	fi

	if [ $ret_ltflib -eq ${TPASS} ];then
		# 成功
		if [ "Z${quiet_ltflib}" != "Zyes" ];then
			TPass_LLE "${logstr_ltflib}"
		fi
		return ${TPASS}
	elif [ $ret_ltflib -eq ${TFAIL} ];then
		RetFlag_LTFLIB=${TFAIL}		
		# 失败
		TFail_LLE "${logstr_ltflib}"
	elif [ $ret_ltflib -eq ${TCONF} ];then
		if [ "Z${RetFlag_LTFLIB}" != "Z${TFAIL}" ];then
			RetFlag_LTFLIB=${TCONF}
		fi
		# 阻塞
		TConf_LLE "${logstr_ltflib}"
	else
		Error_LLE "异常状态:ret=$ret_ltflib,${logstr_ltflib}"
		# 退出
		Exit_LTFLIB ${ERROR}
	fi
	
	if [ "Z${exitflag_ltflib}" == "ZFalse"  ];then
		# 继续执行
		return ${ret_ltflib}
	else
		# 退出
		Exit_LTFLIB ${ret_ltflib}
	fi
}


## TODO: 返回结果
#   In :
#	$1 => ${TPASS} / ${TFAIL} / ${TCONF}
#   Out:
#	$TPASS
#	$TFAIL
#	$TCONF
OutputRet_LTFLIB(){
	local flag_ltflib=$1

	if [ $flag_ltflib -eq ${TPASS} ];then
		return ${TPASS}
	elif [ $flag_ltflib -eq ${TFAIL} ];then
		return ${TFAIL}
	elif [ $flag_ltflib -eq ${TCONF} ];then
		return ${TCONF}
	else
		return ${ERROR}
	fi
}


#######################################################

# 外部函数
export -f Init_LTFLIB
export -f USAGE_LTFLIB
export -f SetFuncOnCtrlC_LTFLIB
export -f OutputRet_LTFLIB
export -f TestRetParse_LTFLIB
export -f CommRetParse_LTFLIB
export -f Exit_LTFLIB

export -f OnCtrlC_LTFLIB
export -f Clean_LTFLIB
