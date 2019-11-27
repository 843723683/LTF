#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-ext4.sh
# Version:    1.0
# Date:       2019/10/12
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   ext4 - 01创建/挂载ext4文件系统
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 使用ctrl+c退出
##
EXT401OnCtrlC(){
	echo "正在优雅的退出..."
	EXT401Clean
	
	exit ${TCONF}
}

## TODO: 用户界面
##
EXT401USAGE(){
	cat >&1 <<EOF
--------- ext4 - 01创建/挂载ext4文件系统 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
EXT401Init(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi
	
	# 信号捕获ctrl+c
	trap 'EXT401OnCtrlC' INT
	
	# 虚拟镜像文件名称
	imgFile="/var/tmp/ext401.img"
	
	# 挂载目录
	imgMountDir="/var/tmp/ext401-dir"
	[ -d ${imgMountDir} ] && rm -rf ${imgMountDir}
	mkdir ${imgMountDir}
	EXT401RetParse "Create mount dir ${imgMountDir}"
	
	# 创建50MB大小的ext4虚拟镜像文件
	dd if=/dev/zero of=${imgFile} bs=1M count=50 &>/dev/null
	EXT401RetParse "Create img File ${imgFile} (50MB) "
	
	return ${TPASS} 
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
EXT401Test(){
	# 虚拟成第一个未使用的回环设备
	loopDev="$(losetup -f)"
	
	losetup -f ${imgFile}
	EXT401RetParse "losetup -f ${imgFile}"
	
	# 格式化为ext4格式
	mkfs.ext4 ${loopDev} &>/dev/null
	EXT401RetParse "mkfs.ext4 ${loopDev}"
	
	# 挂载
	mount ${loopDev} ${imgMountDir}
	EXT401RetParse "mount ${loopDev} ${imgMountDir}"
	    
	# 休眠2s
	sleep 2

	# 取消挂载
	umount ${loopDev}
	EXT401RetParse "umount ${loopDev}"
	
	# 卸载回环设备
        losetup -d ${loopDev}
        EXT401RetParse "losetup -d ${loopDev}"

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

                EXT401RetParse "AUTOCLEAR = 1: umount ${loopDev}"
        fi

	return ${TPASS}
}


## TODO: 测试收尾清除工作
##
EXT401Clean(){
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
                EXT401RetParse "losetup -d ${loopDev}"
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

                EXT401RetParse "AUTOCLEAR = 1: umount ${loopDev}"
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
EXT401RetParse(){
	local ret=$?
	local logstr=""
	
	if [ $# -eq 1 ];then
		logstr="$1"
	fi
	
	if [ $ret -eq 0 ];then       
		echo "[pass] : ${logstr}"
	else
		echo "[fail] : ${logstr}"
		EXT401Clean
		exit $TFAIL
	fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
EXT401Main(){
	EXT401USAGE
	
	EXT401Init
	
	EXT401Test
	
	EXT401Clean
	
	return ${TPASS}
}


EXT401Main
exit $?
