#!/bin/bash

## TODO : init
## In   : $1=>Log Path
##        $2=>Log File

RetSetup(){
	if [ ! -d "$1" ];then
		mkdir -p $1
	fi
	logFile="$2"

	retTPASSNum=0
	retTFAILNum=0
	retTCONFNum=0
	retERRORNum=0
	retTotal=0

	# 开始界面
	RetBrkUsage
}


RetBrkUsage(){
	
	printf " \n\
\t\t#     #######   ######\n \
\t\t#        #      #\n \
\t\t#        #      #####\n \
\t\t#        #      #\n \
\t\t#        #      #\n \
\t\t#####    #      #\n\n \
"
	
	printf "\n"	
	printf "%s: %s\n\n" "Test Start Time" "$(date)"
	printf "%-s\n" ---------------------------------------------------------
	printf "%-30s\t\t\t %-10s\n" TestCase  Result
	printf "%-30s\t\t\t %-10s\n" --------  ------
}


RetBrkParse(){
	let retTotal=retTPASSNum+retTFAILNum+retTCONFNum
	cat >&1 <<-EOF


--------------------
Total Test : ${retTotal}
Total TPASS: ${retTPASSNum}
Total TFAIL: ${retTFAILNum}
Total TCONF: ${retTCONFNum}
Total ERROR: ${retERRORNum}
--------------------
详细日志信息：${logFile}


	EOF
}

## TODO : 写入开始时间和Item name
## In   : $1=>Item name 
RetBrkStart(){
	#打印脚本名称
	printf "%-30s" "$1"
	
	echo "##  Run $1 : $(date)" >> ${logFile}
}

## TODO : 写入结束时间和Item name
## In   : $1=>Item name 
RetBrkEnd(){
	echo "## Finish $1 : $(date)" >> ${logFile}
}

## TODO : 写(TFAIL/TPASS/TCONF/ERROR)日志信息，统计测试项执行结果
## In   : $1=>TFAIL or TPASS or TCONF or ERROR
##        $2=>Item name 
##        $3=>Write to log file info
RetBrk (){
	case $1 in
	TPASS|TFAIL|TCONF)
		RetBrkFailPassConf "$1" "$2"
		;;
	ERROR)
		if [ "$#" -eq "3" ];then
			RetBrkErr "$1" "$2" "$3"
		else
			RetBrkErr "$1" "$2"
		fi
		;;
	*)
		echo "Invalid parameter"
		;;
	esac
}

#------------- 内部静态函数 --------------#


## TODO : 写TFAIL和TPASS日志信息，工具测试结果统计
## In   : $1=>TFAIL or TPASS or TCONF
##        $2=>Item name 
RetBrkFailPassConf(){

	#统计TPASS TFAIL TCONF数据
	case $1 in
	TPASS)
		#打印脚本执行结果
                printf "\033[1m\033[;32m\t\t\t %-10s\033[0m\n" "$1"
		let retTPASSNum=retTPASSNum+1
		;;
	TFAIL)
		#打印脚本执行结果
                printf "\033[1m\033[;31m\t\t\t %-10s\033[0m\n" "$1"
		let retTFAILNum=retTFAILNum+1
		;;
	TCONF)
		#打印脚本执行结果
                printf "\033[1m\033[;33m\t\t\t %-10s\033[0m\n" "$1"
		let retTCONFNum=retTCONFNum+1
		;;
	esac

}

## TODO : 写ERROR日志，程序相关错误统计
## In   : $1=>ERROR
##        $2=>Item name 
##        $3=>Write to log file info
RetBrkErr(){
	#打印脚本执行结果
        printf "%-30s\t\t\t %-10s\n" "$2" "$1"

	#统计ERROR数据
	let retERRORNum=retERRORNum+1

	if [ "$#" -eq "3" ];then
		echo "$(date)" >> $logFile
		echo "$1 : $3" >> $logFile
	fi
}

