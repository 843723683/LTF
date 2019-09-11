#!/bin/bash

toolName="sysbench"
toolRetDir="${toolName}-ret"

## TODO:搭建运行环境
##
SysbenchSetup(){
	# XML配置文件路径
	CONFIG_XML=$(dirname $0)/config/benchmark.xml
	# cfg配置文件路径
	source $(dirname $0)/config/benchmark.cfg
	# 加载解析XML库
	source ${AUTOTEST_ROOT}/lib/xmlParse.sh
}

## TODO:解析XML文件，获取工具安装位置等
##
SysbenchXMLParse(){
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
SysbenchDep(){
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

## TODO:安装前准备，初始化sysbench运行环境
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
##
SysbenchInit(){
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
        
	# 获取总内存大小
        mem_size=$(free -g | awk '{print $2}' | sed -n '2p')
        echo ${mem_size} | grep -q '[^0-9]'
        [ $? -eq 0 ] && { echo "FAIL:Get mem_size is not digit";return 2; }
        echo "当前内存大小:${mem_size}"

        # 获取CPU个数
        CPU_NUM=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
        [ $? -ne 0 ] && { echo "FAIL: lscpu failed";return 2; }
        # 判断 $CPU_NUM 是否为空 
        [ "X$CPU_NUM" == "X" ] && { echo "FAIL: lscpu CPU(s) is NULL";return 2; }
        # 判断 $CPU_NUM 是否为数字 
        echo ${CPU_NUM} | grep -q '[^0-9]'
        [ $? -eq 0 ] && { echo "FAIL:Get CPU_NUM is not digit";return 2; }

	return $ret
}

## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
SysbenchInstall(){
	local ret=0
	#解压缩
	tar -xvf ${localPkgPath}/${localPkgName} -C ${localInstallPath} > /dev/null 2>&1
	if [ "$?" -ne "0" ];then
		echo "解压缩失败"
		return 2
	fi
	
	cd ${localInstallPath}/${localFileName}
	
	./autogen.sh
	[ "$?" -ne "0" ] && return 1
	# 配置
	./configure --without-mysql
	[ "$?" -ne "0" ] && return 1
	# 编译
	make
	[ "$?" -ne "0" ] && return 1
	# 安装
	make install
	[ "$?" -ne "0" ] && return 1
	cd -
	
	return $ret
}

## TODO：运行测试
##
SysbenchRun(){
	cd ${localInstallPath}/${localFileName}
	
	[ ! -d ${toolRetDir} ] && mkdir ${toolRetDir}
	
	# 内存：多线程-随机
	sysbench --threads=${CPU_NUM} --memory-block-size=8k --memory-total-size=${mem_size}G --memory-access-mode=rnd memory run > ${toolRetDir}/sysbench-rnd.ret
	# 内存：多线程-连续
	sysbench --threads=${CPU_NUM} --memory-block-size=8k --memory-total-size=${mem_size}G --memory-access-mode=seq memory run > ${toolRetDir}/sysbench-seq.ret
	# 内存：单线程-随机
	sysbench --threads=1 --memory-block-size=8k --memory-total-size=${mem_size}G --memory-access-mode=rnd memory run > ${toolRetDir}/sysbench-rnd-1cpu.ret
	# 内存：单线程-连续
	sysbench --threads=1 --memory-block-size=8k --memory-total-size=${mem_size}G --memory-access-mode=seq memory run > ${toolRetDir}/sysbench-seq-1cpu.ret
	
	cd -
}

## TODO: 结果收集
##
SysbenchRet(){
        cd ${localInstallPath}/${localFileName}

	local retPath=${LOG_PATH}/${BENCHMARK_RET_PATH}
        if [ -d "${LOG_PATH}" ];then
		if [ ! -d "${retPath}" ];then
			mkdir -p ${retPath}
		fi

		[ ! -d "${retPath}/${toolRetDir}" ] && mkdir ${retPath}/${toolRetDir}

                # result 
                if [ -d "${toolRetDir}" ];then
                        cp -r ${toolRetDir}/* ${retPath}/${toolRetDir}
                fi
	
	fi
        
	cd -
}


SysbenchUnsetup(){
	rm -rf ${localInstallPath}/${localFileName}
}


## TODO:解析函数返回值
## exit：1->程序退出，失败
##     ：2->程序退出，阻塞
SysbenchRetParse(){
	local tmp="$?"
	if [ "${tmp}" -ne "0"  ];then
		exit ${tmp}
	fi	
}


## TODO:安装并且运行测试
##
SysbenchRunTest(){
	SysbenchXMLParse

	SysbenchDep
	SysbenchRetParse

	SysbenchInit
	SysbenchRetParse

	SysbenchInstall
	SysbenchRetParse

	SysbenchRun
	SysbenchRet
#	sleep 5
#	echo "hello Sysbench"
	
#	SysbenchUnsetup
}

## TODO:进行安装测试
##
SysbenchInstallTest(){
	SysbenchXMLParse

	SysbenchDep
	SysbenchRetParse

	SysbenchInit
	SysbenchRetParse
	
	SysbenchInstall
	SysbenchRetParse
}

main(){
	SysbenchSetup
	
	if [ "$#" -ne "0"  ] && [ "X$1" == "X${BENCHMARK_FLAG}" ];then
		SysbenchInstallTest
	else
		SysbenchRunTest
	fi
}

main $@

exit $?
