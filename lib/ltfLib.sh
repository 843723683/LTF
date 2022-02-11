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
#	 标题变量    : Title_Env_LTFLIB
#	 source头文件: HeadFile_Source_LTFLIB
#	 命令判断变量: CmdsExist_Env_LTFLIB
#	 新增用户变量: AddUserNames_LTFLIB
#	 新增用户密码: AddUserPasswds_LTFLIB
EnvTest_LTFLIB(){
	source "${LIB_UTILS}"

	# 打印标题
	if [ "Z${Title_Env_LTFLIB}" != "Z" -a "Z${Title_Env_LTFLIB}" != "Z " ];then
		USAGE_LTFLIB "${Title_Env_LTFLIB}"
	fi

	if [ "Z${HeadFile_Source_LTFLIB}" != "Z" -a "Z${HeadFile_Source_LTFLIB}" != "Z " ];then
		for i_ltflib in ${HeadFile_Source_LTFLIB[@]}
		do
			if [ -f "${i_ltflib}" ];then
				source ${i_ltflib}
			else
				Error_LLE "${i_ltflib}: Can't found file !"
				OutputRet_LTFLIB ${ERROR}
				TestRetParse_LTFLIB
			fi
		done
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
			useradd ${user_ltflib} &> /dev/null
			if [ $? -ne 0 ];then
				Debug_LLE "使用sudo useradd"
		        	sudo useradd ${user_ltflib}>/dev/null
	        		CommRetParse_FailDiy_LTFLIB ${ERROR} "sudo useradd ${user_ltflib}"
			fi
			if [ "${#passwdArr_ltflib[@]}" -ne 0 ];then
			        # 设置密码
				local passwd_ltflib=${passwdArr_ltflib[${count_ltflib}]}
				unset passwdArr_ltflib[${count_ltflib}]
			        echo ${passwd_ltflib} | passwd --stdin ${user_ltflib} &>/dev/null
				if [ $? -ne 0 ];then
					Debug_LLE "使用sudo passwd"
			        	echo ${passwd_ltflib} | sudo passwd --stdin ${user_ltflib} >/dev/null
				        CommRetParse_FailDiy_LTFLIB ${ERROR} "echo ${passwd_ltflib} | sudo passwd --stdin ${user_ltflib}"
				fi
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

	# 结果判断
	RetFlag_LTFLIB=${TPASS}

	# 环境检测
	EnvTest_LTFLIB
	TestRetParse_LTFLIB

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
		        	userdel -rf  ${user_ltflib} &>/dev/null
				if [ $? -ne 0 ];then
					Debug_LLE "使用sudo userdel"
		        		sudo userdel -rf  ${user_ltflib}>/dev/null
				fi
			fi
		done
	fi
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


## TODO: 失败后写日志文件
#    In: $1 => 调用脚本结果值
WriteErrorLog_LTFLIB(){

	if [ "$1" == ${TFAIL} ];then
		echo "${Title_Env_LTFLIB}" >> $LOG_FAIL_FILE
	elif [ "$1" == ${TCONF} ];then
		echo "${Title_Env_LTFLIB}" >> $LOG_CONF_FILE
	elif [ "$1" == ${ERROR} ];then
		echo "${Title_Env_LTFLIB}" >> $LOG_ERROR_FILE
	fi
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
		WriteErrorLog_LTFLIB "$1"
		exit ${1}
	fi
	
	if [ ${retflag_ltflib} != ${TPASS} ];then
		WriteErrorLog_LTFLIB "${retflag_ltflib}"
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

	RetToFlag_LLE ${flag_ltflib}
	return $?
}


########## 常用函数 ##########


## TODO: 判断软件包是否集成
#   In :
#	$1 => isExist(True) / noExist(False)
#	$2 => yes / no. 是否需要静默输出
#       $3 => yes / no. 是否需要集成LTF自带的过滤规则
#	$4 => Package Name,支持正则表达式
#   Out:
#	$TPASS => 如果$1为isExist，存在指定软件包。若$1为noExist，不存在指定软件包
#	$TFAIL => 如果$1为isExist，不存在指定软件包。若$1为noExist，存在指定软件包
#	$TCONF => 代码问题
PkgExist_LTFLIB(){
	if [ $# -ne 4  ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "Function PkgExist_LTFLIB"
	fi
	
	if [ "Z$1" != "ZisExist" -a "Z$1" != "ZnoExist" -a "Z$1" != "ZTrue" -a "Z$1" != "ZFalse" ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "PkgExist_LTFLIB: 第一个参数错误，当前为 '$1'"
	fi
	
	local flag="$1"
	local quiet="$2"
	local rule="$3"
	local pkgname="$4"
	local ret=0

	# 判断软件包是否存在
	if [ Z"$quiet" == Z"yes" ];then
		if [ "Z${rule}" == "Zno" ];then
		# 不需要添加规则
			rpm -qa | grep -q "${pkgname}"
		else
		# 添加规则
			rpm -qa | grep -q "^${pkgname}-[0-9]"
		fi
	else
		echo "rpm -qa | grep ${pkgname} :"
		if [ "Z${rule}" == "Zno" ];then
		# 不需要添加规则
			rpm -qa | grep "${pkgname}"
		else
		# 添加规则
			rpm -qa | grep "^${pkgname}-[0-9]"
		fi
	fi
	ret=$?

	# 如果不存在软件包
	if [ $ret -ne 0 ];then
		echo "未安装软件包 ${pkgname} "
	fi

	if [ Z"$flag" == Z"noExist" -o Z"$flag" == Z"False" ];then
		if [ $ret -eq 0 ];then
		# 存在软件包
			return $TFAIL
		else
		# 不存在软件包
			return $TPASS
		fi	
	else
		if [ $ret -eq 0 ];then
		# 存在软件包
			return $TPASS
		else
		# 不存在软件包
			return $TFAIL
		fi
	fi	

	return $ret
}


## TODO: 判断 多个软件包是否集成
#   In :
#	$1 => isExist(True) / noExist(False)
#	$2 => yes / no. 是否需要静默输出
#       $3 => yes / no. 是否需要集成LTF自带的过滤规则
#	$4 => Package Name,支持正则表达式
#   Out:
#	$TPASS => 如果$1为isExist，存在指定软件包。若$1为noExist，不存在指定软件包
#	$TFAIL => 如果$1为isExist，不存在指定软件包。若$1为noExist，存在指定软件包
#	$TCONF => 代码问题
PkgExistArr_LTFLIB(){
	if [ $# -ne 4  ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "Function PkgExistArr_LTFLIB"
	fi
	
	if [ "Z$1" != "ZisExist" -a "Z$1" != "ZnoExist" -a "Z$1" != "ZTrue" -a "Z$1" != "ZFalse" ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "PkgExistArr_LTFLIB: 第一个参数错误，当前为 '$1'"
	fi
	
	local flag="$1"
	local quiet="$2"
	local rule="$3"
	local pkgname=""
	local pkgnamearr="$4"
	local ret="$TPASS"

	local tmpret="$TPASS"
	local existpkg=""
	local noexistpkg=""

	# 遍历所有软件包
	for pkgname in ${pkgnamearr[@]}
	do
		# 判断软件包务是否已经存在
		PkgExist_LTFLIB "$flag" "$quiet" "$rule" "$pkgname"
		tmpret=$?

		if [ "$flag" == "isExist" -o "$flag" == "True" -a $tmpret -eq $TPASS ];then
		# 已经安装软件包
			existpkg="$existpkg $pkgname"
		elif [ "$flag" == "isExist" -o "$flag" == "True" -a $tmpret -eq $TFAIL ];then
		# 未安装的软件包
			noexistpkg="$noexistpkg $pkgname"
			ret=$TFAIL
		elif [ "$flag" == "noExist" -o "$flag" == "False" -a $tmpret -eq $TPASS ];then
		# 未安装的软件包
			noexistpkg="$noexistpkg $pkgname"
		elif [ "$flag" == "noExist" -o "$flag" == "False" -a $tmpret -eq $TFAIL ];then
		# 已经安装软件包
			existpkg="$existpkg $pkgname"
			ret=$TFAIL
		else
		# 异常
			echo "[ Error ]: PkgExistArr_LTFLIB function Results Abnormal (flag=$flag , ret=$tmpret)"
			return $TCONF
		fi
	done

	# 判断是否静默输出	
	if [ Z"$quiet" == Z"no" ];then
		echo ""
		echo "已安装的软件包: ($existpkg )"
		echo "未安装的软件包: ($noexistpkg )"
	fi

	return $ret
}


## TODO: 判断服务是否存在
#   In :
#	$1 => isExist(True) / noExist(False)
#	$2 => yes / no. 是否需要静默输出
#	$3 => Service Name
#   Out:
#	$TPASS => 如果$1为isExist，存在指定服务。若$1为noExist，不存在指定服务
#	$TFAIL => 如果$1为isExist，不存在指定服务。若$1为noExist，存在指定服务
#	$TCONF => 代码问题
SvcExist_LTFLIB(){
	if [ $# -ne 3  ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "Function SvcExist_LTFLIB"
	fi
	
	if [ "Z$1" != "ZisExist" -a "Z$1" != "ZnoExist" -a "Z$1" != "ZTrue" -a "Z$1" != "ZFalse" ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "SvcExist_LTFLIB: 第一个参数错误，当前为 '$1'"
	fi
	
	local flag="$1"
	local quiet="$2"
	local svcname="$3"
	local ret=0
	
	# 判断是否存在systemctl
	which systemctl &>/dev/null
	if [ $? -eq 0 ];then
	# 存在systemctl
		# 判断服务是否存在,如果存在则返回0
		if [ Z"$quiet" == Z"yes" ];then
			systemctl is-enabled $svcname 2>&1 | grep -q -v "No such file or directory"
			ret=$?
		else
			echo -n "systemctl is-enabled $svcname : "
			systemctl is-enabled $svcname
	
			systemctl is-enabled $svcname 2>&1 | grep -q -v "No such file or directory"
			ret=$?
		fi
	else
		# 判断是否需要静默输出
		if [ Z"$quiet" == Z"yes" ];then
			chkconfig --list | grep -q "$svcname"
			ret=$?
		else
			echo "chkconfig --list | grep $svcname"
			chkconfig --list | grep  $svcname
			ret=$?
		fi
	fi


	# 如指定noExist则结果反转
	if [ Z"$flag" == Z"noExist" -o Z"$flag" == Z"False" ];then
		if [ $ret -eq 0 ];then
		# 服务存在
			return $TFAIL
		else
		# 服务不存在
			return $TPASS
		fi
	else
		if [ $ret -eq 0 ];then
		# 服务存在
			return $TPASS
		else
		# 服务不存在
			return $TFAIL
		fi
	fi	

	return $ret
}


## TODO: 判断 多个服务是否存在
#   In :
#	$1 => isExist(True) / noExist(False)
#	$2 => yes / no. 是否需要静默输出
#	$3 => Service Name
#   Out:
#	$TPASS => 如果$1为isExist，存在指定服务。若$1为noExist，不存在指定服务
#	$TFAIL => 如果$1为isExist，不存在指定服务。若$1为noExist，存在指定服务
#	$TCONF => 代码问题
SvcExistArr_LTFLIB(){
	if [ $# -ne 3  ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "Function SvcExistArr_LTFLIB"
	fi
	
	if [ "Z$1" != "ZisExist" -a "Z$1" != "ZnoExist" -a "Z$1" != "ZTrue" -a "Z$1" != "ZFalse" ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "SvcExistArr_LTFLIB: 第一个参数错误，当前为 '$1'"
	fi
	
	local flag="$1"
	local quiet="$2"
	local svcname=""
	local svcnamearr="$3"
	local ret="$TPASS"

	local tmpret="$TPASS"
	local existsvc=""
	local noexistsvc=""

	# 遍历所有服务
	for svcname in ${svcnamearr[@]}
	do
		# 判断服务是否存在
		SvcExist_LTFLIB "$flag" "$quiet" "$svcname"
		tmpret=$?

		if [ "$flag" == "isExist" -o "$flag" == "True" -a $tmpret -eq $TPASS ];then
		# 服务当前存在
			existsvc="$existsvc $svcname"
		elif [ "$flag" == "isExist" -o "$flag" == "True" -a $tmpret -eq $TFAIL ];then
		# 服务当前不存在
			noexistsvc="$noexistsvc $svcname"
			ret=$TFAIL
		elif [ "$flag" == "noExist" -o "$flag" == "False" -a $tmpret -eq $TPASS ];then
		# 服务当前不存在
			noexistsvc="$noexistsvc $svcname"
		elif [ "$flag" == "noExist" -o "$flag" == "False" -a $tmpret -eq $TFAIL ];then
		# 服务当前存在
			existsvc="$existsvc $svcname"
			ret=$TFAIL
		else
		# 异常
			echo "[ Error ]: SvcExistArr_LTFLIB function Results Abnormal (flag=$flag , ret=$tmpret)"
			return $TCONF
		fi
	done

	# 判断是否静默输出	
	if [ Z"$quiet" == Z"no" ];then
		echo "存在以下服务: ($existsvc )"
		echo "不存在以下服务: ($noexistsvc )"
	fi

	return $ret
}


## TODO: 判断服务是否已经激活
#   In :
#	$1 => isActive(True) / noActive(False)
#	$2 => yes / no. 是否需要静默输出
#	$3 => Service Name
#   Out:
#	$TPASS => 如果$1为isActive，指定服务已启动。若$1为noActive，指定服务未启动
#	$TFAIL => 如果$1为isActive，指定服务未启动。若$1为noActive，指定服务已启动
#	$TCONF => 代码问题
SvcActive_LTFLIB(){
	if [ $# -ne 3  ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "Function SvcActive_LTFLIB"
	fi

	if [ "Z$1" != "ZisActive" -a "Z$1" != "ZnoActive" -a "Z$1" != "ZTrue" -a "Z$1" != "ZFalse" ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "SvcActive_LTFLIB: 第一个参数错误，当前为 '$1'"
	fi
	
	local flag="$1"
	local quiet="$2"
	local svcname="$3"
	local ret=0

        # 判断是否存在systemctl
        which systemctl &>/dev/null
        if [ $? -eq 0 ];then
		# 判断服务当前是否已经激活,如果激活则返回0.(若服务不存在算作未激活)
		if [ Z"$quiet" == Z"yes" ];then
			sudo systemctl is-active $svcname > /dev/null
			ret=$?
		else
			echo -n "systemctl is-active $svcname : "
			sudo systemctl is-active $svcname
			ret=$?
		fi
	else
		if [ Z"$quiet" == Z"yes" ];then
			service $svcname status &>/dev/null
			ret=$?
		else
			echo -n "service $svcname status :"
			service $svcname status
			ret=$?
		fi

	fi

	# 如指定noActive则结果反转
	if [ Z"$flag" == Z"noActive" -o Z"$flag" == Z"False" ];then
		if [ $ret -eq 0 ];then
		# 服务已启动
			return $TFAIL
		else
		# 服务未启动
			return $TPASS
		fi	
	else
		if [ $ret -eq 0 ];then
		# 服务已启动
			return $TPASS
		else
		# 服务未启动
			return $TFAIL
		fi
	fi	

	return $ret
}


## TODO: 判断 多个服务是否已经激活
#   In :
#	$1 => isActive(True) / noActive(False)
#	$2 => yes / no. 是否需要静默输出
#	$3 => Service Name
#   Out:
#	$TPASS => 如果$1为isActive，指定服务已启动。若$1为noActive，指定服务未启动
#	$TFAIL => 如果$1为isActive，指定服务未启动。若$1为noActive，指定服务已启动
#	$TCONF => 代码问题
SvcActiveArr_LTFLIB(){
	if [ $# -ne 3  ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "Function SvcActiveArr_LTFLIB"
	fi

	if [ "Z$1" != "ZisActive" -a "Z$1" != "ZnoActive" -a "Z$1" != "ZTrue" -a "Z$1" != "ZFalse" ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "SvcActiveArr_LTFLIB: 第一个参数错误，当前为 '$1'"
	fi
	
	local flag="$1"
	local quiet="$2"
	local svcname=""
	local svcnamearr="$3"
	local ret="$TPASS"

	local tmpret="$TPASS"
	local activesvc=""
	local noactivesvc=""

	# 遍历所有服务
	for svcname in ${svcnamearr[@]}
	do
		# 判断服务是否已经激活
		SvcActive_LTFLIB "$flag" "$quiet" "$svcname"
		tmpret=$?

		if [ "$flag" == "isActive" -o "$flag" == "True" -a $tmpret -eq $TPASS ];then
		# 服务当前已经激活
			activesvc="$activesvc $svcname"
		elif [ "$flag" == "isActive" -o "$flag" == "True" -a $tmpret -eq $TFAIL ];then
		# 服务当前未激活
			noactivesvc="$noactivesvc $svcname"
			ret=$TFAIL
		elif [ "$flag" == "noActive" -o "$flag" == "False" -a $tmpret -eq $TPASS ];then
		# 服务当前未激活
			noactivesvc="$noactivesvc $svcname"
		elif [ "$flag" == "noActive" -o "$flag" == "False" -a $tmpret -eq $TFAIL ];then
		# 服务当前已经激活
			activesvc="$activesvc $svcname"
			ret=$TFAIL
		else
		# 异常
			echo "[ Error ]: SvcActiveArr_LTFLIB function Results Abnormal (flag=$flag , ret=$tmpret)"
			return $TCONF
		fi
	done

	# 判断是否静默输出	
	if [ Z"$quiet" == Z"no" ];then
		echo "以下服务已激活: ($activesvc )"
		echo "以下服务未激活: ($noactivesvc )"
	fi

	return $ret
}


## TODO: 判断服务是否自启动
#   In :
#	$1 => isEnable(True) / noEnable(False)
#	$2 => yes / no. 是否需要静默输出
#	$3 => Service Name
#   Out:
#	$TPASS => 如果$1为isEnable，指定服务自启动。若$1为noEnable，指定服务未自启动
#	$TFAIL => 如果$1为isEnable，指定服务未自启动。若$1为noEnable，指定服务自启动
#	$TCONF => 代码问题
SvcEnable_LTFLIB(){
	if [ $# -ne 3  ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "Function SvcEnable_LTFLIB"
	fi
	
	if [ "Z$1" != "ZisEnable" -a "Z$1" != "ZnoEnable" -a "Z$1" != "ZTrue" -a "Z$1" != "ZFalse" ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "SvcActiveArr_LTFLIB: 第一个参数错误，当前为 '$1'"
	fi
	
	local flag="$1"
	local quiet="$2"
	local svcname="$3"
	local ret=0

        # 判断是否存在systemctl
        which systemctl &>/dev/null
        if [ $? -eq 0 ];then
		# 判断服务是否自启动,如果自启动则返回0.(若服务不存在算作未自启)
		if [ Z"$quiet" == Z"yes" ];then
			systemctl is-enabled $svcname >/dev/null 
			ret=$?
		else
			echo -n "systemctl is-enabled $svcname : "
			systemctl is-enabled $svcname
			ret=$?
		fi
        else
                # 查看当前Init
                local initnum=$(runlevel | awk '{print $2}')

                if [ Z"$quiet" == Z"yes" ];then
                        chkconfig | grep $svcname | grep -q "${initnum}:启用"
                        ret=$?
                else
                        chkconfig | grep $svcname | grep -q "${initnum}:启用"
                        ret=$?
	
			# 打印日志，判断日志是否为空
			local tmplog=$(chkconfig | grep ${svcname} | awk  '{$1="";print $0}')
			# 判断是否为空
			if [ "Z${tmplog}" == "Z" ];then
				echo "chkconfig | grep ${svcname} :不存在 ${svcname} 服务"
			else
				echo "chkconfig | grep ${svcname} :$tmplog"
			fi
                fi

        fi


	# 如指定noEnable则结果反转
	if [ Z"$flag" == Z"noEnable" -o Z"$flag" == Z"False" ];then
		if [ $ret -eq 0 ];then
		# 服务自启动
			return $TFAIL
		else
		# 服务未自启动
			return $TPASS
		fi
	else
		if [ $ret -eq 0 ];then
		# 服务自启动
			return $TPASS
		else
		# 服务未自启动
			return $TFAIL
		fi
	fi	

	return $ret
}


## TODO: 判断 多个服务是否自启动
#   In :
#	$1 => isEnable(True) / noEnable(False)
#	$2 => yes / no. 是否需要静默输出
#	$3 => Service Name Arr
#   Out:
#	$TPASS => 如果$1为isEnable，指定服务自启动。若$1为noEnable，指定服务未自启动
#	$TFAIL => 如果$1为isEnable，指定服务未自启动。若$1为noEnable，指定服务自启动
#	$TCONF => 代码问题
SvcEnableArr_LTFLIB(){
	if [ $# -ne 3  ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "Function SvcEnableArr_LTFLIB"
	fi

	if [ "Z$1" != "ZisEnable" -a "Z$1" != "ZnoEnable" -a "Z$1" != "ZTrue" -a "Z$1" != "ZFalse" ];then
		OutputRet_LTFLIB "${ERROR}"
		TestRetParse_LTFLIB "SvcActiveArr_LTFLIB: 第一个参数错误，当前为 '$1'"
	fi
	
	
	local flag="$1"
	local quiet="$2"
	local svcname=""
	local svcnamearr="$3"
	local ret="$TPASS"

	local tmpret="$TPASS"
	local enablesvc=""
	local noenablesvc=""

	# 遍历所有服务
	for svcname in ${svcnamearr[@]}
	do
		SvcEnable_LTFLIB "$flag" "$quiet" "$svcname"
		tmpret=$?

		if [ "$flag" == "isEnable" -o "$flag" == "True" -a $tmpret -eq $TPASS ];then
		# 服务默认自启动
			enablesvc="$enablesvc $svcname"
		elif [ "$flag" == "isEnable" -o "$flag" == "True" -a $tmpret -eq $TFAIL ];then
		# 服务默认未自启动
			noenablesvc="$noenablesvc $svcname"
			ret=$TFAIL
		elif [ "$flag" == "noEnable" -o "$flag" == "False" -a $tmpret -eq $TPASS ];then
		# 服务默认未自启动
			noenablesvc="$noenablesvc $svcname"
		elif [ "$flag" == "noEnable" -o "$flag" == "False" -a $tmpret -eq $TFAIL ];then
		# 服务默认自启动
			enablesvc="$enablesvc $svcname"
			ret=$TFAIL
		else
		# 异常
			echo "[ Error ]: SvcEnableArr_LTFLIB function Results Abnormal (flag=$flag , ret=$tmpret)"
			return $TCONF
		fi
	done

	# 判断是否静默输出	
	if [ Z"$quiet" == Z"no" ];then
		echo "开机自启动服务: ($enablesvc )"
		echo "开机未自启动服务: ($noenablesvc )"
	fi

	return $ret
}

