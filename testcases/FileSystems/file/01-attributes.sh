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


## TODO: 用户界面
##
FileAttrUSAGE(){
	FileUSAGE_FSLIB "file - 01测试文件属性"
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
FileAttrInit(){
	# 加载lib库
	local libfile="../lib/fs-lib.sh"
	if [ -f "${libfile}" ];then
		source ${libfile}
	else
		echo "TCONF : Can't found ${libfile}"
		exit 2
	fi

	# 调用初始化函数
	FileInit_FSLIB "FileAttrClean"
	# 调用用户界面函数
	FileAttrUSAGE

	# 临时文件名
	tmpFile="${FSTESTDIR}/fs-file.txt"

	# 创建临时文件
	touch ${tmpFile}
	FileRetParse_FSLIB "touch ${tmpFile}"

	return ${TPASS} 
}


## TODO: test 文件类型
#
FileAttrTest01(){
	file ${tmpFile} >/dev/null
    	FileRetParse_FSLIB "文件类型 : file ${tmpFile}" "False"
}


## TODO: test 文件存储位置
#
FileAttrTest02(){
	ls ${tmpFile} >/dev/null
    	FileRetParse_FSLIB "文件存储位置 : ls ${tmpFile}" "False"
}


## TODO: test 文件大小
#
FileAttrTest03(){
	du -sh ${tmpFile} >/dev/null
	FileRetParse_FSLIB "文件大小 : du -sh ${tmpFile}" "False"
}


## TODO: test 列表
#
FileAttrTest04(){
	ls / > /dev/null
	FileRetParse_FSLIB "列表 : ls /" "False"
}


## TODO: test 新建,复制，移动，重命名，删除
#
FileAttrTest05(){
	touch ${FSTESTDIR}/file-test04 > /dev/null
	FileRetParse_FSLIB "新建 : touch ${FSTESTDIR}/file-test04" "False"

	cp ${FSTESTDIR}/file-test04 ${FSTESTDIR}/file-test04-bak
	FileRetParse_FSLIB "复制 : cp ${FSTESTDIR}/file-test04 ${FSTESTDIR}/file-test04-bak" "False"
	
	mv ${FSTESTDIR}/file-test04 /tmp/
	FileRetParse_FSLIB "移动 : mv ${FSTESTDIR}/file-test04 /tmp/" "False"
	
	mv ${FSTESTDIR}/file-test04-bak ${FSTESTDIR}/file-test04
	FileRetParse_FSLIB "重命名 : mv ${FSTESTDIR}/file-test04-bak ${FSTESTDIR}/file-test04" "False"

	rm ${FSTESTDIR}/file-test04 /tmp/file-test04
	FileRetParse_FSLIB "删除 : rm ${FSTESTDIR}/file-test04 /tmp/file-test04" "False"
}


## TODO: test 权限修改，读，写，重读，重写,追加写
#
FileAttrTest06(){
	echo "helloworld" > ${tmpFile}
	FileRetParse_FSLIB "写 : echo \"helloworld\" > ${tmpFile}" "False"

	cat ${tmpFile} | grep -q "helloworld"
	FileRetParse_FSLIB "读 : cat ${tmpFile} | grep -q \"helloworld\"" "False"

	echo "helloworld" >> ${tmpFile}
	FileRetParse_FSLIB "追加写 : echo \"helloworld\" >> ${tmpFile}" "False"
}


## TODO : 测试收尾清除工作
#
FileAttrClean(){
	if [ -f "${tmpFile}" ];then
		rm ${tmpFile}
	fi

	unset -v tmpFile
}


## TODO: 调用程序退出函数
#    In: $1 => 调用脚本结果值
FileAttrExit(){
	# 调用退出函数，其中调用了clean相关函数
	FileExit_FSLIB ${FILERET}
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
FileAttrMain(){
	FileAttrInit
    
	FileAttrTest01
	FileAttrTest02
  	FileAttrTest03
	FileAttrTest04
  	FileAttrTest05
	FileAttrTest06

	FileAttrExit
}


FileAttrMain
