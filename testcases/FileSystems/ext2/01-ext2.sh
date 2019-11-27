#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-ext2.sh
# Version:    1.0
# Date:       2019/10/12
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   ext2 - 01创建/挂载ext2文件系统
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 使用ctrl+c退出
##
EXT201OnCtrlC(){
	echo "正在优雅的退出..."
	EXT201Clean

	exit ${TCONF}
}

## TODO: 用户界面
##
EXT201USAGE(){
	cat >&1 <<EOF
--------- ext2 - 01创建/挂载ext2文件系统 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
EXT201Init(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'EXT201OnCtrlC' INT

 	# 虚拟镜像文件名称
	imgFile="/var/tmp/ext201.img"

	# 挂载目录
	imgMountDir="/var/tmp/ext201-dir"
	[ -d ${imgMountDir} ] && rm -rf ${imgMountDir}
	mkdir ${imgMountDir}
	EXT201RetParse "Create mount dir ${imgMountDir}"

	# 创建50MB大小的ext2虚拟镜像文件
	dd if=/dev/zero of=${imgFile} bs=1M count=50 &>/dev/null
	EXT201RetParse "Create img File ${imgFile} (50MB) "

	return ${TPASS} 
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
EXT201Test(){
	# 虚拟成第一个未使用的回环设备
	loopDev="$(losetup -f)"

	losetup -f ${imgFile}
	EXT201RetParse "losetup -f ${imgFile}"
    
	# 格式化为ext2格式
	mkfs.ext2 ${loopDev} &>/dev/null
	EXT201RetParse "mkfs.ext2 ${loopDev}"

	# 挂载
	mount ${loopDev} ${imgMountDir}
	EXT201RetParse "mount ${loopDev} ${imgMountDir}"

	# 休眠2s
	sleep 2
	
	# 取消挂载
	umount ${loopDev}
	EXT201RetParse "umount ${loopDev}"

        # 卸载回环设备
	losetup -d ${loopDev}
	EXT201RetParse "losetup -d ${loopDev}"

	# 判断是否卸载成功，如果没有卸载，应该是autoclear = 1
        losetup -a | grep -q ${loopDev}
        if [ $? -eq 0 ];then
		local tmploop="true"
		while [ "${tmploop}" == "true" ]
		do
                	umount ${loopDev}
			[ $? -eq 0 ] && tmploop="false"

                        # 可能存在umount提示not mounted,导致死循环
                        losetup -a | grep -q ${loopDev}
                        [ $? -ne 0 ] && tmploop="false"
			
			# 休眠1s
			sleep 1
		done

                EXT201RetParse "AUTOCLEAR = 1: umount ${loopDev}"
	fi

	return ${TPASS}
}


## TODO: 测试收尾清除工作
##
EXT201Clean(){
	echo "Clean ..."

	# 判断是否挂载
	mount | grep -q ${loopDev}
	if [ $? -eq 0 ];then
		umount ${loopDev}
	fi

        # 判断是否使用回环设备
        losetup -a | grep -q ${loopDev}
        if [ $? -eq 0 ];then
		losetup -d ${loopDev}
		EXT201RetParse "losetup -d ${loopDev}"
        fi

	# 判断是否卸载成功，如果没有卸载，应该是autoclear = 1
        losetup -a | grep -q ${loopDev}
        if [ $? -eq 0 ];then
		local tmploop="true"
		while [ "${tmploop}" == "true" ]
		do
                	umount ${loopDev}
			[ $? -eq 0 ] && tmploop="false"

                        # 可能存在umount提示not mounted,导致死循环
                        losetup -a | grep -q ${loopDev}
                        [ $? -ne 0 ] && tmploop="false"
			
			# 休眠1s
			sleep 1
		done

                EXT201RetParse "AUTOCLEAR = 1: umount ${loopDev}"
	fi

	# 删除挂在目录
	if [ -d "${imgMountDir}" ];then
		rm -rf ${imgMountDir}
	fi

	# 删除虚拟文件
	if [ -f "${imgFile}" ];then
		rm -rf ${imgFile}
	fi

	unset -v loopDev imgMountDir imgFile 
}


## TODO: 解析函数返回值
## In  : $1 => log
EXT201RetParse(){
	local ret=$?
	local logstr=""

	if [ $# -eq 1 ];then
		logstr="$1"
	fi

	if [ $ret -eq 0 ];then       
		echo "[pass] : ${logstr}"
	else
		echo "[fail] : ${logstr}"
		EXT201Clean
		exit $TFAIL
	fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
EXT201Main(){
	EXT201USAGE

	EXT201Init

	EXT201Test

	EXT201Clean

	return ${TPASS}
}


EXT201Main
exit $?
