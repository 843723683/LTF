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


# Test Directory
TESTROOT_ATTR="/var/tmp"
TESTDIR_ATTR="${TESTROOT_ATTR}/test-attr"


## TODO: 用户界面
#
FileAttrUSAGE(){
	FileUSAGE_FSLIB "file - 01测试文件属性"
}


## TODO: 使用ctrl+c退出
#
FileAttrOnCtrlC(){
        echo "正在优雅的退出..."
        FileAttrClean

        exit ${TCONF}
}


## TODO : 测试前的初始化 
# Out  : 
#        0=> Success
#        1=> Fail
#        other=> TCONF
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

        # Determine if there is a test root directory
        if [ ! -d "${TESTROOT_ATTR}" ];then
                echo "Init Error : Can't found ${TESTROOT_ATTR}"
                return ${TCONF}
        fi

        # Determine if there is a test directory
        if [ -d "${TESTDIR_ATTR}" ];then
                rm -rf ${TESTDIR_ATTR}
                if [ $? -ne 0 ];then
                         echo "${TESTDIR_ATTR} : Failed to rm directory"
                         return ${TCONF}
                fi
        fi
    
        mkdir -p ${TESTDIR_ATTR}
        if [ $? -ne 0 ];then
                 echo "${TESTDIR_ATTR} : Failed to create directory"
                 return ${TCONF}
        fi

	# 信号捕获ctrl+c
        trap 'FileAttrOnCtrlC' INT

	return ${TPASS} 
}


## TODO: test 文件类型
#
FileAttrTest01(){
	cd ${TESTDIR_ATTR}
	local tmpFile="file-attr1"
	touch ${tmpFile}

	file ${tmpFile} >/dev/null
    	FileRetParse_FSLIB "文件类型 : file ${tmpFile}" "False"
}


## TODO: test 文件存储位置
#
FileAttrTest02(){
	cd ${TESTDIR_ATTR}
	local tmpFile="file-attr2"
	touch ${tmpFile}

	pwd ${tmpFile} >/dev/null
    	FileRetParse_FSLIB "文件存储位置 : pwd ${tmpFile}" "False"
}


## TODO: test 文件大小
#
FileAttrTest03(){
	cd ${TESTDIR_ATTR}
	local tmpFile="file-attr3"
	touch ${tmpFile}

	du -sh ${tmpFile} >/dev/null
	FileRetParse_FSLIB "文件大小 : du -sh ${tmpFile}" "False"
}


## TODO: test 列表
#
FileAttrTest04(){
	cd ${TESTDIR_ATTR}
	local tmpFile="file-attr4"
	touch ${tmpFile}

	ls / > /dev/null
	FileRetParse_FSLIB "列表 : ls /" "False"
}


## TODO: test 新建,复制，移动，重命名，删除
#
FileAttrTest05(){
	cd ${TESTDIR_ATTR}
	local tmpFile="file-attr5"

	touch ${tmpFile} > /dev/null
	FileRetParse_FSLIB "新建 : touch ${tmpFile}" "False"

	cp ${tmpFile} ${tmpFile}-bak
	FileRetParse_FSLIB "复制 : cp ${tmpFile} ${tmpFile}-bak0" "False"
	
	mv ${tmpFile} /tmp/
	FileRetParse_FSLIB "移动 : mv ${tmpFile} /tmp/" "False"
	
	mv ${tmpFile}-bak ${tmpFile}
	FileRetParse_FSLIB "重命名 : mv ${tmpFile}-bak ${tmpFile}" "False"

	rm ${tmpFile} /tmp/${tmpFile}
	FileRetParse_FSLIB "删除 : rm ${tmpFile} /tmp/${tmpFile}" "False"
}


## TODO: test 权限修改，读，写，重读，重写,追加写,定位
#
FileAttrTest06(){
	cd ${TESTDIR_ATTR}
	local tmpFile="file-attr6"
	touch ${tmpFile}

	chmod a+x ${tmpFile}
	FileRetParse_FSLIB "修改权限 : chmod a+x ${tmpFile}" "False"

	echo "helloworld" > ${tmpFile}
	FileRetParse_FSLIB "写 : echo \"helloworld\" > ${tmpFile}" "False"

	cat ${tmpFile} | grep -q "helloworld"
	FileRetParse_FSLIB "读 : cat ${tmpFile} | grep -q \"helloworld\"" "False"

	echo "helloworld" >> ${tmpFile}
	FileRetParse_FSLIB "追加写 : echo \"helloworld\" >> ${tmpFile}" "False"

	pwd > /dev/null
	FileRetParse_FSLIB "定位 : pwd" "False"
}


## TODO: test 创建、写、读硬链接
#
FileAttrTest07(){
	cd ${TESTDIR_ATTR}
	local tmpFile="test_ln"
	touch ${tmpFile} 

	ln ${tmpFile} ${tmpFile}-ln
	FileRetParse_FSLIB "硬链接 : ln ${tmpFile} ${tmpFile}-ln" "False"
	
	echo "helloworld" > ${tmpFile}-ln
	FileRetParse_FSLIB "写硬链接 : echo \"helloworld\" > ${tmpFile}-ln" "False"

	cat ${tmpFile} | grep -q helloworld
	FileRetParse_FSLIB "读硬链接 : cat ${tmpFile} | grep -q helloworld" "False"
}


## TODO: test 创建、写、读软链接
#
FileAttrTest08(){
	cd ${TESTDIR_ATTR}
	local tmpFile="test_lns"
	touch ${tmpFile} 

	ln -s ${tmpFile} ${tmpFile}-ln
	FileRetParse_FSLIB "软链接 : ln -s ${tmpFile} ${tmpFile}-ln" "False"
	
	echo "helloworld" > ${tmpFile}-ln
	FileRetParse_FSLIB "写软链接 : echo \"helloworld\" > ${tmpFile}-ln" "False"

	cat ${tmpFile} | grep -q helloworld
	FileRetParse_FSLIB "读软链接 : cat ${tmpFile} | grep -q helloworld" "False"
}


## TODO: test 创建大文件分别创建254,255,256个字母文件，最多支持255字母
#
FileAttrTest09(){
	cd ${TESTDIR_ATTR}

	local index=0
	local tmpFile=""
	for index in $(seq 0 253)
	do
		tmpFile="${tmpFile}a"
	done
	
	# 创建254文件名
	touch ${tmpFile}
	FileRetParse_FSLIB "254字母文件名: touch ...(254)" "False"
	# 创建255文件名
	touch ${tmpFile}a
	FileRetParse_FSLIB "255字母文件名: touch ...(255)" "False"
	# 创建256文件名
	touch ${tmpFile}aa &>/dev/null
	# 创建失败则为真
	[ $? -ne 0 ]
	FileRetParse_FSLIB "256字母文件名: touch ...(256) 不允许创建" "False"
}


## TODO: test 创建大文件分别创建84,85,86个中文名文件，最多支持85中文名
#
FileAttrTest10(){
	cd ${TESTDIR_ATTR}

	local index=0
	local tmpFile=""
	for index in $(seq 0 83)
	do
		tmpFile="${tmpFile}佐"
	done
	
	# 创建84文件名
	touch ${tmpFile}
	FileRetParse_FSLIB "84中文文件名: touch ...(84)" "False"
	# 创建85文件名
	touch "${tmpFile}刘"
	FileRetParse_FSLIB "85中文文件名: touch ...(85)" "False"
	# 创建86文件名
	touch "${tmpFile}刘刘" &> /dev/null
	# 创建失败则为真
	[ $? -ne 0 ]
	FileRetParse_FSLIB "86中文文件名: touch ...(86) 不允许创建" "False"
}


## TODO: test 创建大文件分别创建特殊字符文件
#
FileAttrTest11(){
	cd ${TESTDIR_ATTR}

	local index=0
	local tmpFile="！@#￥%……\*（）《》、？"
	
	# 创建特殊字符文件名
	touch ${tmpFile}
	ls ${tmpFile} > /dev/null
	FileRetParse_FSLIB "特殊字符文件创建: touch ${tmpFile}" "False"
	# 写文件
	echo "lz" > ${tmpFile}
	FileRetParse_FSLIB "特殊字符文件编写: echo \"lz\" > ${tmpFile}" "False"
}


## TODO : Empty directory
#
FileAttrCleanEmpty(){
        if [ -d "${TESTDIR_ATTR}" ];then
                rm -rf ${TESTDIR_ATTR}/*
                if [ $? -ne 0 ];then
                         echo "${TESTDIR_ATTR} : Failed to rm ${TESTDIR_ATTR}/*"
                         return 2
                fi
        fi

        return 0
}


## TODO : 测试收尾清除工作
#
FileAttrClean(){
        if [ -d "${TESTDIR_ATTR}" ];then
                rm -rf ${TESTDIR_ATTR}
                if [ $? -ne 0 ];then
                         echo "${TESTDIR_ATTR} : Failed to rm directory"
                         return 2
                fi
        fi
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
	FileAttrCleanEmpty

	FileAttrTest02
	FileAttrCleanEmpty

  	FileAttrTest03
	FileAttrCleanEmpty

	FileAttrTest04
	FileAttrCleanEmpty

  	FileAttrTest05
	FileAttrCleanEmpty

	FileAttrTest06
	FileAttrCleanEmpty

	FileAttrTest07
	FileAttrCleanEmpty

	FileAttrTest08
	FileAttrCleanEmpty

	FileAttrTest09
	FileAttrCleanEmpty

	FileAttrTest10
	FileAttrCleanEmpty

	FileAttrTest11
	FileAttrCleanEmpty

	FileAttrExit
}


FileAttrMain
