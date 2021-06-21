#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   security.sh
# Version:    1.0
# Date:       2019/12/05
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/12/05
# Function:   调用不同的安全测试程序
# In :        Security testcase name(testcase dir name)
# Out:        
#              0 => TPASS
#              1 => TFAIL
#              2 => TCONF
# ----------------------------------------------------------------------

# unbound exit
set -u


## TODO : 测试前的初始化验证 
#  In   : $1 => testcase dir name
#  Out  : 
#         0 => TPASS
#         1 => TFAIL
#         2 => TCONF
Init_SCRT(){
	local testdir="$1"

	cd $(dirname $0)
	# Security 绝对路径
	ROOTPATH_SCRT="$(pwd)"
	
	# 加载config配置文件
	local tmpcfg="${ROOTPATH_SCRT}/config/security.cfg"
	if [ -f "${tmpcfg}" ];then
                source ${tmpcfg}
        else
                echo "${tmpcfg}: Can't found file !"
                return 2
        fi

#	# Security lib库文件 绝对路径
#	export LIBROOT_SCRT="${ROOTPATH_SCRT}/${LIBNAME_SCRT}"

	# 加载log文件
#	local tmplog="${LIBROOT_SCRT}/loglevelecho.sh"
#	if [ -f "${tmplog}" ];then
#		source ${tmplog}
#	else
#		echo "${tmplog}: Can't found file !"
#		return $TCONF
#	fi

	# 判断测试目录有效性
	if [ ! -d "${testdir}" ];then
		TConf_LLE "Can't find testcases (${testdir})"
		return $TCONF
	fi

	# 创建临时文件目录
	if [ -d "${TESTDIR_SCRT}" ];then
		rm -rf ${TESTDIR_SCRT}
		mkdir -p ${TESTDIR_SCRT}
	else
		mkdir -p ${TESTDIR_SCRT}
	fi
	
	# 判断是否创建成功
	if [ ! -d ${TESTDIR_SCRT} ];then
		TConf_LLE "mkdir ${TESTDIR_SCRT}"
		return $TCONF
	fi

	return ${TPASS}
}


## TODO : 执行测试
#  In   : $1 => testcase dir name
#  Out  : 0 => TPASS
#         1 => TFAIL
#         2 => TCONF
Run_SCRT(){
	# 测试文件目录
	local testdir="$1"
	# 测试文件路径
	local testfile=""
	local ret="${TPASS}"
	
	# 进入测试目录
	cd ${testdir}
	# 测试文件，通过数组保存
	local testfilelist=($(find ./ -type f | sort))

	for testfile in ${testfilelist[*]}
	do
		# 不识别指定文件
		[[ "$testfile" =~ "readme"|"swp" ]] && continue
		if [ -x "$testfile" ];then
			# 清空临时文件目录
			rm -rf ${TESTDIR_SCRT}/*
			Debug_LLE "rm -rf ${TESTDIR_SCRT}/*"

			Info_LLE "\t\tStart  Test FileSystem : ${testdir}-${testfile#*/} "
			bash $testfile
			ret=$?
			Info_LLE "\t\tFinish Test FileSystem : ${testdir}-${testfile#*/} "
		else
			TConf_LLE "${testfile#*/} : No executable permissions"
			continue
		fi

		# 判断结果
		OverallLog_LLE "$ret" "${testfile#*/}" 
		if [ $ret -ne ${TPASS} ];then
			break
		fi
	done

	return $ret
}


## TODO : 垃圾回收
Clean_SCRT(){
	# 删除临时文件目录
	Debug_LLE "rm -rf ${TESTDIR_SCRT}"
	rm -rf ${TESTDIR_SCRT}

	return $?
}


## TODO : 解析函数返回值
RetParse_SCRT(){
	local ret=$?
	if [ $ret -ne ${TPASS} ];then
		Clean_SCRT
		exit $ret
	fi
}


## TODO : main
#   In  : $1 => testcase dir name
#   Out : 0 => TPASS
#         1 => TFAIL
#         2 => TCONF
Main_SCRT(){
	local testdir=$(basename $1)

	Init_SCRT ${testdir}
	RetParse_SCRT

	Run_SCRT ${testdir}
	RetParse_SCRT

	Clean_SCRT
	RetParse_SCRT

	return ${TPASS}
}

Main_SCRT $*
exit $?
