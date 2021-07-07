#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename	:  ssh-auto.sh
# Version	:  1.0
# Date		:  2020/05/23
# Author	:  Lz
# Email		:  lz843723683@gmail.com
# History	:     
#              Version 1.0, 2020/05/23
# Function	:  ssh免密登录
# Out		:        
#              0 => TPASS
#              1 => TFAIL
#              other=> TCONF
# ----------------------------------------------------------------------

SSHAUTO_CONFIGFILE=""
# 已经存在ssh免密登录的用户
SSHAUTO_EXIST_LTFLIB=""
# 已经存在ssh免密登录的普通用户
SSHAUTO_EXISTORDINARY_LTFLIB=""
# 普通用户IP和用户名
SSHAUTO_ORDINARYSTR=""
# 所有IP
SSHAUTO_IPARR=()
# 所有的用户名
SSHAUTO_USERARR=()
# 所有的用户密码
SSHAUTO_PASSWDARR=()


## TODO  : 判断是否存在全局变量
SshAuto_Global_LTFLIB(){
	if [ "Z$TPASS" == "Z" ];then
		TPASS=0
	fi
	if [ "Z$TFAIL" == "Z" ];then
		TFAIL=1
	fi
	if [ "Z$TCONF" == "Z" ];then
		TCONF=2
	fi
}


## TODO  : 设置默认远程ip和用户名，与SshAuto_CmdDef_LTFLIB配合使用
#    In  : $1 => 默认远程ip
#          $2 => 默认远程用户名
SshAuto_SetIpUser_LTFLIB(){
	if [ $# -ne 2 ];then
		echo "SshAuto_SetIpUser_LTFLIB 参数错误"
		return $TFAIL
	fi
	
	SshAuto_DefIP=$1
	SshAuto_DefUser=$2
	return $?
}


## TODO  : 使用默认IP($SshAuto_DefIP)和默认用户($SshAuto_DefUser)执行命令，与SshAuto_SetIpUser_LTFLIB配合使用
#    In  : $1 => 执行命令
#          $2 => 是否静默输出 yes -> 静默 no -> 打印输出
#          $3 => 结果是否反转
SshAuto_CmdDef_LTFLIB(){
	if [ "Z${SshAuto_DefIP}" == "Z" -o "Z${SshAuto_DefUser}" == "Z" ];then
		echo "尚未设置远程ip和远程用户名"
		return $TFAIL
	fi

	if [ $# -ne 3 ];then
		echo "SshAuto_CmdDef_LTFLIB 参数错误"
		return $TFAIL
	fi

	SshAuto_Command_LTFLIB "${SshAuto_DefIP}" "${SshAuto_DefUser}" "$1" "$2" "$3"
	return $?
}


## TODO  : 本地(localhost)用户(audadm)执行命令
#    In  : $1 => 执行命令
#          $2 => 是否静默输出 yes -> 静默 no -> 打印输出
#          $3 => 结果是否反转
SshAuto_CmdLocalAud_LTFLIB(){
	if [ $# -ne 3 ];then
		echo "SshAuto_CmdLocalAud_LTFLIB 参数错误"
		return $TFAIL
	fi

	SshAuto_Command_LTFLIB "localhost" "audadm" "$1" "$2" "$3"
	return $?
}


## TODO  : 本地(localhost)用户(secadm)执行命令
#    In  : $1 => 执行命令
#          $2 => 是否静默输出 yes -> 静默 no -> 打印输出

#          $3 => 结果是否反转
SshAuto_CmdLocalSec_LTFLIB(){
	if [ $# -ne 3 ];then
		echo "SshAuto_CmdLocalSec_LTFLIB 参数错误"
		return $TFAIL
	fi

	SshAuto_Command_LTFLIB "localhost" "secadm" "$1" "$2" "$3"
	return $?
}


## TODO  : 本地(localhost)用户(sysadm)执行命令
#    In  : $1 => 执行命令
#          $2 => 是否静默输出 yes -> 静默 no -> 打印输出
#          $3 => 结果是否反转
SshAuto_CmdLocalSys_LTFLIB(){
	if [ $# -ne 3 ];then
		echo "SshAuto_CmdLocalSys_LTFLIB 参数错误"
		return $TFAIL
	fi

	SshAuto_Command_LTFLIB "localhost" "sysadm" "$1" "$2" "$3"
	return $?
}


## TODO  : 远程执行命令
#    In  : $1 => ip地址
#          $2 => 用户名
#          $3 => 执行命令
#          $4 => 是否静默输出 yes -> 静默 no -> 打印输出
#          $5 => 结果是否反转 yes -> 反转 no -> 不反转
SshAuto_Command_LTFLIB(){
	if [ $# -ne 5 ];then
		echo "SshAuto_Command_LTFLIB 参数错误"
		return $TFAIL
	fi
	local ret_ssha=0

	# 判断静默输出
	if [ "Z$4" != "Zyes" ];then
		echo "Command: ssh $2@$1 \"$3\""
#		ssh "$2"@"$1" "whoami ; $3"
		ssh -t -t -q "$2"@"$1" "$3"
		ret_ssha=$?
	else
		# 禁止打印输出
		ssh -t -t -q "$2"@"$1" "$3" >/dev/null
		ret_ssha=$?
	fi

	# 结果反转
	if [ "Z$5" == "Zyes" ];then
		# 反转结果
		if [ $ret_ssha -eq 0 ];then
			ret_ssha=$TFAIL
		else
			ret_ssha=$TPASS
		fi
	else
		if [ $ret_ssha -eq 0 ];then
			ret_ssha=$TPASS
		else
			ret_ssha=$TFAIL
		fi
	fi

	return $ret_ssha
}


## TODO  : 初始化
#    In  : $1 => 账号密码配置文件
#    Out :        
#          0 => TPASS
#          1 => TFAIL
#          other=> TCONF
SshAuto_Init_LTFLIB(){
	# 已经存在免密登录的用户
	SSHAUTO_EXIST_LTFLIB=""

	local ret_ssha=$TPASS

	# 全局变量设置
	SshAuto_Global_LTFLIB

	# 存在配置文件
	local userinfo_file_ssha="$1"
	if [ ! -f "${userinfo_file_ssha}" ];then
		echo "Can't found $userinfo_file_ssha"
		return $TCONF
	else
		SSHAUTO_CONFIGFILE=${userinfo_file_ssha}
	fi

	# 解析配置文件
	SshAuto_ParsingConfig_LTFLIB
	ret_ssha=$?
	if [ $ret_ssha -ne 0 ];then
		return $ret_ssha
	fi
}


## TODO  : 解析配置文件
#    Out :        
#          0 => TPASS
#          1 => TFAIL
#          other=> TCONF
SshAuto_ParsingConfig_LTFLIB(){
	local ip_ssha="$1"
	local user_name_ssha="$2"
	local pass_word_ssha="$3"

	local flagnum_ssha=0
	local num_ssha=0
	# 解析配置文件内容 
	for line_ssha in `cat ${SSHAUTO_CONFIGFILE}`
	do
		flagnum_ssha=$(echo $line_ssha | tr ':' "\n" | wc -l)
		# 判断分隔符是否为两个 ":"
		if [ $flagnum_ssha -ne 3 ];then
			echo "${SSHAUTO_CONFIGFILE} 格式错误: \"$line_ssha\""
			return $TFAIL 
		fi
		# 提取文件中的ip
	        ip_ssha=`echo $line_ssha | cut -d ":" -f1`
        	# 提取文件中的用户名
	        user_name_ssha=`echo $line_ssha | cut -d ":" -f2`
        	# 提取文件中的密码
	        pass_word_ssha=`echo $line_ssha | cut -d ":" -f3`

		# 收集所有用户信息
	        SSHAUTO_IPARR[$num_ssha]=${ip_ssha}
	        SSHAUTO_USERARR[$num_ssha]=${user_name_ssha}
	        SSHAUTO_PASSWDARR[$num_ssha]=${pass_word_ssha}
		let num_ssha=num_ssha+1

                # 判断是否已经配置免密登录
                SshAuto_Judge_LTFLIB "${ip_ssha}" "${user_name_ssha}"
                if [ $? -eq ${TPASS} ];then
		# 已经配置免密登录
			# 不需要清除免密登录			
			if [ "Z${SSHAUTO_EXIST_LTFLIB}" == "Z" ];then
				SSHAUTO_EXIST_LTFLIB="${ip_ssha}:${user_name_ssha}"
			else
				SSHAUTO_EXIST_LTFLIB="${SSHAUTO_EXIST_LTFLIB} ${ip_ssha}:${user_name_ssha}"
			fi
                fi

		# 判断是否为特性用户
		echo ${user_name_ssha} | grep -Evq "^sysadm|^secadm|^audadm"
		if [ $? -eq 0 ];then
		# 普通用户
			# 收集普通用户
			if [ "Z${SSHAUTO_ORDINARYARR}" == "Z" ];then
				SSHAUTO_ORDINARYSTR="${ip_ssha}:${user_name_ssha}"
			else
				SSHAUTO_ORDINARYSTR="${SSHAUTO_ORDINARYSTR} ${ip_ssha}:${user_name_ssha}"
			fi
		fi
	done
}


## TODO  : 判断是否存在免密登录的用户
#    Out : TFAIL => 不存在免密登录用户
#          TPASS => 存在免密登录用户
SshAuto_JudgeOrdinary_LTFLIB(){ 
	# 判断是否存在普通用户
	if [ "Z${SSHAUTO_ORDINARYSTR}" == "Z" ];then
		return $TFAIL
	fi

	local ip_name_ssha=""
	local ip_ssha=""
	local user_name_ssha=""
	for ip_name_ssha in ${SSHAUTO_ORDINARYSTR}
	do
		ip_ssha=`echo $ip_name_ssha | cut -d ":" -f1`
		user_name_ssha=`echo $ip_name_ssha | cut -d ":" -f2`

		# 判断是否已经配置免密登录
		SshAuto_Judge_LTFLIB "$ip_ssha" "$user_name_ssha"
		if [ $? -eq ${TPASS} ];then
		# 已经配置免密登录
			SSHAUTO_EXISTORDINARY_LTFLIB="${ip_name_ssha}"
			
			# 存在一个普通用户则退出
			break
		fi
	done
}


## TODO  : 判断免密登录是否设置成功
#    In  : $1 => ip
#        : $2 => username
#    Out :        
#          0 => TPASS
#          1 => TFAIL
#          other=> TCONF
SshAuto_Judge_LTFLIB(){ 
	if [ $# -ne 2 ];then
		return $TFAIL
	fi
	
	local ret_ssha=$TPASS

	# PasswordAuthentication=no是否使用密码认证，（在遇到没做信任关系时非常有用，不然会卡在那里)
	# StrictHostKeyChecking=no
	ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o PreferredAuthentications=publickey $2@$1 "date" &>/dev/null 
	ret_ssha=$?
	if [ $ret_ssha -ne $TPASS ];then
		return $TFAIL
	fi
	
	return $TPASS
}


## TODO  : 配置一个用户SSH免密登录
#    In  : $1 => ip地址
#          $2 => 用户名
#          $3 => 密码
#    Out :        
#          0 => TPASS
#          1 => TFAIL
#          other=> TCONF
SshAuto_OneConfig_LTFLIB(){
	# 账号密码配置文件
	if [ $# -ne 3 ];then
		echo "Fail: SshAuto_OneConfig_LTFLIB"
		return $TCONF
	fi
	local ip_ssha="$1"
	local user_name_ssha="$2"
	local pass_word_ssha="$3"

	local ret_ssha=$TPASS

	local rsapath_ssha="${HOME}/.ssh"
	local rsafile_ssha="id_rsa"
	# 公钥文件
	local rsapub_file_ssha="${rsapath_ssha}/${rsafile_ssha}.pub"

	# 密钥对不存在则创建密钥
	[ ! -f  "$rsapub_file_ssha" ] && ssh-keygen -t rsa -N '' -f ${rsapath_ssha}/id_rsa -q

	# 判断是否已经配置免密登录
	SshAuto_Judge_LTFLIB "$ip_ssha" "$user_name_ssha"
	if [ $? -eq ${TPASS} ];then
	# 已经配置免密登录
		return $TPASS
	else
	# 未配置免密登录
		# 判断命令expect是否存在
		which expect &>/dev/null
		if [ $? -ne 0 ];then
			echo "不存在命令: expect . 所以无法为用户 ${user_name_ssha} 配置免密登录"
			echo "请手动安装expect命令相关包，或者手动配置root 对于用户 ${user_name_ssha} 的免密登录"
			return $TCONF
		fi
	fi

	# 配置免密登录
	expect &>/dev/null <<-EOF
	spawn ssh-copy-id -i $rsapub_file_ssha $user_name_ssha@$ip_ssha
	expect {
		"yes/no" { send "yes\n";exp_continue}
		"password" { send "$pass_word_ssha\n"}
	}
	expect eof
	EOF

	# 判断是否已经配置免密登录
	SshAuto_Judge_LTFLIB "$ip_ssha" "$user_name_ssha"
	if [ $? -eq ${TFAIL} ];then
		echo "ERROR : 配置免密登录失败，请验证下列参数是否正确  ip=$ip_ssha user=$user_name_ssha passwd=$pass_word_ssha"
		ret_ssha=$TFAIL
	fi

	return $ret_ssha
}


## TODO  : 配置SSH免密登录
#    In  : $1 => 账号密码配置文件
#    In  : $2 => 需要配置免密登录的用户名
#    Out :        
#          0 => TPASS
#          1 => TFAIL
#          other=> TCONF
SshAuto_Config_LTFLIB(){
	local ret_ssha=$TPASS

	# 账号密码配置文件
	local ip_ssha=""
	local user_name_ssha=""
	local pass_word_ssha=""

	local index_ssha=0
	for ip_ssha in ${SSHAUTO_IPARR[@]}
	do
        	# 提取文件中的用户名
	        user_name_ssha=${SSHAUTO_USERARR[$index_ssha]}
        	# 提取文件中的密码
	        pass_word_ssha=${SSHAUTO_PASSWDARR[$index_ssha]}
	
		let index_ssha=index_ssha+1

		# 配置免密登录
		SshAuto_OneConfig_LTFLIB "$ip_ssha" "$user_name_ssha" "$pass_word_ssha"
		if [ $? -ne ${TPASS} ];then
			ret_ssha=$TFAIL
		fi
	done

	return $ret_ssha
}


## TODO  : 清除SSH免密登录
#    In  : $1 => 账号密码配置文件
#    In  : $2 => 需要配置免密登录的用户名
#    Out :        
#          0 => TPASS
#          1 => TFAIL
#          other=> TCONF
SshAuto_ClearConfig_LTFLIB(){
	local ip_ssha=""
	local user_name_ssha=""
	local pass_word_ssha=""

	local index_ssha=0
	
	# 清除远程免密登录文件
	for ip_ssha in ${SSHAUTO_IPARR[@]}
	do
        	# 提取文件中的用户名
	        user_name_ssha=${SSHAUTO_USERARR[$index_ssha]}
        	# 提取文件中的密码
	        pass_word_ssha=${SSHAUTO_PASSWDARR[$index_ssha]}
		
		let index_ssha=index_ssha+1

		# 判断是否已经配置免密登录
		SshAuto_Judge_LTFLIB "$ip_ssha" "$user_name_ssha"
		if [ $? -eq ${TPASS} ];then
		# 已经配置免密登录
			# 判断是否不需要清除免密登录
			echo $SSHAUTO_EXIST_LTFLIB | grep "${ip_ssha}:${user_name_ssha}" >/dev/null
			if [ $? -ne 0 ];then
				# 需要清除免密登录
				SshAuto_Command_LTFLIB "$ip_ssha" "$user_name_ssha" "sudo rm ~/.ssh -rf" "yes" "no"
			fi
			continue
		fi
	done
}


## TODO  : 结果解析
#    In  : $1 => 账号密码配置文件
#    Out :        
SshAuto_RetParse_LTFLIB(){
        local ret_ssha=$?
        if [ $ret_ssha -ne ${TPASS} ];then
                exit $ret_ssha
        fi
}

#export SSHAUTO_ORDINARYSTR
#
#export -f SshAuto_Command_LTFLIB
#export -f SshAuto_CmdLocalSys_LTFLIB
#export -f SshAuto_CmdLocalSec_LTFLIB
#export -f SshAuto_CmdLocalAud_LTFLIB
#
#export -f SshAuto_OneConfig_LTFLIB
#export -f SshAuto_Judge_LTFLIB
#export -f SshAuto_JudgeOrdinary_LTFLIB
