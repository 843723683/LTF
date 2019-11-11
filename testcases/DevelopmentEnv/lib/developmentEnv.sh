#!/usr/bin/env bash


## TODO : 注册函数，用于注册：Init,Install,Run,assert,clean函数
#    $1 : Init函数名,用于初始化调用
#    $2 : Install函数名，用于安装调用
#    $3 : Run函数名，用于运行调用
#    $4 : assert函数名，用于断言成功与否
#    $5 : clean函数名，用于清除垃圾文件
RegisterFunc_BHK(){
	# 判断是否提供5个函数
	if [ $# -ne "5" ];then
		echo "TCONF: RegisterFunc_BHK 参数传递错误"
		return 2;
	fi

	readonly regInitFunc_bhk="$1"
	readonly regInstallFunc_bhk="$2"
	readonly regRunFunc_bhk="$3"
	readonly regAssertFunc_bhk="$4"
	readonly regCleanFunc_bhk="$5"

	return 0;
}


## TODO : 注册变量，用于注册：工具名
#    $1 : 工具名，用于匹配xml中Casename
RegisterVar_BHK(){
	if [ $# -ne "1" ];then
		echo "TCONF: RegisterVar_BHK 参数传递错误"
		return 2;
	fi

	readonly regToolName_bhk="$1"
}


## TODO: Benchmark主函数
Main_BHK(){
	# 加载配置文件，构建运行测试环境  
        Setup_BHK
        RetParse_BHK

	# 运行测试
        RunTest_BHK
}


## TODO:搭建运行环境,加载必要的文件
Setup_BHK(){
	# XML配置文件路径
	if [ -f "$(dirname $0)/config/developmentEnv.xml"  ];then
        	configXml_bhk=$(dirname $0)/config/developmentEnv.xml
	else
		echo "TCONF : Can't found xml file ($(dirname $0)/config/developmentEnv.xml)"
		return 2
	fi
	
        # cfg配置文件路径
	if [ -f "$(dirname $0)/config/developmentEnv.cfg"  ];then
        	source $(dirname $0)/config/developmentEnv.cfg
	else
		echo "TCONF : Can't found configure file ($(dirname $0)/config/developmentEnv.cfg)"
		return 2
	fi

        # 加载解析XML库
	if [ -f "${AUTOTEST_ROOT}/lib/xmlParse.sh"  ];then
        	source ${AUTOTEST_ROOT}/lib/xmlParse.sh
	else
		echo "TCONF : Can't found xml parse file (${AUTOTEST_ROOT}/lib/xmlParse.sh)"
		return 2
	fi
}


## TODO: 运行测试
#
RunTest_BHK(){
	# XML解析
	XMLParse_BHK
        RetParse_BHK

	# 初始化
	Init_BHK
	RetParse_BHK "初始化"

	# 安装
	Install_BHK
        RetParse_BHK "编译安装"

	# 运行测试
	Run_BHK
	RetParse_BHK "执行"

	# 结果分析
	Assert_BHK
	RetParse_BHK "结果断言"

	# 清理垃圾文件
	Clean_BHK
	RetParse_BHK "垃圾回收"
}


## TODO : XML源文件字串解析，用于识别":"
#    In : $1 => 源文件原始字串
#         $2 => 保存的列表名字
SourceStrAnalysis(){
	local sourcestr="$1"

	local sourcenum=0
        # 没有需要的依赖包
        sourcenum=$(echo $sourcestr | awk -F":" '{print NF}')
        if [ "${sourcenum}" -eq "1"  ];then
                if [ "${sourcestr}" == "-" ];then
                        return 0
                fi
        fi

	local index=0
        local sourcetmp=""
        local sourcetmplist=""
        for index in `seq 1 ${sourcenum}`
        do
                sourcetmp=$(echo $sourcestr | awk -F":" "{print \$${index}}")
		# 保存到$2数组中
		eval sourcetmplist[${#sourcetmplist[*]}]="${sourcetmp}"
        done

	# 复制给第二个参数
	eval $2="("${sourcetmplist[@]}")"
}


## TODO:解析XML文件
#  Out :0=>TPASS
#       1=>TFAIL
#       2=>TCONF :xml文件中未找到工具对应的配置
XMLParse_BHK(){
	# 测试项目名称
        xmlName_bhk=""
	# 测试源码名称列表(数组)
        xmlSourceNameList_bhk=()
	# 测试工具源码存放路径
        sourcePath_bhk=""
	# 测试源码运行目录
        runPath_bhk=""

        XMLParse ${configXml_bhk}
        XMLGetItemContent CaseName        xmlCaseName
        XMLGetItemContent CaseSourceName  xmlCaseSourceName
        XMLGetItemNum     xmlCaseName     xmlCaseNum
        XMLUnsetup

        local border=$((${xmlCaseNum}-1))
        local index=0
        for index in `seq 0 ${border}`
        do
                if [ "${xmlCaseName[${index}]}" == "${regToolName_bhk}" ];then
                        xmlName_bhk="${xmlCaseName[$index]}"
			# XML源文件字串解析，用于识别":"
			SourceStrAnalysis ${xmlCaseSourceName[$index]} xmlSourceNameList_bhk

                        break
                fi
		
		# 若没有找到匹配的CaseName，则阻塞	
		if [ "${index}" -eq "${border}" ];then
			echo "Casename (${regToolName_bhk}):Can't found in XML configuration file(${configXml_bhk}) "
			return 2
		fi
        done
      
	# 判断源码目录 
	if [ -d "$(dirname $0)/${DEVELOPMENTENV_SOURCE_PATH}" ];then
		# 存在源码目录
		sourcePath_bhk="$(dirname $0)/${DEVELOPMENTENV_SOURCE_PATH}"
	else
		echo "TCONF : Can't found source path!($(dirname $0)/${DEVELOPMENTENV_SOURCE_PATH})"
		return 2
	fi

	# 判断运行目录是否存在
	if [ -d "${DEVELOPMENTENV_RUN_PATH}" ];then
		# 存在运行目录
        	runPath_bhk="${DEVELOPMENTENV_RUN_PATH}"
	else
		echo "TCONF : Can't found run path!(${DEVELOPMENTENV_RUN_PATH})"
		return 2
	fi

        unset -v xmlCaseName xmlCaseSourceName xmlCaseNum 

	return 0
}


## TODO:安装前测试。
## Out :0=>TPASS
##      1=>TFAIL
##      2=>TCONF
##
Init_BHK(){
	local ret=0

        # 判断源文件是否存在
	local index=0
	local readonly border=$((${#xmlSourceNameList_bhk[*]}-1))
	local tmpsrcname=""
	for index in `seq 0 ${border}`
	do
		tmpsrcname=${xmlSourceNameList_bhk[$index]}
        	if [ ! -f "${sourcePath_bhk}/${tmpsrcname}"  ];then
                	echo "Can't found souce file !(${sourcePath_bhk}/${tmpsrcname})"
                	return 2
        	fi
	done

        # 判断是否已经存在源码文件
	for index in `seq 0 ${border}`
	do
		tmpsrcname=${xmlSourceNameList_bhk[$index]}
        	if [ -f "${runPath_bhk}/${tmpsrcname}" ];then
                	echo "Clean ${runPath_bhk}/${tmpsrcname}"
                	rm -rf ${runPath_bhk}/${tmpsrcname}
	                if [ "$?" -ne "0"  ];then
        	                return 2
	                fi
        	fi
	done

        
	# 判断运行目录是否存在
        if [ -d "${runPath_bhk}" ];then
		# 拷贝源码到运行目录
		for index in `seq 0 ${border}`
		do
			tmpsrcname=${xmlSourceNameList_bhk[$index]}
			cp ${sourcePath_bhk}/${tmpsrcname} ${runPath_bhk}
		done
	else
		echo "TCONF : Can't found run path ! (${runPath_bhk})"
                return 2
        fi
	
	# 初始化
        eval ${regInitFunc_bhk}
	ret=$?
	
	return ${ret}
}


# TODO: 安装测试工具
#
Install_BHK(){
	local ret=0
	
	# 判断源码文件是否存在
	local index=0
	local readonly border=$((${#xmlSourceNameList_bhk[*]}-1))
	local tmpsrcname=""
	for index in `seq 0 ${border}`
	do
		tmpsrcname=${xmlSourceNameList_bhk[$index]}
		if [ ! -f "${sourcePath_bhk}/${tmpsrcname}" ];then
			# 不存在则报错退出
			echo "${sourcePath_bhk}/${tmpsrcname} : No such source file"
			return 2
		fi
	done

	# 进入运行目录
	cd ${runPath_bhk}
	
	# 安装
	eval ${regInstallFunc_bhk}
	ret=$?

	return $ret
}


# TODO: 运行测试
Run_BHK(){
	local ret=0

	# 进入运行目录
	cd ${runPath_bhk}

	# 运行测试
	eval ${regRunFunc_bhk}
	ret=$?

	return ${ret}
}


## TODO : 断言分析
#
Assert_BHK(){
	local ret=0

	# 进入运行目录
	cd ${runPath_bhk}

	eval ${regAssertFunc_bhk}
	ret=$?	

	return ${ret}
}


## TODO : 资源回收,清除创建变量
#
Clean_BHK(){
	# 进入运行目录
	cd ${runPath_bhk}

	# 调用注册清除函数
	eval ${regCleanFunc_bhk}

	# 回收文件
	local index=0
	local readonly border=$((${#xmlSourceNameList_bhk[*]}-1))
	local tmpsrcname=""
	for index in `seq 0 ${border}`
	do
		tmpsrcname=${xmlSourceNameList_bhk[$index]}
        	if [ ! -f "${sourcePath_bhk}/${tmpsrcname}"  ];then
                	echo "Can't found souce file !(${sourcePath_bhk}/${tmpsrcname})"
                	return 2
		else
			rm ${tmpsrcname}
        	fi
	done

	unset -v configXml_bhk
	
	unset -v xmlName_bhk xmlSourceNameList_bhk sourcePath_bhk runPath_bhk

	return 0
}


## TODO : 解析函数返回值
#    In : $1 -> 日志(可以不指定)
#  exit : 1->程序退出，失败
#       : 2->程序退出，阻塞
RetParse_BHK(){
        local tmp="$?"

	if [ $# -eq 1  ];then
		local logstr="$1"
	fi


        if [ "${tmp}" -ne "0"  ];then
		[ "Z${logstr}" != "Z"  ] && echo "[ fail ] : ${logstr}"
		# 回收垃圾
		Clean_BHK	

                exit ${tmp}
	else
		[ "Z${logstr}" != "Z"  ] && echo "[ pass ] : ${logstr}"
		
        fi
}
