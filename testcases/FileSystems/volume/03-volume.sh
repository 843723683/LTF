#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   03-volume.sh
# Version:    1.0
# Date:       2020/11/24
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2020/11/24
# Function:   volume - 03 LVM快照
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------

# 结果判断
VOLUME03RET=${TPASS}


## TODO: 使用ctrl+c退出
##
Volume03OnCtrlC(){
	echo "正在优雅的退出..."
	Volume03Clean

	exit ${TCONF}
}


## TODO: 用户界面
##
Volume03USAGE(){
	cat >&1 <<EOF
--------- volume - 03 LVM快照 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
Volume03Init(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'Volume03OnCtrlC' INT

	# 虚拟镜像文件名称
	imgFileList=("${FSTESTDIR}/volume03-01.img" "${FSTESTDIR}/volume03-02.img")

	# 回环磁盘设备，用作物理卷
	pvDevList=()    

	# 逻辑卷挂载目录
	lvMountDir="${FSTESTDIR}/volume03-lvMntDir"
	[ -d ${lvMountDir} ] && rm -rf ${lvMountDir}
	mkdir ${lvMountDir}
	Volume03RetParse "Create mount dir ${lvMountDir}"

	local imgfile=""
	local pvdev=""
	for imgfile in ${imgFileList[*]}
	do
		# 创建50MB虚拟镜像文件
		dd if=/dev/zero of=${imgfile} bs=1M count=50 &>/dev/null
		Volume03RetParse "Create img File ${imgfile} (50MB)"
    		
		# 虚拟成回环设备
		pvdev="$(losetup -f)"

		losetup -f ${imgfile}
		Volume03RetParse "losetup -f ${imgfile} (${pvdev})"
		pvDevList=(${pvDevList} ${pvdev})
	done

	# 快照卷名称
	lvSnap="lv03-snap"
	# 快照卷挂载目录
	lvMountSnapDir="${FSTESTDIR}/volume03-lvMntSnapDir"
	[ -d ${lvMountSnapDir} ] && rm -rf ${lvMountSnapDir}
	mkdir ${lvMountSnapDir}
	Volume03RetParse "Create mount dir ${lvMountSnapDir}"

	return ${TPASS} 
}


## TODO : volume - 03 LVM快照
## Out  : 0=> Success
##        1=> Fail
##        other=> TCONF
Volume03Test(){
	# 卷组名
	vgName="volume03-vg"
	# 逻辑卷名
	lvName="volume03-lv"

	# 创建物理卷
	pvcreate ${pvDevList[*]} > /dev/null
	Volume03RetParse "pvcreate ${pvDevList[*]}"
	# 创建卷组
	vgcreate ${vgName} ${pvDevList[*]} > /dev/null
	Volume03RetParse "vgcreate ${vgName} ${pvDevList[*]}"
	# 激活卷组
	vgchange -a y ${vgName}	 > /dev/null
	Volume03RetParse "vgchange -a y ${vgName}"
	# 创建逻辑卷
	lvcreate -n ${lvName} -L 20M ${vgName} > /dev/null
	Volume03RetParse "lvcreate -n ${lvName} -L 20M ${vgName}"
	# 格式化为ext4格式
	mkfs.ext4 /dev/${vgName}/${lvName} &>/dev/null
	Volume03RetParse "mkfs.ext4 /dev/${vgName}/${lvName}"
	# 挂载
	mount /dev/${vgName}/${lvName} ${lvMountDir}
	Volume03RetParse "mount /dev/${vgName}/${lvName} ${lvMountDir}"
	# 访问创建文件
	touch ${lvMountDir}/testfile
	Volume03RetParse "touch ${lvMountDir}/testfile"

	# 创建LVM快照卷
	lvcreate -s -L 20M -n ${lvSnap} /dev/${vgName}/${lvName} > /dev/null
	Volume03RetParse "lvcreate -s -L 20M -n ${lvSnap} /dev/${vgName}/${lvName}"
	# 原始卷 新增目录
	mkdir ${lvMountDir}/testdir
	Volume03RetParse "mkdir ${lvMountDir}/testdir"
	# 挂载LVM快照卷
	mount /dev/${vgName}/${lvSnap} ${lvMountSnapDir}
	Volume03RetParse "mount /dev/${vgName}/${lvSnap} ${lvMountSnapDir}"
	# 查看LVM快照内容
	ls ${lvMountSnapDir}
	ls ${lvMountSnapDir} -al | grep -q testdir
	if [ $? -eq 0 ];then
		false
		Volume03RetParse "ls ${lvMountSnapDir}"
	else
		true
		Volume03RetParse "ls ${lvMountSnapDir}"
	fi

	# 卸载快照卷
	umount /dev/${vgName}/${lvSnap}
	Volume03RetParse "umount /dev/${vgName}/${lvSnap}"
	# 删除快照卷
	lvremove -y /dev/${vgName}/${lvSnap} > /dev/null
	Volume03RetParse "lvremove -y /dev/${vgName}/${lvSnap}"
	# 取消挂载
	umount /dev/${vgName}/${lvName}
	Volume03RetParse "umount /dev/${vgName}/${lvName}"
	# 删除逻辑卷
	lvremove -f /dev/${vgName}/${lvName} > /dev/null
	Volume03RetParse "lvremove -f /dev/${vgName}/${lvName}"
	# 取消激活卷组
	vgchange -a n ${vgName}	> /dev/null
	Volume03RetParse "vgchange -a n ${vgName}"
	# 删除卷组
	vgremove ${vgName} > /dev/null
	Volume03RetParse "vgremove ${vgName}"
	# 删除物理卷	 
	pvremove ${pvDevList[*]} >/dev/null
	Volume03RetParse "pvremove ${pvDevList[*]}"

	return ${TPASS}
}


## TODO : 测试收尾清除工作
##
Volume03Clean(){
	# 卸载快照卷
	mount | grep -q "${lvMountSnapDir}"
	if [ $? -eq 0 ];then
		umount /dev/${vgName}/${lvSnap}
	fi

	# 删除快照卷
	lvdisplay | grep -q ${lvSnap}
	if [ $? -eq 0 ];then
		lvremove -y /dev/${vgName}/${lvSnap}
	fi

	# 取消挂载
	mount | grep -q "${lvMountDir}"
	if [ $? -eq 0 ];then
		umount /dev/${vgName}/${lvName}
	fi

	# 删除逻辑卷
	lvdisplay | grep -q ${lvName}
	if [ $? -eq 0 ];then
		lvremove -f /dev/${vgName}/${lvName}
	fi

	# 取消激活卷组,删除卷组
	vgdisplay | grep -q ${vgName}
	if [ $? -eq 0 ];then
		vgchange -a n ${vgName}	
		vgremove ${vgName}
	fi
	
	# 删除物理卷
	local pvdev=""
	for pvdev in ${pvDevList[*]}
	do
		pvdisplay | grep -q  ${pvdev}
    		if [ $? -eq 0 ];then
			pvremove ${pvdev}
		fi
	done

	# 判断是否使用回环设备
	local pvdev=""
	for pvdev in ${pvDevList[*]}
	do
		losetup -a | grep -q ${pvdev}
    		if [ $? -eq 0 ];then
        		losetup -d ${pvdev}
    		fi
	done

	# 删除挂载目录
	if [ -d "${lvMountDir}" ];then
        	rm -rf ${lvMountDir}
	fi

	# 删除快照卷挂载目录
	if [ -d "${lvMountSnapDir}" ];then
        	rm -rf ${lvMountSnapDir}
	fi

	# 删除虚拟文件
    	local imgfile=""
	for imgfile in ${imgFileList[*]}
	do
		if [ -f "${imgfile}" ];then
			rm -rf ${imgfile}
		fi
	done

	unset -v pvDevList lvMountDir imgFileList vgName lvName 
}


## TODO: 解析函数返回值
## In  : $1 => log
##     : $2 => 是否退出测试,False不退出
Volume03RetParse(){
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
		Volume03Clean
		if [ "Z$flag" != "ZFalse" ];then
			exit ${TFAIL}
		else
			VOLUME03RET=${TFAIL}
		fi
	fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
Volume03Main(){
	Volume03USAGE

	Volume03Init

	Volume03Test

	Volume03Clean

	return ${TPASS}
}


Volume03Main
exit ${VOLUME03RET}
