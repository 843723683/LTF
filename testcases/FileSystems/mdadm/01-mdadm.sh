#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-mdadm.sh
# Version:    1.0
# Date:       2021/06/17
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2021/06/17
# Function:   mdadm - 01 创建和删除软RAID
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------

# 结果判断
MDADM01RET=${TPASS}


## TODO: 使用ctrl+c退出
##
Mdadm01OnCtrlC(){
	echo "正在优雅的退出..."
	Mdadm01Clean

	exit ${TCONF}
}


## TODO: 用户界面
##
Mdadm01USAGE(){
	cat >&1 <<EOF
--------- mdadm - 01创建和删除软RAID ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
Mdadm01Init(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'Mdadm01OnCtrlC' INT

	# 虚拟镜像文件名称
	imgFileList=("${FSTESTDIR}/mdadm01-01.img" "${FSTESTDIR}/mdadm01-02.img")

	# 回环磁盘设备，用作物理设备
	pvDevList=()    

	# md0挂载目录
	mdMountDir="${FSTESTDIR}/mdadm01-lvMntDir"
	[ -d ${mdMountDir} ] && rm -rf ${mdMountDir}
	mkdir ${mdMountDir}
	Mdadm01RetParse "Create mount dir ${mdMountDir}"

	local imgfile=""
	local pvdev=""
	for imgfile in ${imgFileList[*]}
	do
		# 创建50MB虚拟镜像文件
		dd if=/dev/zero of=${imgfile} bs=1M count=50 &>/dev/null
		Mdadm01RetParse "Create img File ${imgfile} (50MB)"
    		
		# 虚拟成回环设备
		pvdev="$(losetup -f)"

		losetup -f ${imgfile}
		Mdadm01RetParse "losetup -f ${imgfile} (${pvdev})"
		pvDevList=(${pvDevList} ${pvdev})
	done

	return ${TPASS} 
}


## TODO : mdadm - 01 创建和删除软RAID
## Out  : 0=> Success
##        1=> Fail
##        other=> TCONF
Mdadm01Test(){
	# 软RAID设备名
	md0Dev="/dev/md0"

	# 创建raid1设备
	echo "y" | mdadm --create --verbose ${md0Dev} --level=raid1 --raid-devices=2 ${pvDevList[*]}
	Mdadm01RetParse "mdadm --create --verbose ${md0Dev} --level=raid1 --raid-devices=2 ${pvDevList[*]}"

	# 查看设备信息
	mdadm -D ${md0Dev}
	Mdadm01RetParse "mdadm -D ${md0Dev}"

	# 格式化为ext4格式
	mkfs.ext4 ${md0Dev} &>/dev/null
	Mdadm01RetParse "mkfs.ext4 ${md0Dev}"

	# 挂载
	mount ${md0Dev} ${mdMountDir}
	Mdadm01RetParse "mount ${md0Dev} ${mdMountDir}"
	# 访问创建文件和目录
	touch ${mdMountDir}/testfile
	Mdadm01RetParse "touch ${mdMountDir}/testfile"
	mkdir ${mdMountDir}/testdir
	Mdadm01RetParse "mkdir ${mdMountDir}/testdir"
	# 取消挂载
	umount ${md0Dev} 
	Mdadm01RetParse "umount ${md0Dev}"

	# 删除软RAID设备
	mdadm -S ${md0Dev}
	Mdadm01RetParse "mdadm -S ${md0Dev}"
	# 清除loop设备中RAID信息
	local pvdev=""
	for pvdev in ${pvDevList[*]}
	do
		mdadm --misc --zero-superblock ${pvdev}
		Mdadm01RetParse "mdadm --misc --zero-superblock ${pvdev}"
	done

	return ${TPASS}
}


## TODO : 测试收尾清除工作
##
Mdadm01Clean(){
	# 取消挂载
	mount | grep -q "${mdMountDir}"
	if [ $? -eq 0 ];then
		umount ${md0Dev}
	fi

	# 判断是否存在软RAID设备
	if [ -e "${md0Dev}" ];then
		mdadm -S ${md0Dev}
		# 清除loop设备中RAID信息
		local pvdev=""
		for pvdev in ${pvDevList[*]}
		do
			mdadm --misc --zero-superblock ${pvdev}
			Mdadm01RetParse "mdadm --misc --zero-superblock ${pvdev}"
		done
	else
		echo "Can't found ${md0Dev}"
	fi

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
	if [ -d "${mdMountDir}" ];then
        	rm -rf ${mdMountDir}
	fi

	# 删除虚拟文件
    	local imgfile=""
	for imgfile in ${imgFileList[*]}
	do
		if [ -f "${imgfile}" ];then
			rm -rf ${imgfile}
		fi
	done

	unset -v pvDevList mdMountDir imgFileList
}


## TODO: 解析函数返回值
## In  : $1 => log
##     : $2 => 是否退出测试,False不退出
Mdadm01RetParse(){
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
		Mdadm01Clean
		if [ "Z$flag" != "ZFalse" ];then
			exit ${TFAIL}
		else
			MDADM01RET=${TFAIL}
		fi
	fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
Mdadm01Main(){
	Mdadm01USAGE

	Mdadm01Init

	Mdadm01Test

	Mdadm01Clean

	return ${TPASS}
}


Mdadm01Main
exit ${MDADM01RET}
