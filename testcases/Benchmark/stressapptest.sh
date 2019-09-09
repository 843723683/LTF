#!/bin/bash

toolName="stressapptest"

## TODO:搭建测试运行环境
##
StressapptestSetup(){
	# XML配置文件路径
	CONFIG_XML=$(dirname $0)/config/benchmark.xml
	# cfg配置文件路径
	source $(dirname $0)/config/benchmark.cfg
	# 加载解析XML库
	source ${AUTOTEST_ROOT}/lib/xmlParse.sh
}

## TODO:解析XML文件，获取工具安装位置等
##
StressapptestXMLParse(){
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
##      2=>TCONF,未安装指定依赖
StressapptestDep(){
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

## TODO:安装前准备
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
##
StressapptestInit(){
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
		echo "Clean :rm -rf${localInstallPath}/${localFileName}"
		rm -rf ${localInstallPath}/${localFileName}
		if [ "$?" -ne "0"  ];then
			ret=2
		fi
	fi

	return $ret
}

## TODO:解析函数返回值
## exit：1->程序退出，失败
##     ：2->程序退出，阻塞
StressapptestRetParse(){
	local tmp="$?"
	if [ "${tmp}" -ne "0"  ];then
		exit ${tmp}
	fi	
}

## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
StressapptestInstall(){
	local ret=0
	#解压缩
	tar -zxvf ${localPkgPath}/${localPkgName} -C ${localInstallPath} > /dev/null 2>&1
	if [ "$?" -ne "0" ];then
		echo "解压缩失败"
		return 2
	fi	

	cd ${localInstallPath}/${localFileName}
	# 配置,判断体系架构
	if [[ "X${AUTOTEST_ARCH}" =~ "Xaarch64" ]];then
		echo "TCONF：Arm is not supported! Try x86_64, i686, powerpc, or armv7a"
		return 2
	else
		./configure
		[ $? -ne 0 ] && return 1
	fi
	
	# 编译
	make
	[ $? -ne 0 ] && return 1
	# 安装
	make install
	[ $? -ne 0 ] && return 1
	cd -

	return $ret
}

## TODO：运行测试
##
StressapptestRun(){
	cd ${localInstallPath}/${localFileName}
	mem_size=$(free -m | awk '{print $4}' | sed -n '2p')
	echo "当前剩余内存大小:${mem_size}"
	echo "Cmd: stressapptest -M ${mem_size} -s 1200"

	# 测试
        stressapptest -M ${mem_size} -s 1200 >  stressapptest.ret
	cd -
}

## TODO: 结果收集
##
StressapptestRet(){
        cd ${localInstallPath}/${localFileName}

	local retPath=${LOG_PATH}/${BENCHMARK_RET_PATH}
        if [ -d "${LOG_PATH}" ];then
		if [ ! -d "${retPath}" ];then
			mkdir -p ${retPath}
		fi

		##result 
		cp stressapptest.ret ${retPath}
	fi
        
	
	cd -

}

StressapptestUnsetup(){
	rm -rf ${localInstallPath}/${localFileName}
}

## TODO:安装并且运行测试
##
StressapptestRunTest(){
	StressapptestXMLParse

	StressapptestDep
	StressapptestRetParse

	StressapptestInit
	StressapptestRetParse

	StressapptestInstall
	StressapptestRetParse

	StressapptestRun
	StressapptestRet
#	sleep 5
#	echo "hello Stressapptest"
	
#	StressapptestUnsetup
}

## TODO:进行安装测试
##
StressapptestInstallTest(){
	StressapptestXMLParse

	StressapptestDep
	StressapptestRetParse

	StressapptestInit
	StressapptestRetParse

	StressapptestInstall
	StressapptestRetParse
}

main(){
	StressapptestSetup
	
	if [ "$#" -ne "0"  ] && [ "X$1" == "X${BENCHMARK_FLAG}" ];then
		StressapptestInstallTest
	else
		StressapptestRunTest
	fi
}

main $@

exit $?
