#!/usr/bin/env bash


## TODO: 注册函数，用于注册：Init,Install,Run函数
#    $1 : Init函数名,用于初始化调用
#    $2 : Install函数名，用于安装调用
#    $3 : Run函数名，用于运行调用
RegisterFunc_BHK(){
	# 判断是否提供三个函数
	if [ $# -ne "3" ];then
		echo "TCONF: RegisterFunc_BHK 参数传递错误"
		return 2;
	fi

	readonly regInitFunc_bhk="$1"
	readonly regInstallFunc_bhk="$2"
	readonly regRunFunc_bhk="$3"

	return 0;
}


## TODO: 注册变量，用于注册：工具名,源结果路径，源结果文件或目录名
#    $1 : 工具名，用于匹配xml中Casename
#    $2 : 源结果路径，用于保存结果
#    $3 : 源结果文件或目录名，用于保存结果
RegisterVar_BHK(){
	if [ $# -ne "3" ];then
		echo "TCONF: RegisterVar_BHK 参数传递错误"
		return 2;
	fi

	readonly regToolName_bhk="$1"
	readonly regOrigRetDir_bhk="$2"
	readonly regOrigRetName_bhk="$3"
}


## TODO: Benchmark主函数
Main_BHK(){
	# 加载配置文件，构建运行测试环境  
        Setup_BHK

	# 判断 安装测试 or 运行测试
	if [ "$#" -gt "1"  ] && [ "X$2" == "X${BENCHMARK_FLAG}" ];then
                InstallTest_BHK
        else
                RunTest_BHK
        fi
}


## TODO:搭建运行环境,加载必要的文件
Setup_BHK(){
	# XML配置文件路径
        CONFIG_XML=$(dirname $0)/config/benchmark.xml
        # cfg配置文件路径
        source $(dirname $0)/config/benchmark.cfg
        # 加载解析XML库
        source ${AUTOTEST_ROOT}/lib/xmlParse.sh
}


## TODO: 安装测试
InstallTest_BHK(){
	# XML解析
	XMLParse_BHK
        RetParse_BHK

	# 依赖解析
        Dep_BHK
        RetParse_BHK
	
	# 命令校验
	CmdCheck_BHK
        RetParse_BHK

	# 初始化
	Init_BHK
	RetParse_BHK

	# 安装
	Install_BHK
        RetParse_BHK
}


## TODO: 运行测试
RunTest_BHK(){
	InstallTest_BHK

	# 运行测试
	Run_BHK
	
	# 结果收集
	Result_BHK 

	# 资源回收
	Unsetup_BHK
}


## TODO:解析XML文件
#  Out :0=>TPASS
#       1=>TFAIL
#       2=>TCONF :xml文件中未找到工具对应的配置
XMLParse_BHK(){
	# 测试项目名称
        localName=""
	# 测试工具依赖
        localDep=""
	# 测试工具需要的命令
        localCmd=""
	# 测试工具源码包存放路径
        localPkgPath=""
	# 测试工具安装包名
        localPkgName=""
	# 测试工具解压后名称
        localFileName=""
	# 测试工具安装目录
        localInstallPath=""

        XMLParse ${CONFIG_XML}
        XMLGetItemContent CaseName        xmlCaseName
        XMLGetItemContent CaseDepend      xmlCaseDep
        XMLGetItemContent CaseCommand     xmlCaseCmd
        XMLGetItemContent CasePkgName     xmlCasePkgName
        XMLGetItemContent CaseFileName    xmlCaseFileName
        XMLGetItemNum     xmlCaseName     xmlCaseNum
        XMLUnsetup

        local border=$((${xmlCaseNum}-1))
        local index=0
        for index in `seq 0 ${border}`
        do
                if [ "${xmlCaseName[${index}]}" == "${regToolName_bhk}" ];then
                        localName="${xmlCaseName[$index]}"
                        localDep="${xmlCaseDep[$index]}"
                        localCmd="${xmlCaseCmd[$index]}"
                        localPkgName="${xmlCasePkgName[$index]}"
                        localFileName="${xmlCaseFileName[$index]}"
                        break
                fi
		
		# 若没有找到匹配的CaseName，则阻塞	
		if [ "${index}" -eq "${border}" ];then
			echo "Casename (${regToolName_bhk}) not found in XML configuration file(${CONFIG_XML}) "
			return 2
		fi
        done
        localPkgPath="${AUTOTEST_ROOT}/${BENCHMARK_PKG_PATH}"
        localInstallPath="${BENCHMARK_PKG_INSTALL_PATH}"

        unset -v xmlCaseName xmlCaseDep xmlCaseCmd xmlCasePkgName xmlCaseFileName xmlCaseNum 

#       echo "$localName -$localDep - $localCmd -$localPkgPath-$localPkgName-$localFileName-$localInstallPath "
	
	return 0
}


## TODO:依赖关系检查
## Out :0 => TPASS
##      1 => TFAIL
##      2 => TCONF
Dep_BHK(){
        local depNum=0
        local depTmp=""

	# 没有指定的依赖包
        depNum=$(echo $localDep | awk -F":" '{print NF}')
        if [ "${depNum}" -eq "1"  ];then
                if [ "${localDep}" == "-" ];then
                        return 0
                fi
        fi

	# 依赖检测命令
	local pkgcmd=""
	which rpm > /dev/null
	if [ $? -eq 0 ];then
		# 存在rpm命令
		pkgcmd="rpm -ql"	
	else
		which dpkg > /dev/null
		if [ $? -eq 0 ];then
			# 存在dpkg命令
			pkgcmd="dpkg -L"
		else
			# 不存在dpkg和rpm命令
			echo "[ TCONF ] : Can't found commands. dpkg or rpm "
			return 2
		fi
	fi

        local index=0
        local failpkg=""
        for index in `seq 1 ${depNum}`
        do
                depTmp=$(echo $localDep | awk -F":" "{print \$${index}}")
                #判断是否安装依赖包
                $pkgcmd $depTmp > /dev/null
                #没有安装依赖
                if [ "$?" -ne "0"  ];then
                        failpkg="$failpkg $depTmp"
                fi
        done

        if [ "X$failpkg" != "X" ];then
                echo "Not install ${failpkg}"
                return 2
        fi

	return 0
}


## TODO : 基础命令检查
#  Out  : 0 => TPASS
#         1 => TFAIL
#         2 => TCONF
CmdCheck_BHK(){
        local cmdnum=0
        local cmdtmp=""

	# 检测命令
	local checkcmd="which"

	# 没有指定的基础命令
        cmdnum=$(echo $localCmd | awk -F":" '{print NF}')
        if [ "${cmdnum}" -eq "1"  ];then
                if [ "${localCmd}" == "-" ];then
                        return 0
                fi
        fi

	# 检测是否提供指定命令
        local index=0
        local failcmd=""
        for index in `seq 1 ${cmdnum}`
        do
                cmdtmp=$(echo $localCmd | awk -F":" "{print \$${index}}")
                #判断是否存在指定命令
                $checkcmd $cmdtmp > /dev/null
                #没有安装依赖
                if [ "$?" -ne "0"  ];then
                        failcmd="$failcmd $cmdtmp"
                fi
        done

	# 判断是否存在失败命令
        if [ "X$failcmd" != "X" ];then
                echo "Can't found Command . ${failcmd}"
                return 2
        fi

	return 0
}


## TODO:安装前测试。
## Out :0=>TPASS
##      1=>TFAIL
##      2=>TCONF
##
Init_BHK(){
        local ret=0

        # 判断安装路径是否存在,不存在则新建
        if [ ! -f "${localInstallPath}" ];then
                mkdir -p ${localInstallPath}
                if [ "$?" -ne "0"  ];then
                        return 2
                fi
        fi

	# 判断是否提供安装包
	if [ "${localPkgName}" == "-" ];then
		# 没有提供包 #
		
		# 判断localFileName是否为"-"
		if [ "${localFileName}" == "-"  ];then
			# 未指定localFileName,则为localName
			localFileName="${localName}"
		fi
	else
        	# 提供包，判断安装包是否存在
        	if [ ! -f "${localPkgPath}/${localPkgName}"  ];then
        	        echo "Can't found ${localPkgPath}/${localPkgName}"
        	        return 2
        	fi
	fi	

        # 判断localInstallPath目录中是否存在localFileName，存在则清除
        if [ -d "${localInstallPath}/${localFileName}" ];then
                echo "Clean ${localInstallPath}/${localFileName}"
                rm -rf ${localInstallPath}/${localFileName}
                if [ "$?" -ne "0"  ];then
                        return 2
                fi
        fi

	# 初始化
        eval ${regInitFunc_bhk}
	ret=$?
	
	return ${ret}
}


# TODO: 安装测试工具。解压测试和调用安装函数(配置，编译，安装)
Install_BHK(){
	local ret=0

	# 判断是否提供安装包
	if [ "${localPkgName}" == "-" ];then
        	# 未提供压缩包
		mkdir "${localInstallPath}/${localFileName}"
        	if [ "$?" -ne "0" ];then
        	        echo "新建目录失败：mkdir ${localInstallPath}/${localFileName}"
        	        return 2
        	fi
	else
		# 提供压缩包
        	tar -xvf ${localPkgPath}/${localPkgName} -C ${localInstallPath} > /dev/null 2>&1
        	if [ "$?" -ne "0" ];then
        	        echo "解压缩失败"
        	        return 2
        	fi
	fi	

	# 判断是否存在解压后目录
	if [ ! -d "${localInstallPath}/${localFileName}" ];then
		# 不存在则报错退出
		echo "${localInstallPath}/${localFileName} : No such directory"
		return 2
	fi

	# 进入源码包目录
	cd ${localInstallPath}/${localFileName}
	
	# 安装
	eval ${regInstallFunc_bhk}
	ret=$?

	return $ret
}


# TODO: 运行测试
Run_BHK(){
	# 进入源码包目录
	cd ${localInstallPath}/${localFileName}

	# 休眠
        Sleep_BHK
	
	# 运行测试
	eval ${regRunFunc_bhk}
}


## TODO: 结果收集
Result_BHK(){
	# 源结果路径
	local retorigpath="${regOrigRetDir_bhk}" 
	# 源结果文件名或目录名
	local retorigname="${regOrigRetName_bhk}"
	# 目的结果路径
	local retdespath="${LOG_PATH}/${BENCHMARK_RET_PATH}"
	# 目的结果目录名
	local retdesname="${regToolName_bhk}-ret"

	# 判断是否指定结果保存目录,没有则默认为${localInstallPath}/${localFileName}
	if [ "Z${retorigpath}" == "Z:" ];then
		retorigpath="${localInstallPath}/${localFileName}"
	fi        
	
	# 进入原始结果保存目录
	cd ${retorigpath} 

        if [ -d "${LOG_PATH}" ];then
                if [ ! -d "${retdespath}/${retdesname}" ];then
                        mkdir -p ${retdespath}/${retdesname}
                fi

                # result
		if [ -d "${retorigname}" ];then
                	cp -r ${retorigname}/* ${retdespath}/${retdesname}
		else
                	cp -r ${retorigname} ${retdespath}/${retdesname}
		fi
        fi

        cd -
}


## TODO: 释放资源：buff/cache
#
Unsetup_BHK(){
	# 休眠60s
	echo "释放资源等待60s ..."
	Sleep_BHK 60

## 释放内存buff/cache ##
	
	#运行sync 命令以确保文件系统的完整性。sync 命令将所有未写的系统缓冲区写到磁盘中,包含已修改的 i-Node、已延迟的块 I/O 和读写映射文件
	sync
	# 清除pagecache
	echo 1 > /proc/sys/vm/drop_caches
	# 清除回收slab分配器中的对象（包括目录项缓存和inode缓存）。slab分配器是内核中管理内存的一种机制，其中很多缓存数据实现都是用的pagecache。
	echo 2 > /proc/sys/vm/drop_caches
	# 清除pagecache和slab分配器中的缓存对象。
	echo 3 > /proc/sys/vm/drop_caches

	echo " -   资源回收完成  - "
}


## TODO: 解析函数返回值
#  exit：1->程序退出，失败
#      ：2->程序退出，阻塞
RetParse_BHK(){
        local tmp="$?"
        if [ "${tmp}" -ne "0"  ];then
                exit ${tmp}
        fi
}


## TODO: 休眠时间
#    In: $1 => 如果存在第一个参数，则设置为休眠时间，默认为${BENCHMARK_WAIT_DEFAULT}
Sleep_BHK(){
	local sleeptime=${BENCHMARK_WAIT_DEFAULT}
	if [ "$#" -eq "1" ];then
		sleeptime=$1
	fi

	echo "sleep ${sleeptime}s ~~~"
	sleep ${sleeptime}
}


## TODO:获取指定目录存储可用大小,单位KB
#   In : $1 => 变量名，用于保存
#      : $2 => 指定目录名
#  Out : 0 => TPASS，获取成败
#        1 => TFAIL，获取失败
#        2 => TCONF，阻塞
GetDirAvailMemKB_BHK(){
	# 判断是否传入参数
	if [ $# -ne "2" ];then
		echo "[ TCONF ] : GetDirAvailMem_BHK 参数传递错误"
		return 2
	fi
	if [ ! -d "$2" ];then
		echo "[ TCONF ] : No such directory. ($2)"
		return 2
	fi
	local dirname="$2"

        # 获取目录可用空间
        local availmem=$(df -l ${dirname} | awk '{print $4}' | sed -n '2p')

        # 判断 $availmem 是否为空 
        [ "X$availmem" == "X" ] && { echo "[ FAIL ] : Get Available is NULL";return 1; }

        # 判断 $availmem 是否为数字 
        echo ${availmem} | grep -q '[^0-9]'
        [ $? -eq 0 ] && { echo "[ FAIL ] : Get Available is not digit";return 1; }

        echo "[ Success ] : Get Available num = ${availmem}KB"

	# 将可用内存保存到第一个参数中
	eval $1="${availmem}"

        return 0
}


## TODO:获取CPU个数
#   In : $1 => 变量名，用于保存cpu个数
#  Out : 0 => TPASS，获取成败
#        1 => TFAIL，获取失败
#        2 => TCONF，阻塞
GetCpuNum_BHK(){
	# 判断是否传入参数
	if [ $# -ne "1" ];then
		echo "[ TFAIL ] : GetCpuNum_BHK 参数传递错误"
		return 2
	fi

        # 获取CPU个数
        local cpunum=$(cat /proc/cpuinfo | grep "processor" | wc -l)
        [ $? -ne 0 ] && { echo "[ FAIL ] : Get cpu num failed";return 1; }

	if [ ${cpunum} -eq 0 ];then
		cpunum=$(lscpu | grep "CPU(s):" | awk '{print $2}')
	fi

        # 判断 $cpunum 是否为空 
        [ "X$cpunum" == "X" ] && { echo "[ FAIL ] : Get CPU(s) is NULL";return 1; }

	# 判断是否为0
	[ ${cpunum} -eq 0 ] && { echo "[ FAIL ] : Get cpu is 0";return 1; }

        # 判断 $cpunum 是否为数字 
        echo ${cpunum} | grep -q '[^0-9]'
        [ $? -eq 0 ] && { echo "[ FAIL ] : Get cpunum is not digit";return 1; }

        echo "Success :Get Cpu num = $cpunum"

	# 将cpu数量保存到第一个参数中
	eval $1="${cpunum}"

        return 0
}


## TODO: 获取剩余内存大小,单位MB
#   In : $1 => 变量名，用于保存内存余量
#  Out : 0 => TPASS，获取成败
#        1 => TFAIL，获取失败
#        2 => TCONF，阻塞
GetFreeMemSizeMB_BHK(){
	# 判断是否传入参数
	if [ $# -ne "1" ];then
		echo "[ TFAIL ] : GetFreeMemSizeMB_BHK 参数传递错误"
		return 2
	fi
        
	# 获取剩余内存大小
        local memsize=$(free -m | awk '{print $4}' | sed -n '2p')
        [ $? -ne 0 ] && { echo "[ FAIL ] : Get mem size failed";return 1; }

        # 判断 $memsize 是否为空 
        [ "X$memsize" == "X" ] && { echo "[ FAIL ]: Get mem size is NULL";return 1; }

        # 判断 $memsize 是否为数字 
        echo ${memsize} | grep -q '[^0-9]'
        [ $? -eq 0 ] && { echo "[ FAIL ] : Get memsize is not digit";return 1; }

	echo "Success :Get mem Size = ${memsize}MB"
	
	# 将mem余量保存到第一个参数中
	eval $1="${memsize}"

        return 0
}


## TODO:获取总内存大小,单位GB
#   In : $1 => 变量名，用于保存内存
#  Out : 0 => TPASS，获取成败
#        1 => TFAIL，获取失败
#        2 => TCONF，阻塞
GetTotalMemSizeGB_BHK(){
	# 判断是否传入参数
	if [ $# -ne "1" ];then
		echo "[ TFAIL ] : GetTotalMemSizeGB_BHK 参数传递错误"
		return 2
	fi
        
	# 获取总内存大小
        local memsize=$(free -g | awk '{print $2}' | sed -n '2p')
        [ $? -ne 0 ] && { echo "[ FAIL ] : Get mem size failed";return 1; }

	# 内存总大小+1GB
	let memsize=memsize+1

        # 判断 $memsize 是否为空 
        [ "X$memsize" == "X" ] && { echo "[ FAIL ] : Get mem size is NULL";return 1; }

        # 判断 $memsize 是否为数字 
        echo ${memsize} | grep -q '[^0-9]'
        [ $? -eq 0 ] && { echo "[ FAIL ] :Get memsize is not digit";return 1; }

	echo "Success :Get mem Size = ${memsize}GB"
	
	# 将mem保存到第一个参数中
	eval $1="${memsize}"

        return 0
}
