#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-attributes.sh
# Version:    1.0
# Date:       2019/10/14
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   attributes - 01测试文件属性
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------

# 结果判断
FILERET=${TPASS}


## TODO: 使用ctrl+c退出
##
FileAttrOnCtrlC(){
    echo "正在优雅的退出..."
    FileAttrClean

    exit ${TCONF}
}

## TODO: 用户界面
##
FileAttrUSAGE(){
    cat >&1 <<EOF
--------- file - 01测试文件属性 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
FileAttrInit(){
    # 判断root用户
    if [ `id -u` -ne 0 ];then
        echo "Must use root ！"
        exit ${TCONF}
    fi

    # 信号捕获ctrl+c
    trap 'FileAttrOnCtrlC' INT

    # 临时文件名
    tmpFile="${FSTESTDIR}/fs-file.txt"

    # 创建临时文件
    touch ${tmpFile}
    FileAttrRetParse "touch ${tmpFile}"

    return ${TPASS} 
}


## TODO : 测试收尾清除工作
##
FileAttrClean(){
	if [ -f "${tmpFile}" ];then
		rm ${tmpFile}
	fi

	unset -v tmpFile
}


## TODO: test 文件类型
##
FileAttrTest01(){
	file ${tmpFile} >/dev/null
    	FileAttrRetParse "文件类型 - file ${tmpFile}" "False"
}


## TODO: test 文件存储位置
##
FileAttrTest02(){
	ls ${tmpFile} >/dev/null
    	FileAttrRetParse "文件存储位置 - ls ${tmpFile}" "False"
}


## TODO: test 文件大小
##
FileAttrTest03(){
	du -sh ${tmpFile} >/dev/null
    	FileAttrRetParse "文件大小 - du -sh ${tmpFile}" "False"
}


## TODO: 解析函数返回值
## In  : $1 => log
##       $2 => 是否退出测试，False为不退出
FileAttrRetParse(){
    local ret=$?
    local logstr=""
    local flag=""

    if [ $# -eq 1 ];then
        logstr="$1"
    elif [ $# -eq 2 ];then
        logstr="$1"
	flag="$2"
    fi

    if [ $ret -eq 0 ];then       
        echo "[pass] : ${logstr}"
    else
        echo "[fail] : ${logstr}"
        FileAttrClean
	if [ "Z${flag}" != "ZFalse"  ];then
	        exit $TFAIL
	else
		FILERET=${TFAIL}
	fi
    fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
FileAttrMain(){
    FileAttrUSAGE

    FileAttrInit
    
    FileAttrTest01
    FileAttrTest02
    FileAttrTest03

    FileAttrClean

    return ${TPASS}
}


FileAttrMain
exit ${FILERET}
