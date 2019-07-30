#!/bin/bash

## TODO : Usage
##
##
RUNUSAGE(){
	echo ""
	echo "-------------------------------"
	echo "| Usage  : ./Run [OPTION]      |"
	echo "| OPTION :                     |"
	echo "|    -r : Clean result dir     |"
	echo "|    -a : Run All Testcases    |"
	echo "|    -f xmlFile : XML file     |"
	echo "-------------------------------"
	echo ""
}

## TODO:Init
##
##
RunSetup(){
	#Run time
	START_TIME="$(date "+%Y%m%d%H%M%S")" 
	
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

	# source xmlParse.sh
	source ${LIB_ROOT}/xmlParse.sh

	# source result.sh
	export LOG_PATH=${LOG_ROOT}/${START_TIME}	
	LOG_FILE=${LOG_PATH}/${START_TIME}.ret
	source ${LIB_ROOT}/result.sh
	# 创建日志文件和目录
	RetSetup ${LOG_PATH} ${LOG_FILE}
	
}


## TODO:rm log and result dir
##
##
RunClean(){
	cd $(dirname $0)
	local logPath=`pwd`/output

	if [ -d "${logPath}" ];then
		rm ${logPath} -rf
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

	local ret=0	

	RetBrkStart ${caseName}

	sh ${caseDir}/${caseScript} >> ${LOG_FILE} 2>&1
	ret="$?"
	RunRetParse $ret		

	RetBrkEnd ${caseName}
	
	return $ret
}

##TODO: 
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
			"Can't find XML file (${CFG_ROOT}/$1)"
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
	local index=0
	for((index=0 ;index < ${xmlCaseNum} ; ++index))
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

	local index=0
	for((index=0;index<${xmlGroupNum};++index))
	do
		if [ "${xmlGroupRun[${index}]}" == "True" ];then
			RunAutoTest ${xmlGroupXMLName[$index]}
		else
			continue
		fi
	done

	unset -v xmlGroupName xmlGroupXMLName xmlGroupRun xmlGroupNum
}



if [ "$#" -eq "0"  ];then
	RUNUSAGE
	exit 1
else
	#运行指定XML测试项
	while getopts ":f:ar" opt
	do
		case $opt in
		f)
			#初始化设置
			RunSetup
			# 运行指定XML测试
			RunAutoTest $OPTARG
			# 结果解析
			RetBrkParse
			exit 0
			;;
		a)	
			#初始化设置
			RunSetup
			# 运行所有测试
			RunAllAutoTest
			# 结果解析
			RetBrkParse
			;;
		r)
			RunClean
			exit 0
			;;
		*)
			RUNUSAGE
			exit 1
			;;
		esac
	done

	# 参数未加“-”
	RUNUSAGE
	exit 1
fi
