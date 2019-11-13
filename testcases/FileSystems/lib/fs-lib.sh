#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   fs-lib.sh
# Version:    1.0
# Date:       2019/10/12
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   定义用于文件系统测试常用变量和函数
# ----------------------------------------------------------------------
readonly TPASS=0
readonly TFAIL=1
readonly TCONF=2

# FS测试临时目录
readonly FSTESTDIR="/var/tmp"


## TODO: 用户界面
#    In: $1 => 字符串文字
FileUSAGE_FSLIB(){
	cat >&1 <<EOF
--------- $1 ---------
EOF
}


## TODO : 测试前的初始化 
#     In: $1 => 清除函数名
#    Out: 
#        0=> Success
#        1=> Fail
#        other=> TCONF
FileInit_FSLIB(){
	# 判断是否传入清除函数
	if [ $# -ne 1 ];then
		echo "Fail : Must specify \"clean function!\""
		exit ${TCONF}
	else
		# 定义清除函数
		fileClean_fslib="$1"
	fi

	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'FileOnCtrlC_FSLIB' INT
	
	# 结果判断
	fsRet_fslib=${TPASS}
}


## TODO: 解析函数返回值,当不为"False"时则退出(为空也退出)
#  In  : $1 => log
#        $2 => 是否退出测试，False为不退出
FileRetParse_FSLIB(){
	local ret=$?
	local logstr=""
	local flag=""

	if [ $# -eq 1 ];then
		logstr="$1"
	elif [ $# -eq 2 ];then
		logstr="$1"
		flag="$2"
	fi

	if [ $ret -eq 0 ];then
		# 成功
		echo "[pass] : ${logstr}"
	else
		# 失败
		fsRet_fslib=${TFAIL}		
	
		echo "[fail] : ${logstr}"
		if [ "Z${flag}" == "ZFalse"  ];then
			# 继续执行
			return ${TFAIL}
		else
			# 退出
			FileExit_FSLIB
		fi
	fi
}


## TODO: 调用程序退出函数
#    In: $1 => 调用脚本结果值
FileExit_FSLIB(){
	# 调用清除函数
	FileClean_FSLIB

	if [ $# -eq "1" -a "$1" != "${TPASS}" ];then
		exit ${1}
	fi
	
	if [ ${fsRet_fslib} != ${TPASS} ];then
		exit ${fsRet_fslib}
	fi

	exit ${TPASS}
}


## TODO: ctrl+c之后自动步骤
#   Out: 
#       Success => TPASS 
#       Failed  => TFAIL
#       Conf    => TCONF
FileOnCtrlC_FSLIB(){
	echo "正在优雅的退出..."

	# ctrl+c退出
	FileExit_FSLIB
}


## TODO: 清除操作
#
FileClean_FSLIB(){
	# 判断是否指定清除操作
	if [ "Z${fileClean_fslib}" == "Z" ];then
		echo "TCONF: 未指定清除函数"
	else
		# 执行清除函数
		eval ${fileClean_fslib}		
	fi
}


# 外部变量
export TPASS
export TFAIL
export TCONF

export FSTESTDIR
