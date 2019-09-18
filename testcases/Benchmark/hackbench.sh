#!/bin/bash

toolName="hackbench"
toolRetDir="${toolName}-ret"

## TODO:搭建运行环境
##
HackbenchSetup(){
	# XML配置文件路径
	CONFIG_XML=$(dirname $0)/config/benchmark.xml
	# cfg配置文件路径
	source $(dirname $0)/config/benchmark.cfg
	# 加载解析XML库
	source ${AUTOTEST_ROOT}/lib/xmlParse.sh
}

## TODO:解析XML文件，获取工具安装位置等
##
HackbenchXMLParse(){
	localName=""
	localDep=""
	localPkgPath=""
	localPkgName=""
	localFileName=""
	localInstallPath=""

        XMLParse ${CONFIG_XML}
        XMLGetItemContent CaseName        xmlCaseName
        XMLGetItemContent CaseDepend      xmlCaseDep
        XMLGetItemContent CasePkgName     xmlCasePkgName
        XMLGetItemContent CaseFileName    xmlCaseFileName
	XMLGetItemNum     xmlCaseName     xmlCaseNum
        XMLUnsetup

	local border=$((${xmlCaseNum}-1))
	local index=0
	for index in `seq 0 ${border}`
        do
                if [ "${xmlCaseName[${index}]}" == "${toolName}" ];then
			localName="${xmlCaseName[$index]}"
                        localDep="${xmlCaseDep[$index]}"
			localPkgName="${xmlCasePkgName[$index]}"
			localFileName="${xmlCaseFileName[$index]}"
			break
                fi
        done
	localPkgPath="${AUTOTEST_ROOT}/${BENCHMARK_PKG_PATH}"
	localInstallPath="${BENCHMARK_PKG_INSTALL_PATH}"

	unset -v xmlCaseName xmlCaseDep xmlCasePkgName xmlCaseFileName xmlCaseNum 
	
#	echo "$localName -$localDep-$localPkgPath-$localPkgName-$localFileName-$localInstallPath "
}

## TODO:依赖关系检查
## Out :0=>TPASS
##	1=>TFAIL
##      2=>未安装指定依赖
HackbenchDep(){
	local depNum=0
	local depTmp=""

	depNum=$(echo $localDep | awk -F":" '{print NF}')
	if [ "${depNum}" -eq "1"  ];then
		if [ "${localDep}" == "-" ];then
                	return 0
		fi
	fi

	local index=0
	for index in `seq 1 ${depNum}`
	do
		depTmp=$(echo $localDep | awk -F":" "{print \$${index}}")
		#判断是否安装依赖包
		$BENCHMARK_PKG_CMD $depTmp > /dev/null
		local ret="$?"
		#没有安装依赖
		if [ "${ret}" -ne "0"  ];then
			echo "Not install ${depTmp}"
			return 2
		fi
	done

	return 0
}

## TODO:安装前准备，初始化unixbench运行环境
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
##
HackbenchInit(){
	local ret=0
	#判断安装包是否存在
	if [ ! -f "${localPkgPath}/${localPkgName}"  ];then
		echo "Not Find ${localPkgPath}/${localPkgName}"
		ret=2
	fi
	#判断安装路径是否存在
	if [ ! -f "${localInstallPath}" ];then
		mkdir -p ${localInstallPath}
		if [ "$?" -ne "0"  ];then
			ret=2
		fi
	fi

	#判断是否已经解压
	if [ -d "${localInstallPath}/${localFileName}" ];then
		echo "Clean ${localInstallPath}/${localFileName}"
		rm -rf ${localInstallPath}/${localFileName}
		if [ "$?" -ne "0"  ];then
			ret=2
		fi
	fi
        
	# 获取CPU个数
	HackbenchGetCpuNum
        local cpuNum=$?
        [ $cpuNum -le 0 ] && { echo "FAIL:cpu num is $cpuNum";ret=2; }

	return $ret
}

## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
HackbenchInstall(){
	local ret=0
	#解压缩
	tar -xvf ${localPkgPath}/${localPkgName} -C ${localInstallPath} > /dev/null 2>&1
	if [ "$?" -ne "0" ];then
		echo "解压缩失败"
		return 2
	fi	

	cd ${localInstallPath}/${localFileName}
	# 配置
	./configure
	[ $? -ne 0 ] &&  return 1

        # 获取CPU个数
	HackbenchGetCpuNum
        local cpuNum=$?
        [ $cpuNum -le 0 ] && { echo "FAIL:cpu num is $cpuNum";return 2; }
	
	#编译
	if [ "$cpuNum" -eq "0" ];then
		make 
	else
		make -j ${cpuNum}
	fi
	[ $? -ne 0 ] &&  return 1

	#安装
	make install
	[ $? -ne 0 ] &&  return 1
	
	#判断是否存在hackbench
	if [ ! -f "/opt/ltp/testcases/bin/hackbench" ];then
		echo "Can't find /opt/ltp/testcases/bin/hackbench "
		return 1
	fi
	cd -

	return $ret
}

## TODO：运行测试
##
HackbenchRun(){
	cd /opt/ltp/
	
	./runltp -f sched -s hackbench > hackbench.ret

	cd -
}

## TODO: 结果收集
##
HackbenchRet(){
        cd /opt/ltp/

	local retPath=${LOG_PATH}/${BENCHMARK_RET_PATH}
        if [ -d "${LOG_PATH}" ];then
		if [ ! -d "${retPath}" ];then
			mkdir -p ${retPath}
		fi

		[ ! -d "${retPath}/${toolRetDir}" ] && mkdir ${retPath}/${toolRetDir}

		# result
		cp hackbench.ret ${retPath}/${toolRetDir}
	fi
	
	cd -

}


HackbenchUnsetup(){
	rm -rf ${localInstallPath}/${localFileName}
}


## TODO:解析函数返回值
## exit：1->程序退出，失败
##     ：2->程序退出，阻塞
HackbenchRetParse(){
	local tmp="$?"
	if [ "${tmp}" -ne "0"  ];then
		exit ${tmp}
	fi	
}


## TODO:获取CPU个数
## Out :-1 => 获取失败
##   other => CPU个数
##
HackbenchGetCpuNum(){
        # 获取CPU个数
        local cpuNum=$(cat /proc/cpuinfo | grep "processor" | wc -l)
        [ $? -ne 0 ] && { echo "FAIL: Get cpu num failed";return -1; }

        # 判断 $cpuNum 是否为空 
        [ "X$cpuNum" == "X" ] && { echo "FAIL: Get CPU(s) is NULL";return -1; }

        # 判断 $cpuNum 是否为数字 
        echo ${cpuNum} | grep -q '[^0-9]'
        [ $? -eq 0 ] && { echo "FAIL:Get cpuNum is not digit";return -1; }

        echo "Success :Get cpu Num = $cpuNum"

        return $cpuNum
}


## TODO:安装并且运行测试
##
HackbenchRunTest(){
	HackbenchXMLParse

	HackbenchDep
	HackbenchRetParse

	HackbenchInit
	HackbenchRetParse

	HackbenchInstall
	HackbenchRetParse

	HackbenchRun
	HackbenchRet
#	sleep 5
#	echo "hello Hackbench"

#	HackbenchUnsetup
}

## TODO:进行安装测试
##
HackbenchInstallTest(){
	HackbenchXMLParse

	HackbenchDep
	HackbenchRetParse

	HackbenchInit
	HackbenchRetParse

	HackbenchInstall
	HackbenchRetParse
}

main(){
	HackbenchSetup

	if [ "$#" -ne "0"  ] && [ "X$1" == "X${BENCHMARK_FLAG}" ];then
		HackbenchInstallTest
	else
		HackbenchRunTest
	fi

}

main $@

exit $?
