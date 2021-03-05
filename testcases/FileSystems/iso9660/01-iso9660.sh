#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-iso9660.sh
# Version:    1.0
# Date:       2021/03/05
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2021/03/05
# Function:   iso9660 - 01创建、访问、卸载ISO9660
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------

# 结果判断
ISO9660_01RET=${TPASS}


## TODO: 使用ctrl+c退出
##
ISO9660_01OnCtrlC(){
	echo "正在优雅的退出..."
	ISO9660_01Clean

	exit ${TCONF}
}


## TODO: 用户界面
##
ISO9660_01USAGE(){
	cat >&1 <<EOF
--------- iso9660 - 01创建、访问、卸载ISO9660 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
ISO9660_01Init(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'ISO9660_01OnCtrlC' INT

	# ISO名称
	isoImg="${FSTESTDIR}/iso9660_01.iso"

	# 创建临时文件和目录
	isoFileName="iso9660_01_file.txt"
	isoFile="${FSTESTDIR}/${isoFileName}"
	writeText="hello kylin"
	isoDir="${FSTESTDIR}/iso9660_01_dir"

	# ISO挂载目录
	isoMountDir="${FSTESTDIR}/iso9660_01_MntDir"
	[ -d ${isoMountDir} ] && rm -rf ${isoMountDir}
	mkdir ${isoMountDir}
	ISO9660_01RetParse "Create mount dir ${isoMountDir}"

	touch ${isoFile}
	ISO9660_01RetParse "Create File ${isoFile}"
	echo ${writeText} > ${isoFile}
	ISO9660_01RetParse "Write Text ${writeText}"

	local isodir=""
	mkdir ${isoDir}
	ISO9660_01RetParse "Create dir ${isoDir}"

	return ${TPASS} 
}


## TODO : iso9660 - 01创建、访问、卸载ISO9660
## Out  : 0=> Success
##        1=> Fail
##        other=> TCONF
ISO9660_01Test(){
	# 生成iso9660
	mkisofs -r -o ${isoImg} ${FSTESTDIR} > /dev/null
	ISO9660_01RetParse "mkisofs -r -o ${isoImg} ${FSTESTDIR}"

        # 虚拟成第一个未使用的回环设备
        loopDev="$(losetup -f)"
        losetup -f ${isoImg}
        ISO9660_01RetParse "losetup -f ${isoImg}"

	# 挂载
	mount ${loopDev} ${isoMountDir}		
	ISO9660_01RetParse "mount ${loopDev} ${isoMountDir}"

	# 判断文件内容
	cat ${isoMountDir}/${isoFileName} | grep "${writeText}"
	ISO9660_01RetParse "cat ${isoMountDir}/${isoFileName} | grep ${writeText}"

	sleep 2

	# 取消挂载
	mount | grep -q "${loopDev}"
	if [ $? -eq 0 ];then
		umount ${loopDev} 
	fi

        # 判断是否使用回环设备
        losetup -a | grep -q ${loopDev}
        if [ $? -eq 0 ];then
                losetup -d ${loopDev}
                ISO9660_01RetParse "losetup -d ${loopDev}"
        fi

	# 删除img
	if [ -f "${isoImg}" ];then
		rm ${isoImg} -rf
	fi

	# 删除iso9660
	if [ -f "${isoFile}" ];then
		rm ${isoFile} -rf
	fi

	# 删除目录
	if [ -d "${isoDir}" ];then
        	rm -rf ${isoDir}
	fi

	# 删除挂载目录
	if [ -d "${isoMountDir}" ];then
        	rm -rf ${isoMountDir}
	fi

	return ${TPASS}
}


## TODO : 测试收尾清除工作
##
ISO9660_01Clean(){
	# 取消挂载
	mount | grep -q "${loopDev}"
	if [ $? -eq 0 ];then
		umount ${loopDev} 
	fi

        # 判断是否使用回环设备
        losetup -a | grep -q ${loopDev}
        if [ $? -eq 0 ];then
                losetup -d ${loopDev}
                ISO9660_01RetParse "losetup -d ${loopDev}"
        fi

	# 删除img
	if [ -f "${isoImg}" ];then
		rm ${isoImg} -rf
	fi

	# 删除iso9660
	if [ -f "${isoFile}" ];then
		rm ${isoFile} -rf
	fi

	# 删除目录
	if [ -d "${isoDir}" ];then
        	rm -rf ${isoDir}
	fi

	# 删除挂载目录
	if [ -d "${isoMountDir}" ];then
        	rm -rf ${isoMountDir}
	fi

	unset -v loopDev isoMountDir isoFileName isoFile isoDirList isoMountDir
}


## TODO: 解析函数返回值
## In  : $1 => log
##     : $2 => 是否退出测试,False不退出
ISO9660_01RetParse(){
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
		ISO9660_01Clean
		if [ "Z$flag" != "ZFalse" ];then
			exit ${TFAIL}
		else
			ISO9660_01RET=${TFAIL}
		fi
	fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
ISO9660_01Main(){
	ISO9660_01USAGE

	ISO9660_01Init

	ISO9660_01Test

	ISO9660_01Clean

	return ${TPASS}
}


ISO9660_01Main
exit ${ISO9660_01RET}
