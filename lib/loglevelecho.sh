#!/usr/bin/env bash


################################################################

readonly TPASS=0
readonly TFAIL=1
readonly TCONF=2
readonly ERROR=3

## TODO : 日志级别输出函数
#   In  : $1 => 日志级别
#         $2 => 颜色
#         $3 => 打印字符串
#   Out : 0 => Success
Log_LLE(){
	[ $# -ne 3 ] && return 1
	local infolevel=$1
	local color=$2
	local logstr="$3"

	# 当前日志级别
#	LOGLEVEL_LLE="debug"
	LOGLEVEL_LLE="release"

	# 结束颜色
	local ENDCOLOR_LLE="\033[0m"

	case $infolevel in
	DEBUG)
		if [ "$LOGLEVEL_LLE" == "debug" ];then
			echo -e "$color $logstr $ENDCOLOR_LLE"		
		fi
	;;
	INFO)
		echo -e " $logstr"
	;;
	TPASS)
		echo -e "$color $logstr $ENDCOLOR_LLE"		
	;;
	TCONF)
		echo -e "$color $logstr $ENDCOLOR_LLE"		
	;;
	TFAIL)
		echo -e "$color $logstr $ENDCOLOR_LLE"		
	;;
	ERROR)
		echo -e "$color $logstr $ENDCOLOR_LLE"		
	;;
	esac
	
	return 0
}


## TODO : Debug级别输出函数,默认颜色为 蓝色
#   In  : $1 => 打印字符串
Debug_LLE(){
	local logstr="$1"

	local BLUE_LLE="\033[34m"

	if [ "Z${logstr}" != "Z"  ];then
		Log_LLE "DEBUG"	"${BLUE_LLE}" "[ DEBUG ][$(basename $0)]: ${logstr}"
#		Log_LLE "DEBUG"	"${BLUE_LLE}" "[ DEBUG ][$(basename $0)][`date +'%F %H:%M:%S'`]: ${logstr}"
	fi
}


## TODO : Info级别输出函数,默认无颜色
#   In  : $1 => 打印字符串
Info_LLE(){
	local logstr="$1"

	if [ "Z${logstr}" != "Z"  ];then
		Log_LLE "INFO"	"NONE " "${logstr}"
#		Log_LLE "INFO"	"NONE " "[ INFO ][`date +'%F %H:%M:%S'`]: ${logstr}"
	fi
}


## TODO : TPASS 级别输出函数,默认颜色为 绿色
#   In  : $1 => 打印字符串
TPass_LLE(){
	local logstr="$1"

	local GREEN_LLE="\033[32m"

	if [ "Z${logstr}" != "Z"  ];then
		Log_LLE "TPASS"	"${GREEN_LLE}" "[pass]: ${logstr}"
#		Log_LLE "TPASS"	"${GREEN_LLE}" "[ TPASS ][`date +'%F %H:%M:%S'`]: ${logstr}"
	fi
}


## TODO : TCONF 级别输出函数,默认颜色为 黄色
##  In  : $1 => 打印字符串
TConf_LLE(){
	local logstr="$1"

	local YELLOW_LLE="\033[33m"

	if [ "Z${logstr}" != "Z"  ];then
		Log_LLE "TCONF"	"${YELLOW_LLE}" "[conf]: ${logstr}"
#		Log_LLE "TCONF"	"${YELLOW_LLE}" "[ TCONF ][`date +'%F %H:%M:%S'`]: ${logstr}"
	fi
}


## TODO : TFAIL级别输出函数,默认颜色为 红色
#   In  : $1 => 打印字符串
TFail_LLE(){
	local logstr="$1"

	local RED_LLE="\033[31m"

	if [ "Z${logstr}" != "Z"  ];then
		Log_LLE "TFAIL"	"${RED_LLE}" "[fail]: ${logstr}"
#		Log_LLE "TFAIL"	"${RED_LLE}" "[ TFAIL ][`date +'%F %H:%M:%S'`]: ${logstr}"
	fi
}


## TODO : Error级别输出函数,默认颜色为 红色
#   In  : $1 => 打印字符串
Error_LLE(){
	local logstr="$1"

	local RED_LLE="\033[31m"

	if [ "Z${logstr}" != "Z"  ];then
		Log_LLE "ERROR"	"${RED_LLE}" "[error]: ${logstr}"
	fi
}


## TODO : 整体结果日志，主要用于测试文件对错输出
#   In  : $1 => TPASS,TFAIL,TCONF,ERROR
#         $2 => 打印字符串
OverallLog_LLE(){
	local ret=$1
	local logstr=$2

	if [ "Z${logstr}" == "Z"  ];then
		return ${TPASS}
	fi

	if [ $ret -eq ${TPASS} ];then
		local GREEN_LLE="\033[32m"
		Log_LLE "TPASS"	"${GREEN_LLE}" "[ Test PASS ]: ${logstr}"
	elif [ $ret -eq ${TFAIL} ];then
		local RED_LLE="\033[31m"
		Log_LLE "TFAIL"	"${RED_LLE}" "[ Test FAIL ]: ${logstr}"
	elif [ $ret -eq ${TCONF} ];then
		local YELLOW_LLE="\033[33m"
		Log_LLE "TCONF"	"${YELLOW_LLE}" "[ Test CONF ]: ${logstr}"
	else
		local RED_LLE="\033[31m"
		Log_LLE "ERROR"	"${RED_LLE}" "[ Test ERROR ]: ${logstr}"
	fi
}


# 外部变量
export TPASS
export TFAIL
export TCONF
export ERROR 

export -f Log_LLE

export -f Debug_LLE
export -f Info_LLE
export -f Error_LLE 
export -f TPass_LLE
export -f TFail_LLE
export -f TConf_LLE
export -f OverallLog_LLE 

# Debug-LLE "hello debug"
# TPass-LLE "hello info"
# TFail-LLE "hello warn"
# TConf-LLE "hello error"
