#!/bin/bash

toolName="unixbench"
## TODO:搭建运行环境
##
UnixbenchSetup(){
	# XML配置文件路径
	CONFIG_XML=$(dirname $0)/config/benchmark.xml
	# cfg配置文件路径
	source $(dirname $0)/config/benchmark.cfg
	# 加载解析XML库
	source ${AUTOTEST_ROOT}/lib/xmlParse.sh
}

## TODO:解析XML文件，获取工具安装位置等
##
UnixbenchXMLParse(){
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

	local index=0
	for ((index=0;index<${xmlCaseNum};++index))
        do
                if [ "${xmlCaseName[${index}]}" == "${toolName}"  ];then
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
UnixbenchDep(){
	local depNum=0
	local depTmp=""

	depNum=$(echo $localDep | awk -F":" '{print NF}')
	if [ "${depNum}" -eq "1"  ];then
		if [ "${localDep}" == "-" ];then
			return 0
		fi
	fi

	local index=0
	for((index=1;index<=${depNum};++index))
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
UnixbenchInit(){
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

	return $ret
}

## TODO:设置Run文件最大运行的CPU
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
UnixbenchSetThread(){
	# 获取CPU个数
	CPU_NUM=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
	[ $? -ne 0 ] && { echo "FAIL: lscpu failed";return 2; }
	# 判断 $CPU_NUM 是否为空 
	[ "X$CPU_NUM" == "X" ] && { echo "FAIL: lscpu CPU(s) is NULL";return 2; }
	# 判断 $CPU_NUM 是否为数字 
	echo ${CPU_NUM} | grep -q '[^0-9]'
	[ $? -eq 0 ] && { echo "FAIL:Get CPU_NUM is not digit";return 2; }

	if [ $CPU_NUM -le 16 ];then
		return 0
	fi

	echo "Set Cpu num = ${CPU_NUM}"	
	cd ${localInstallPath}/${localFileName}
	# 设置unixbench支持多线程
	sed -i "s/\"System Benchmarks\", 'maxCopies' => 16/\"System Benchmarks\", 'maxCopies' => $CPU_NUM/" Run	
	[ $? -ne 0 ] && { echo "FAIL:Set CPU_NUM to \"Run\" ";return 2; }
	
	cd -
	
	return 0
		
}

## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
UnixbenchInstall(){
	local ret=0
	#解压缩
	tar -xvf ${localPkgPath}/${localPkgName} -C ${localInstallPath} > /dev/null 2>&1
	if [ "$?" -ne "0" ];then
		echo "解压缩失败"
		return 2
	fi
	
	# 编译
	cd ${localInstallPath}/${localFileName}
	make
	[ "$?" -ne "0" ] && return 1
	cd -
	
	UnixbenchSetThread
	ret=$?
	[ "$ret" -ne "0" ] && return $ret

	return $ret
}

## TODO:解析函数返回值
## exit：1->程序退出，失败
##     ：2->程序退出，阻塞
UnixbenchRetParse(){
	local tmp="$?"
	if [ "${tmp}" -ne "0"  ];then
		exit ${tmp}
	fi	
}

## TODO：运行测试
##
UnixbenchRun(){
	cd ${localInstallPath}/${localFileName}
	./Run 
	cd -
}

## TODO: 结果收集
##
UnixbenchRet(){
        cd ${localInstallPath}/${localFileName}

	local retPath=${LOG_PATH}/${BENCHMARK_RET_PATH}
        if [ -d "${LOG_PATH}" ];then
		if [ ! -d "${retPath}" ];then
			mkdir -p ${retPath}
		fi

		if [ -d "./results" ];then
			cp -r ./results ${retPath}/${toolName}-ret
		fi
	fi
        
	
	cd -

}

UnixbenchUnsetup(){
	rm -rf ${localInstallPath}/${localFileName}
}

## TODO:安装并且运行测试
##
UnixbenchRunTest(){
	UnixbenchXMLParse

	UnixbenchDep
	UnixbenchRetParse

	UnixbenchInit
	UnixbenchRetParse

	UnixbenchInstall
	UnixbenchRetParse

	UnixbenchRun
	UnixbenchRet
#	sleep 5
#	echo "hello Unixbench"
	
#	UnixbenchUnsetup
}

## TODO:进行安装测试
##
UnixbenchInstallTest(){
	UnixbenchXMLParse

	UnixbenchDep
	UnixbenchRetParse

	UnixbenchInit
	UnixbenchRetParse
	
	UnixbenchInstall
	UnixbenchRetParse
}

main(){
	UnixbenchSetup
	
	if [ "$#" -ne "0"  ] && [ "X$1" == "X${BENCHMARK_FLAG}" ];then
		UnixbenchInstallTest
	else
		UnixbenchRunTest
	fi
}

main $@

exit $?
