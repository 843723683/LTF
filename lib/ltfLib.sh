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
	printf "#  \033[1m\033[;35m %s \033[0m\n\n" "$1"
}


## TODO : 环境检测,用户探测当前环境中特殊设置
EnvTest_LTFLIB(){
	source "${LIB_UTILS}"

	# 打印标题
	if [ "Z${Title_Env_LTFLIB}" != "Z" -a "Z${Title_Env_LTFLIB}" != "Z " ];then
		USAGE_LTFLIB "${Title_Env_LTFLIB}"
	fi

	# 针对Commands测试
	if [ "Z${CmdsExist_Env_LTFLIB}" != "Z" -a "Z${CmdsExist_Env_LTFLIB}" != "Z " ];then
		Command_isExist_utils ${CmdsExist_Env_LTFLIB}
		TestRetParse_LTFLIB
	fi
}

## TODO : 注册函数，用于注册：Init,Run,Clean 函数
#    $1 : Init函数名,用于初始化调用
#    $2 : Run函数名，测试用例集调用
#    $3 : Clean函数名，垃圾回收调用
RegFunc_LTFLIB(){
        # 判断是否提供三个函数
        if [ $# -ne "3" ];then
                TConf_LLE "RegisterFunc_SCRT 参数传递错误"
                return $TCONF;
        fi

        readonly regInitFunc="$1"
        readonly regRunFunc="$2"
        readonly regClnFunc="$3"

        return $TPASS;
}


## TODO : 测试主函数
Main_LTFLIB(){
	# 环境检测
	EnvTest_LTFLIB
	TestRetParse_LTFLIB

	# 注册函数
	RegFunc_LTFLIB "TestInit" "Testsuite" "TestClean"
	TestRetParse_LTFLIB

	# 初始化
	Init_NEW_LTFLIB
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
        if [ "Z${regRunFunc}" == "Z" ];then
                TConf_LLE "未指定测试用例集"
		return $TCONF
        else
                # 执行运行测试用例集
                eval ${regRunFunc}
		return $?
        fi
}


## TODO : 新版初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Init_NEW_LTFLIB(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		TConf_LEE "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'OnCtrlC_LTFLIB' INT

	# 创建临时测试目录
	local testfile=$(basename ${0})
	TmpTestDir_LTFLIB="${TMP_ROOT_LTF}/ltf_${testfile%%.sh}"
	if [ -d  ${TmpTestDir_LTFLIB} ];then
		rm -rf ${TmpTestDir_LTFLIB}
	fi
	mkdir -p ${TmpTestDir_LTFLIB}
	export TmpTestDir_LTFLIB

	# 结果判断
	RetFlag_LTFLIB=${TPASS}

        # 判断是否指定初始化函数
        if [ "Z${regInitFunc}" == "Z" ];then
                TConf_LLE "未指定初始化函数"
		return $TCONF
        else
                # 执行初始化函数
                eval ${regInitFunc}
		return $?
        fi
}


## TODO : 测试前的初始化，老版初始化函数，兼容SOP相关脚本
#    Out: 
#         0=> TPASS
#         1=> TFAIL
#         other=> TCONF
Init_LTFLIB(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		TConf_LLE "Must use root"
		exit ${TCONF}
	fi

	# 定义清除函数
	regClnFunc=""

	# 信号捕获ctrl+c
	trap 'OnCtrlC_LTFLIB' INT
	
	# 结果判断
	RetFlag_LTFLIB=${TPASS}
}


## TODO: 清除操作
#
Clean_LTFLIB(){
	# 判断是否指定清除操作
	if [ "Z${regClnFunc}" == "Z" ];then
		TConf_LLE "未指定清除函数"
	else
		# 执行清除函数
		eval ${regClnFunc}		
	fi
	
	# 删除临时目录
	if [ -d  ${TmpTestDir_LTFLIB} ];then
		rm -rf ${TmpTestDir_LTFLIB}
	fi
}


## TODO : 测试前的初始化 
#     In: $1 => 清除函数名
SetFuncOnCtrlC_LTFLIB(){
	regClnFunc="$1"
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
	local retflag=${RetFlag_LTFLIB}
	# 结果标示复位
	RetFlag_LTFLIB=${TPASS}

	# 调用清除函数
	Clean_LTFLIB

	if [ $# -eq "1" -a "$1" != "${TPASS}" ];then
		exit ${1}
	fi
	
	if [ ${retflag} != ${TPASS} ];then
		exit ${retflag}
	fi

	exit ${TPASS}
}


## TODO: 解析 执行命令返回值，用于处理外部执行命令，0->成功，其他->失败。与TestRetParse_LTFLIB不同在于只判断对错。
#  In  : $1 => log
#        $2 => 是否退出测试，False->不退出,其他->退出。默认为空退出程序
#        $3 => 结果是否反转测试,yes->反转,no->不反转,默认为no不反转.(TPASS->TFAIL ,TFAIL-TPASS)
CommRetParse_LTFLIB(){
	# 必须第一位
	local ret=$?

	local logstr=""
	local exitflag="true"
	local reverse="no"

	if [ $# -eq 0 ];then
		true
	elif [ $# -eq 1 ];then
		logstr="$1"
	elif [ $# -eq 2 ];then
		logstr="$1"
		exitflag="$2"
	elif [ $# -eq 3 ];then
		logstr="$1"
		exitflag="$2"
		reverse="$3"
	else
		Error_LLE "TestRetParse_LTFLIB :invalid option -- $*($#)"
		# 退出
		Exit_LTFLIB ${ERROR}
	fi

	if [ "Z${reverse}" == "Zyes" -a "Z${ret}" == "Z0" ];then
		ret=${TFAIL}
	elif [ "Z${reverse}" == "Zyes" -a "Z${ret}" != "Z0" ];then
		ret=${TPASS}
	elif [ "Z${reverse}" != "Zyes" -a "Z${ret}" == "Z0" ];then
		ret=${TPASS}
	else
		ret=${TFAIL}
	fi

	if [ $ret -eq ${TPASS} ];then
		# 成功
		TPass_LLE "${logstr}"
		return ${TPASS}
	else
		RetFlag_LTFLIB=${TFAIL}		
		# 失败
		TFail_LLE "${logstr}"
	fi
	
	if [ "Z${exitflag}" == "ZFalse"  ];then
		# 继续执行
		return ${ret}
	else
		# 退出
		Exit_LTFLIB ${ret}
	fi
}

## TODO: 解析 函数返回值,用于处理内部函数或命令，$?只能是LTF中注册状态${TPASS}等。
#  In  : $1 => log
#        $2 => 是否退出测试，False->不退出,其他->退出.默认为空退出程序
#        $3 => 结果是否反转测试,yes->反转,no->不反转,默认为no不反转.(TPASS->TFAIL ,TFAIL-TPASS)
TestRetParse_LTFLIB(){
	# 必须第一位
	local ret=$?

	local logstr=""
	local exitflag="true"
	local reverse="no"

	if [ $# -eq 0 ];then
		true
	elif [ $# -eq 1 ];then
		logstr="$1"
	elif [ $# -eq 2 ];then
		logstr="$1"
		exitflag="$2"
	elif [ $# -eq 3 ];then
		logstr="$1"
		exitflag="$2"
		reverse="$3"
	else
		Error_LLE "TestRetParse_LTFLIB :invalid option -- $*($#)"
		# 退出
		Exit_LTFLIB ${ERROR}
	fi

	if [ "Z${reverse}" == "Zyes" -a "Z${ret}" == "Z${TPASS}" ];then
		ret=${TFAIL}
	elif [ "Z${reverse}" == "Zyes" -a "Z${ret}" == "Z${TFAIL}" ];then
		ret=${TPASS}
	fi

	if [ $ret -eq ${TPASS} ];then
		# 成功
		TPass_LLE "${logstr}"
		return ${TPASS}
	elif [ $ret -eq ${TFAIL} ];then
		RetFlag_LTFLIB=${TFAIL}		
		# 失败
		TFail_LLE "${logstr}"
	elif [ $ret -eq ${TCONF} ];then
		if [ "Z${RetFlag_LTFLIB}" != "Z${TFAIL}" ];then
			RetFlag_LTFLIB=${TCONF}
		fi
		# 阻塞
		TConf_LLE "${logstr}"
	else
		Error_LLE "异常状态:ret=$ret,${logstr}"
		# 退出
		Exit_LTFLIB ${ERROR}
	fi
	
	if [ "Z${exitflag}" == "ZFalse"  ];then
		# 继续执行
		return ${ret}
	else
		# 退出
		Exit_LTFLIB ${ret}
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
	local flag=$1

	if [ $flag -eq ${TPASS} ];then
		return ${TPASS}
	elif [ $flag -eq ${TFAIL} ];then
		return ${TFAIL}
	elif [ $flag -eq ${TCONF} ];then
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
