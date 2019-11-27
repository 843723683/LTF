#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-ntfs.sh
# Version:    1.0
# Date:       2019/10/12
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   ntfs - 01创建/挂载ntfs文件系统
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 使用ctrl+c退出
##
NTFS01OnCtrlC(){
	echo "正在优雅的退出..."
	NTFS01Clean

	exit ${TCONF}
}

## TODO: 用户界面
##
NTFS01USAGE(){
	cat >&1 <<EOF
--------- ntfs - 01创建/挂载ntfs文件系统 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
NTFS01Init(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'NTFS01OnCtrlC' INT

	# 虚拟镜像文件名称
	imgFile="/var/tmp/ntfs01.img"

	# 挂载目录
	imgMountDir="/var/tmp/ntfs01-dir"
	[ -d ${imgMountDir} ] && rm -rf ${imgMountDir}
	mkdir ${imgMountDir}
	NTFS01RetParse "Create mount dir ${imgMountDir}"

	# 创建50MB大小的ntfs虚拟镜像文件
	dd if=/dev/zero of=${imgFile} bs=1M count=50 &>/dev/null
	NTFS01RetParse "Create img File ${imgFile} (50MB) "

	return ${TPASS} 
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
NTFS01Test(){
	# 虚拟成第一个未使用的回环设备
	loopDev="$(losetup -f)"

	losetup -f ${imgFile}
	NTFS01RetParse "losetup -f ${imgFile}"
    
	# 格式化为ntfs格式
	mkfs.ntfs ${loopDev} &>/dev/null
	NTFS01RetParse "mkfs.ntfs ${loopDev}"

	# 挂载
	mount ${loopDev} ${imgMountDir}
	NTFS01RetParse "mount ${loopDev} ${imgMountDir}"

	# 休眠2s，解决ntfs马上取消挂载会报错（umount: /var/tmp/ntfs01-dir：目标忙）
	sleep 2

	# 取消挂载
	umount ${loopDev}
	NTFS01RetParse "umount ${loopDev}"

        # 卸载回环设备
        losetup -d ${loopDev}
        NTFS01RetParse "losetup -d ${loopDev}"

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

                NTFS01RetParse "AUTOCLEAR = 1: umount ${loopDev}"
        fi

	return ${TPASS}
}


## TODO: 测试收尾清除工作
##
NTFS01Clean(){
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
                NTFS01RetParse "losetup -d ${loopDev}"
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

                NTFS01RetParse "AUTOCLEAR = 1: umount ${loopDev}"
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
NTFS01RetParse(){
	local ret=$?
	local logstr=""

	if [ $# -eq 1 ];then
		logstr="$1"
	fi

	if [ $ret -eq 0 ];then       
		echo "[pass] : ${logstr}"
	else
		echo "[fail] : ${logstr}"
		NTFS01Clean
		exit $TFAIL
	fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
NTFS01Main(){
	NTFS01USAGE

	NTFS01Init

	NTFS01Test

	NTFS01Clean

	return ${TPASS}
}


NTFS01Main
exit $?
