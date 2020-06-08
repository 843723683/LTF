#!/usr/bin/env bash

## TODO:获取主机名
getInfoHostName_GSI(){
	# 主机名
	GSI_HOSTNAME="Unknow"

	which hostname &>/dev/null
	if [ $? -eq 0 ];then
		GSI_HOSTNAME="$(hostname)"
	fi
}


## TODO:获取系统版本号，内核版本号，内核release日期
getInfoOS_GSI(){
	# 系统版本号
	GSI_SYSVER="Unknow"
	# 内核版本号
	GSI_OSVER="Unknow"	
	# 内核release日期
	GSI_OSREL="Unknow"

	if [ -f "/etc/.kyinfo" ];then
		cat /etc/.kyinfo | grep -q dist_id
		if [ $? -eq 0  ];then
			GSI_SYSVER="$(cat /etc/.kyinfo | grep dist_id | awk -F '= ' '{print $2}')"
		fi
	fi

	which uname &>/dev/null
	if [ $? -eq 0 ];then
		GSI_OSVER="$(uname -r)"
		GSI_OSREL="$(uname -v)"
	fi
}


## TODO:获取runlevel
getInfoRunlevel_GSI(){
	# runlevel
	GSI_RUNLEVEL="Unknow"	

	which runlevel &>/dev/null
	if [ $? -eq 0 ];then
		GSI_RUNLEVEL="$(runlevel | awk '{print $2}')"
	fi
}


## TODO:获取language
getInfoLanguage_GSI(){
	# language
	GSI_LANGUAGE="Unknow"	

	which printenv &>/dev/null
	if [ $? -eq 0 ];then
		GSI_LANGUAGE="$(printenv LANG)"
	fi
}


## TODO:获取Enforce
getInfoEnforce_GSI(){
	# enforce
	GSI_ENFORCE="Unknow"	

	which getenforce &>/dev/null
	if [ $? -eq 0 ];then
		GSI_ENFORCE="$(getenforce)"
	fi
}


## TODO:获取shell运行环境
getInfoShellEnv_GSI(){
	# shell env
	GSI_SHELLENV="Unknow"	

	# 保存打印
	local tmplog="$(echo $SHELL)"
        if [ "Z$tmplog" == "Z" ];then
		return 1
	else
                GSI_SHELLENV="$tmplog"
        fi
}


## TODO:获取shell链接地址
getInfoShLink_GSI(){
	# shell link 
	GSI_SHLINK="Unknow"	

	which file &>/dev/null
	[ $? -ne 0 ] && return 1

        which sh &>/dev/null
        if [ $? -eq 0 ];then
                local tmpcmd="$(which sh)"
                GSI_SHLINK="$(file ${tmpcmd} |awk -F ': ' '{print $2}' )"
        fi
}


printSysInfo_GSI(){
	echo "GSI_HOSTNAME = $GSI_HOSTNAME"
	
	echo "GSI_SYSVER = $GSI_SYSVER"
	echo "GSI_OSVER = $GSI_OSVER"
	echo "GSI_OSREL = $GSI_OSREL"
	
	echo "GSI_RUNLEVEL = $GSI_RUNLEVEL"

	echo "GSI_LANGUAGE = $GSI_LANGUAGE"
	
	echo "GSI_ENFORCE = $GSI_ENFORCE"

	echo "GSI_SHELLENV = $GSI_SHELLENV"
}


getInfoHostName_GSI
getInfoOS_GSI
getInfoRunlevel_GSI
getInfoLanguage_GSI
getInfoEnforce_GSI
getInfoShellEnv_GSI
getInfoShLink_GSI

#printSysInfo_GSI
