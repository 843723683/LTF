#!/bin/bash

# unbound exit
set -u

readonly TPASS=0
readonly TFAIL=1
readonly TCONF=2

# Test Directory
CMDTESTROOT_GJB="/var/tmp"
CMDTESTDIR_GJB="${CMDTESTROOT_GJB}/test-ex-gjb"

# Exists commands
CMDEXISTS_GJB=("NONE")
# Result Flag
CMDRETFLAG_GJB="${TPASS}"


# All commands
readonly COMMANDS="alias bg command fc fg getopts hash jobs read type\
		       ulimit umask unalias wait"

#----------------------------------------------------------------------------#

## TODO : Determine if the command exists
#   Out : TPASS => success
#         TFAIL => failed
#         TCONF => conf
CMDExistTest_GJB(){
	local ret=${TPASS}
	# Command that does not exit
	local failstr=""
	# Number of Commands
	local sum=0
	local cmd=""
	for cmd in $COMMANDS
	do
		let sum=sum+1
		which ${cmd} > /dev/null 2>&1
                if [ $? -eq 0 ];then
			CMDEXISTS_GJB=("${CMDEXISTS_GJB[@]}" ${cmd})
			continue
                fi

		type ${cmd} > /dev/null 2>&1
		if [ $? -eq 0 ];then
			CMDEXISTS_GJB=("${CMDEXISTS_GJB[@]}" ${cmd})
			continue
		fi
		
		# Can't found command	
		ret=${TFAIL}
		failstr="${failstr} ${cmd}"
	done

	[ "Z$failstr" != "Z" ] && echo "Can't found commands : $failstr"
	echo "Commands Total : $sum"

	return ${ret}
}


## TODO : Run testcases
#    In : command name
CMDRunTest_GJB(){
	if [ $# -ne 1 ];then
		return ${TCONF}
	fi

	local ret=${TPASS}

	# Run testcases function
	local cmdname="$1"
	if [ "${cmdname}" == "[" ];then
		# Special characters "["
		CMDTest_brackets_GJB
		ret=$?
	else
		# Determine if the function has been defined
		if [ "$(type -t CMDTest_${cmdname}_GJB)" == "function" ];then
			# defined
			eval CMDTest_${cmdname}_GJB ${cmdname}
			ret=$?
		else
			# undefined
			echo "CMDTest_${cmdname}_GJB : Can't found function "
			return ${TCONF}
		fi
	fi

	return ${ret}
}


## TODO     : 1 - alias 设置命令别名以用来简化一些较长的命令
#  Function : -p => 以可重用的格式打印所有定义的别名 
CMDTest_alias_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -p 
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 2 - bg 后台暂停的命令，变成继续执行(继续在后台运行)
#  Function :  
CMDTest_bg_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	# 默认没有判断结果，因为如果没后台执行，会报错	
	${cmd}

	return ${TPASS}
}


## TODO     : 3 - command 
#  Function : -p => 为PATH使用默认值，以确保找到所有标准实用程序
#           : -v => 打印每个命令的详细说明
#           : -V => 打印命令的描述，类似于内置的“类型”
CMDTest_command_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -p ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -v ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -V ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 4 - fc 显示历史命令
#  Function : -l => 列出了历史文件中的命令。不调用编辑器去修改它们
#           : -r => 逆转所列出命令的顺序（当使用 -l 标志）或者逆转所编辑的命令顺序（当没有指定 -l 标志时）
#           : -n => 当与 -l 标志一起使用时，隐藏命令编号
CMDTest_fc_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -lr > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -ln > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 5 - fg 将后台中的命令调至前台继续运行
#  Function :  
CMDTest_fg_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	# 默认没有判断结果，因为如果没后台执行，会报错	
	${cmd}

	return ${TPASS}
}


## TODO     : 6 - getopts 命令行参数解析
#  Function : -hva => 自定义参数 
CMDTest_getopts_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        local tmpfile="tmpfile"
        touch ${tmpfile}
        cat > ${tmpfile} << EOF
#!/bin/bash

while getopts hva opt
do
	case "\${opt}" in
	h)
		echo "help"
		;;
	v)
		echo "version"
		;;
	a)
		echo "all"
		;;
	esac
done

exit 0
EOF
        chmod a+x ${tmpfile}

	${CMDTESTDIR_GJB}/${tmpfile} -h -v -a > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 7 - hash 记录或报告命令路径名
#  Function : -l => 查看hash表的内容
#           : -d => 清除其中的某一条
#           : -r => 清除hash表，清除的是全部的
CMDTest_hash_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	ls > /dev/null
	${cmd} -l > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -d ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -r > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 8 - jobs 显示Linux中的任务列表及任务状态
#  Function : -l => 显示进程号
#           : -r => 仅输出运行状态（running）的任务
#           : -s => 仅输出停止状态（stoped）的任务
CMDTest_jobs_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -l > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -r > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -s > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 9 - read 从标准输入读取数值
#  Function : -t => 后面跟秒数，定义输入字符的等待时间
#           : -e => 在输入的时候可以使用命令补全功能
#           : -a => 后跟一个变量，该变量会被认为是个数组，然后给其赋值，默认是以空格为分割符
CMDTest_read_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	local tmparr=""
	${cmd} -t 5 -e -a tmparr <<< helloworld
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 10 - type 显示指定命令的类型
#  Function : -a => 如果给出的指令为外部指令，则显示其绝对路径
#           : -P => 输出“file”、“alias”或者“builtin”，分别表示给定的指令为“外部指令”、“命令别名”或者“内部指令”
#           : -t => 输出“file”、“alias”或者“builtin”，分别表示给定的指令为“外部指令”、“命令别名”或者“内部指令”
CMDTest_type_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -a ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -P ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -t ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 11 - ulimit
#  Function : -a => 显示当前所有的资源限制
#           : -c => 设置core文件的最大值
#           : -n => 设置内核可以同时打开的文件描述符的最大值
CMDTest_ulimit_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -a > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -c > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -n > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 12 - umask 返回或设置系统文件模式创建掩码的值
#  Function : -p => 打印当前umask值
#           : -S => 接受或返回一个代表掩码的符号
CMDTest_umask_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -p > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -S > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 13 - unalias 取消别名
#  Function :  
CMDTest_unalias_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	local tmpcmd=""
	alias tmpcmd='cd ~'
	${cmd} tmpcmd
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 14 - wait 等待作业结束运行
#  Function : 
CMDTest_wait_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	sleep 2 &
	${cmd}
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


### TODO     :  - 
##  Function :  
#CMDTest_a_GJB(){
#	# Determine if the parameters are correct
#	if [ $# -ne 1 ];then
#		echo "Parameters error"
#		return ${TONF}
#	fi
#	local cmd="$1"
#
#	${cmd}
#	[ $? -ne 0 ] && return ${TFAIL}
#
#	return ${TCONF}
#}


#----------------------------------------------------------------------------#


## TODO: 使用ctrl+c退出
#
CMDOnCtrlC_GJB(){
	echo "正在优雅的退出..."
	CMDClean_GJB

	exit ${TCONF}
}


## TODO : Init
#
CMDInit_GJB(){
	# root!
	if [ $(id -u) -ne 0 ];then
		echo "Operation not permitted"
		return ${TCONF}
	fi

	# Determine if there is a test root directory
	if [ ! -d "${CMDTESTROOT_GJB}" ];then
		echo "Init Error : Can't found ${CMDTESTROOT_GJB}"
		return ${TCONF}
	fi

	# Determine if there is a test directory
	if [ -d "${CMDTESTDIR_GJB}" ];then
		rm -rf ${CMDTESTDIR_GJB}
		if [ $? -ne 0 ];then
			 echo "${CMDTESTDIR_GJB} : Failed to rm directory"
			 return ${TCONF}
		fi
	fi
	
	mkdir -p ${CMDTESTDIR_GJB}
	if [ $? -ne 0 ];then
		 echo "${CMDTESTDIR_GJB} : Failed to create directory"
		 return ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'CMDOnCtrlC_GJB' INT

	return ${TPASS}
}


## TODO : Empty directory
#
CMDCleanEmpty_GJB(){
	if [ -d "${CMDTESTDIR_GJB}" ];then
		rm -rf ${CMDTESTDIR_GJB}/*
		if [ $? -ne 0 ];then
			 echo "${CMDTESTDIR_GJB} : Failed to rm ${CMDTESTDIR_GJB}/*"
			 return ${TCONF}
		fi
	fi
	
	return ${TPASS}
}


## TODO : delete directory
#
CMDClean_GJB(){
	if [ -d "${CMDTESTDIR_GJB}" ];then
		rm -rf ${CMDTESTDIR_GJB}
		if [ $? -ne 0 ];then
			 echo "${CMDTESTDIR_GJB} : Failed to rm directory"
			 return ${TCONF}
		fi
	fi
}


## TODO : Return value analysis
#    In : $1 => string log
#         $2 => False:Do not exit
CMDRetAna_GJB(){
	local ret=$?
	local strlog="$1"

	local flag=""
	if [ $# -eq 2 ];then
		flag="$2"
	fi

	if [ $ret -eq ${TPASS} ];then
		echo "[ TPASS ] ${strlog}"
	elif [ $ret -eq ${TFAIL} ];then
		echo "[ TFAIL ] ${strlog}"
		CMDRETFLAG_GJB=${ret}
		if [ "Z${flag}" != "ZFalse" ];then
			CMDClean_GJB
			exit ${CMDRETFLAG_GJB}
		fi
	else
		echo "[ TCONF ] ${strlog}"
		CMDRETFLAG_GJB=${TCONF}
		if [ "Z${flag}" != "ZFalse" ];then
			CMDClean_GJB
			exit ${CMDRETFLAG_GJB}
		fi
	fi
}


## TODO : Main
#
CMDMain_GJB(){
	CMDInit_GJB
	CMDRetAna_GJB "Init"

	CMDExistTest_GJB
	CMDRetAna_GJB "Commands exists" "False"

	local index=0
	local border=0
	let border=${#CMDEXISTS_GJB[@]}-1

	for index in $(seq 1 ${border})
	do
		# Run test
		CMDRunTest_GJB ${CMDEXISTS_GJB[${index}]}
		#CMDRetAna_GJB "${CMDEXISTS_GJB[${index}]}" "False"
		CMDRetAna_GJB "[ $index ] : ${CMDEXISTS_GJB[${index}]}"

		CMDCleanEmpty_GJB
	done

	CMDClean_GJB
	CMDRetAna_GJB "Clean ${CMDTESTDIR_GJB}"
}

CMDMain_GJB
exit ${CMDRETFLAG_GJB}
