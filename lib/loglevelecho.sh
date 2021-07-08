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
	local infolevel_lle=$1
	local color_lle=$2
	local logstr_lle="$3"

	# 当前日志级别
#	LOGLEVEL_LLE="debug"
	LOGLEVEL_LLE="release"

	# 结束颜色
	local ENDCOLOR_LLE="\033[0m"

	case $infolevel_lle in
	DEBUG)
		if [ "$LOGLEVEL_LLE" == "debug" ];then
			echo -e "${color_lle}${logstr_lle} $ENDCOLOR_LLE"
		fi
	;;
	INFO)
		echo -e "${logstr_lle}"
	;;
	TPASS)
		echo -e "${color_lle}${logstr_lle} $ENDCOLOR_LLE"
	;;
	TCONF)
		echo -e "${color_lle}${logstr_lle} $ENDCOLOR_LLE"
	;;
	TFAIL)
		echo -e "${color_lle}${logstr_lle} $ENDCOLOR_LLE"
	;;
	ERROR)
		echo -e "${color_lle}${logstr_lle} $ENDCOLOR_LLE"
	;;
	esac
	
	return 0
}


## TODO : Debug级别输出函数,默认颜色为 蓝色
#   In  : $1 => 打印字符串
Debug_LLE(){
	local logstr_lle="$1"

	local BLUE_LLE="\033[34m"

	if [ "Z${logstr_lle}" != "Z"  ];then
		Log_LLE "DEBUG"	"${BLUE_LLE}" "[ DEBUG ][$(basename $0)]: ${logstr_lle}"
#		Log_LLE "DEBUG"	"${BLUE_LLE}" "[ DEBUG ][$(basename $0)][`date +'%F %H:%M:%S'`]: ${logstr_lle}"
	fi
}


## TODO : Info级别输出函数,默认无颜色
#   In  : $1 => 打印字符串
Info_LLE(){
	local logstr_lle="$1"

	if [ "Z${logstr_lle}" != "Z"  ];then
		Log_LLE "INFO"	"NONE " "${logstr_lle}"
#		Log_LLE "INFO"	"NONE " "[ INFO ][`date +'%F %H:%M:%S'`]: ${logstr_lle}"
	fi
}


## TODO : TPASS 级别输出函数,默认颜色为 绿色
#   In  : $1 => 打印字符串
TPass_LLE(){
	local logstr_lle="$1"

	local GREEN_LLE="\033[32m"

	if [ "Z${logstr_lle}" != "Z"  ];then
		Log_LLE "TPASS"	"${GREEN_LLE}" "[pass]: ${logstr_lle}"
#		Log_LLE "TPASS"	"${GREEN_LLE}" "[ TPASS ][`date +'%F %H:%M:%S'`]: ${logstr_lle}"
	fi
}


## TODO : TCONF 级别输出函数,默认颜色为 黄色
##  In  : $1 => 打印字符串
TConf_LLE(){
	local logstr_lle="$1"

	local YELLOW_LLE="\033[33m"

	if [ "Z${logstr_lle}" != "Z"  ];then
		Log_LLE "TCONF"	"${YELLOW_LLE}" "[conf]: ${logstr_lle}"
#		Log_LLE "TCONF"	"${YELLOW_LLE}" "[ TCONF ][`date +'%F %H:%M:%S'`]: ${logstr_lle}"
	fi
}


## TODO : TFAIL级别输出函数,默认颜色为 红色
#   In  : $1 => 打印字符串
TFail_LLE(){
	local logstr_lle="$1"

	local RED_LLE="\033[31m"

	if [ "Z${logstr_lle}" != "Z"  ];then
		Log_LLE "TFAIL"	"${RED_LLE}" "[fail]: ${logstr_lle}"
#		Log_LLE "TFAIL"	"${RED_LLE}" "[ TFAIL ][`date +'%F %H:%M:%S'`]: ${logstr_lle}"
	fi
}


## TODO : Error级别输出函数,默认颜色为 红色
#   In  : $1 => 打印字符串
Error_LLE(){
	local logstr_lle="$1"

	local RED_LLE="\033[31m"

	if [ "Z${logstr_lle}" != "Z"  ];then
		Log_LLE "ERROR"	"${RED_LLE}" "[error]: ${logstr_lle}"
	fi
}


## TODO : 整体结果日志，主要用于测试文件对错输出
#   In  : $1 => TPASS,TFAIL,TCONF,ERROR
#         $2 => 打印字符串
OverallLog_LLE(){
	local ret_lle=$1
	local logstr_lle=$2

	if [ "Z${logstr_lle}" == "Z"  ];then
		return ${ret_lle}
	fi

	if [ $ret_lle -eq ${TPASS} ];then
		local GREEN_LLE="\033[32m"
		Log_LLE "TPASS"	"${GREEN_LLE}" "\t\t${logstr_lle} [ Test PASS ]"
	elif [ $ret_lle -eq ${TFAIL} ];then
		local RED_LLE="\033[31m"
		Log_LLE "TFAIL"	"${RED_LLE}" "\t\t${logstr_lle} [ Test FAIL ]"
	elif [ $ret_lle -eq ${TCONF} ];then
		local YELLOW_LLE="\033[33m"
		Log_LLE "TCONF"	"${YELLOW_LLE}" "\t\t${logstr_lle} [ Test CONF ]"
	else
		local RED_LLE="\033[31m"
		Log_LLE "ERROR"	"${RED_LLE}" "\t\t${logstr_lle} [ Test ERROR ]"
	fi
}


## TODO : 根据$1和$2的值 返回断言标志，与OverallLog_LLE中保持一致
#         返回优先级 TFAIL > TCONF > ERROR >  TPASS
#   In  : $1 => 0～127
#         $2 => 第二个值，可以为空
RetToFlag_LLE(){
	local flag1_lle=""
	local flag2_lle=""
	if [ $# -eq 1 ];then
		flag1_lle=$1
		flag2_lle=${TPASS}
	elif [ $# -eq 2 ];then
		flag1_lle=$1
		flag2_lle=$2
	else
		return ${ERROR}
	fi

	if [ ${flag1_lle} -eq ${TFAIL} -o ${flag2_lle} -eq ${TFAIL} ];then
		return ${TFAIL}	
	elif [ ${flag1_lle} -eq ${TCONF} -o ${flag2_lle} -eq ${TCONF} ];then
		return ${TCONF}
	elif [ ${flag1_lle} -eq ${ERROR} -o ${flag2_lle} -eq ${ERROR} ];then
		return ${ERROR}
	elif [ ${flag1_lle} -eq ${TPASS} -a ${flag2_lle} -eq ${TPASS} ];then
		return ${TPASS}
        else
		return ${ERROR}
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
export -f RetToFlag_LLE

# Debug-LLE "hello debug"
# TPass-LLE "hello info"
# TFail-LLE "hello warn"
# TConf-LLE "hello error"
