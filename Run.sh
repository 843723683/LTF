#!/bin/bash

## TODO : Usage
##
##
RUNUSAGE(){
	cat >&2 <<-EOF
	 -------------------------------
	| Usage  : ./Run [OPTION]       |
	| OPTION :                      |
	|    -r : Clean result dir      |
	|    -a : Run All Testcases     |
	|    -i : Install Test          |
	|    -f xmlFile : XML file      |
	 -------------------------------
	EOF
}

## TODO:Init
##
##
RunSetup(){
	#Run time
	START_TIME="$(date "+%Y%m%d%H%M%S")" 
	
	# banchemark是否只进行安装测试,在main函数中可能定义
	if [ "X${AUTOTEST_INSTALL_FALG}" == "X" ];then
		AUTOTEST_INSTALL_FALG=""
	fi

	# cd tools path,export tool path
	cd $(dirname $0)
	export AUTOTEST_ROOT=`pwd`
	
	CFG_ROOT="${AUTOTEST_ROOT}/config"
	LIB_ROOT="${AUTOTEST_ROOT}/lib"
	TESTCASE_ROOT="${AUTOTEST_ROOT}/testcases"

	LOG_ROOT="${AUTOTEST_ROOT}/output"

	# Auto Test XML-File	
	if [ "$#" -eq "0" ];then
		AUTOTEST_XML="autoTest.xml"
	fi

	# Get architecture
	export AUTOTEST_ARCH=`${LIB_ROOT}/gnu-os`
	
	# Get Sysinfo
	source ${LIB_ROOT}/getSysInfo.sh

	# source xmlParse.sh
	source ${LIB_ROOT}/xmlParse.sh

	# 创建日志文件和目录
	export LOG_PATH=${LOG_ROOT}/${START_TIME}	
        if [ ! -d "${LOG_PATH}" ];then
                mkdir -p ${LOG_PATH} &>/dev/null
                # 判断是否创建失败
                if [ $? -ne 0 ];then
			echo "[ ERROR ] :Can't create directory '${LOG_PATH}' "
			exit 1
                fi
        fi
	LOG_FILE=${LOG_PATH}/${START_TIME}.ret

	# source result.sh
	source ${LIB_ROOT}/result.sh
	RetSetup ${LOG_PATH}
	# 判断是否初始化成功
	if [ $? -eq 1 ];then
		echo "[ ERROR ] :RetSetup function "
		exit 1
	fi
}


## TODO:rm log and result dir
##
##
RunClean(){
	cd $(dirname $0)
	local logPath=`pwd`/output

	if [ -d "${logPath}" ];then
		rm ${logPath} -rf &>/dev/null
		
		# 判断是否清楚失败
        	if [ $? -ne 0 ];then
	                echo "[ ERROR ] :Can't remove '${logPath}' "
                	exit 1
        	fi
	fi
	echo "Clean Finish"
}

## TODO:Run result parse
## In: $1=> 0-> Ret success
##          1-> Ret False
##          2-> Ret TCONF
##          3-> No Run
RunRetParse(){
	local ret=$1
	if [ "${ret}" -eq "0" ];then
		RetBrk "TPASS" "$caseName"
	elif [ "${ret}" -eq "1" ];then
		RetBrk "TFAIL" "$caseName"
	else
		RetBrk "TCONF" "$caseName"
	fi

}

## TODO:Run Script
## In: $1=> CaseName
##     $2=> CaseDir
##     $3=> CaseScript
## Out: 0=> Ret success
##      1=> Ret False
##      2=> Ret TCONF
##	3=> No Run
Run(){
	local caseName=$1
	local caseDir=$2
	local caseScript=$3

	# 日志文件
	local logFile=${LOG_PATH}/$(basename ${caseDir}).ret
	
	local ret=0	

	RetBrkStart "`basename $caseDir`-$caseName" ${logFile}
	# 第一个参数：${caseDir}/${CaseName}。第二个参数：是否只进行安装测试。
	bash ${caseDir}/${caseScript} "${caseDir}/${caseName}" "${AUTOTEST_INSTALL_FALG}" >> ${logFile} 2>&1
	ret="$?"
	RunRetParse $ret

	RetBrkEnd "`basename $caseDir`-$caseName" ${logFile}
	
	return $ret
}

##TODO:解析xml中每一个测试小项的内容 
## In: $1=> CaseName
##     $2=> CaseDir
##     $3=> CaseScript
##     $4=> CaseRun
RunStartTest(){
	local caseName=$1
	local caseDir=$2
	local caseScript=$3
	local caseRun=$4
	
	local ret=0
	if [ "${caseRun}" == "True" ];then
		##Run test
		Run "$caseName" "$caseDir" "$caseScript"
		ret=$?
        elif [ "${caseRun}" == "ALL" ];then
                local allCaseName=""
                allCaseName=$(ls ${caseDir})
		local i=0
                for i in ${allCaseName}
                do
                        Run "${i%%.sh}" "$caseDir" "$i"
                done
	else 
		## XML 中caseRun 设置为 False

#		RetBrk "NORUN" "${caseName}" \
#			"Configure set"
		ret=77
	fi
	
	return $ret
}

## TODO: 解析XML文件，调用判断执行函数
## In  : $1=>XML file name
## OUT : 0=>Success
##       1=>Failed
RunAutoTest(){
	if [ ! -f "${CFG_ROOT}/$1" ];then
		RetBrk "ERROR" "XML File" \
			"Can't find XML file (${CFG_ROOT}/$1)" ${LOG_FILE}
		return 1
	fi

	# 解析XML文件
	local XMLFilePath="${CFG_ROOT}/$1"
	XMLParse ${XMLFilePath}
	XMLGetItemContent CaseName    xmlCaseName
	XMLGetItemContent CaseDir     xmlCaseDir
	XMLGetItemContent CaseScript  xmlCaseScript
	XMLGetItemContent CaseRun     xmlCaseRun
	XMLGetItemNum     xmlCaseName xmlCaseNum
	XMLUnsetup
#	echo ${xmlCaseName[*]} - ${xmlCaseDir[*]} - ${xmlCaseScript[*]} - ${xmlCaseRun[*]} - $xmlCaseNum
	
	# 运行XML中每一个测试项	
	local border=$((${xmlCaseNum}-1))
	local index=0
        for index in `seq 0 ${border}`
	do
		RunStartTest ${xmlCaseName[${index}]} \
				${TESTCASE_ROOT}/${xmlCaseDir[${index}]} \
				${xmlCaseScript[${index}]} \
				${xmlCaseRun[${index}]}
	done

	unset -v xmlCaseName xmlCaseDir xmlCaseScript xmlCaseRun xmlCaseNum	
}

## TODO:Run all test(${AUTOTEST_XML})
##
RunAllAutoTest(){
	XMLParse ${CFG_ROOT}/${AUTOTEST_XML}
	XMLGetItemContent GroupName     xmlGroupName
	XMLGetItemContent GroupXMLName  xmlGroupXMLName
	XMLGetItemContent GroupRun      xmlGroupRun
	XMLGetItemNum     xmlGroupName  xmlGroupNum
	XMLUnsetup

	local border=$((${xmlGroupNum}-1))
	local index=0
        for index in `seq 0 ${border}`
	do
		if [ "${xmlGroupRun[${index}]}" == "True" ];then
			RunAutoTest ${xmlGroupXMLName[$index]}
		else
			continue
		fi
	done

	unset -v xmlGroupName xmlGroupXMLName xmlGroupRun xmlGroupNum
}

main(){
	if [ "$#" -eq "0"  ];then
		RUNUSAGE
		exit 1
	else
		#运行指定XML测试项
		while getopts ":f:ari" opt
		do
			case $opt in
			f)
				# 获取xmlfile名称
				local xmlFileName=$OPTARG
				;;
			a)	
				# 获取xmlfile名称
				local xmlFileName="ALL"
				;;
			r)
				RunClean
				exit 0
				;;
			i)
			## banchmark只进行安装测试
				AUTOTEST_INSTALL_FALG="INSTALL"
				;;
			*)
				RUNUSAGE
				exit 1
				;;
			esac

		done

		if [ "$xmlFileName" == "ALL" ];then
			#初始化设置
			RunSetup
			# 运行所有测试
			RunAllAutoTest
			# 结果解析
			RetBrkParse
		elif [ "$xmlFileName" != "" ];then
			#初始化设置
			RunSetup
			# 运行指定XML测试
			RunAutoTest $xmlFileName
			# 结果解析
			RetBrkParse
			exit 0
		else
			# 参数未加“-”
			RUNUSAGE
			exit 1
			
		fi

		exit 0
	fi
}
main $@
