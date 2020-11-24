#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   02-volume.sh
# Version:    1.0
# Date:       2019/10/15
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   volume - 02 物理卷、卷组、逻辑卷进行扩容以及逻辑卷缩小
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------

# 结果判断
VOLUME02RET=${TPASS}


## TODO: 使用ctrl+c退出
##
Volume02OnCtrlC(){
	echo "正在优雅的退出..."
	Volume02Clean

	exit ${TCONF}
}


## TODO: 用户界面
##
Volume02USAGE(){
	cat >&1 <<EOF
--------- volume - 02 物理卷、卷组、逻辑卷扩容以及逻辑卷缩小 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
Volume02Init(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'Volume02OnCtrlC' INT

	# 虚拟镜像文件名称
	imgFileList=("${FSTESTDIR}/volume02-01.img" "${FSTESTDIR}/volume02-02.img")

	# 回环磁盘设备，用作物理卷
	pvDevList=()

	# 扩容虚拟文件 
	extendFile="${FSTESTDIR}/volume02-extend.img"
	# 扩容回环设备
	extendDev=""

	# 创建逻辑卷挂载目录
	lvMountDir="${FSTESTDIR}/volume02-lvMntDir"
	[ -d ${lvMountDir} ] && rm -rf ${lvMountDir}
	mkdir ${lvMountDir}
	Volume02RetParse "Create mount dir ${lvMountDir}"

	local imgfile=""
	local pvdev=""
	for imgfile in ${imgFileList[*]}
	do
		# 创建50MB虚拟镜像文件
		dd if=/dev/zero of=${imgfile} bs=1M count=50 &>/dev/null
		Volume02RetParse "Create img File ${imgfile} (50MB)"
    		
		# 虚拟成回环设备
		pvdev="$(losetup -f)"

		losetup -f ${imgfile}
		Volume02RetParse "losetup -f ${imgfile} (${pvdev})"
		pvDevList=(${pvDevList} ${pvdev})
	done
	
	# 创建50MB虚拟镜像文件
	dd if=/dev/zero of=${extendFile} bs=1M count=50 &>/dev/null
	Volume02RetParse "Create img extend File ${extendFile} (50MB)"
    		
	# 扩展文件虚拟成回环设备
   	extendDev="$(losetup -f)"

	losetup -f ${extendFile}
	Volume02RetParse "losetup -f ${extendFile} (${extendDev})"

	return ${TPASS} 
}


## TODO : volume - 01创建和删除逻辑卷、卷组、物理卷 
## Out  : ##        0=> Success
##        1=> Fail
##        other=> TCONF
Volume02Test(){
	# 卷组名
	vgName="volume02-vg"
	# 逻辑卷名
	lvName="volume02-lv"

	# 创建物理卷
	pvcreate ${pvDevList[*]} > /dev/null
	Volume02RetParse "pvcreate ${pvDevList[*]}"
	# 创建卷组
	vgcreate ${vgName} ${pvDevList[*]} > /dev/null
	Volume02RetParse "vgcreate ${vgName} ${pvDevList[*]}"
	# 激活卷组
	vgchange -a y ${vgName}	 > /dev/null
	Volume02RetParse "vgchange -a y ${vgName}"
	# 创建逻辑卷
	lvcreate -n ${lvName} -L 20M ${vgName} > /dev/null
	Volume02RetParse "lvcreate -n ${lvName} -L 20M ${vgName}"
	# 格式化为ext4格式
	mkfs.ext4 /dev/${vgName}/${lvName} &>/dev/null
	Volume02RetParse "mkfs.ext4 /dev/${vgName}/${lvName}"
	# 挂载
	mount /dev/${vgName}/${lvName} ${lvMountDir}
	Volume02RetParse "mount /dev/${vgName}/${lvName} ${lvMountDir}"

# 20191017,gjb验证resize2fs,用于更新文件系统大小
	df -Th | grep ${lvMountDir}	
	Volume02RetParse "df -Th | grep ${lvMountDir}"
	# 扩容物理卷
	pvcreate ${extendDev} > /dev/null
	Volume02RetParse "pvcreate ${extendDev}"
	# 扩容卷组
	vgextend ${vgName} ${extendDev} > /dev/null
	Volume02RetParse "vgextend ${vgName} ${extendDev}"
	# 扩容逻辑卷
	lvextend -L +10M /dev/${vgName}/${lvName} > /dev/null
	Volume02RetParse "lvextend -L +10M /dev/${vgName}/${lvName}"
	# 使逻辑卷调容生效
	resize2fs /dev/${vgName}/${lvName} > /dev/null
	Volume02RetParse "resize2fs /dev/${vgName}/${lvName}"
# 20191017,打印逻辑卷容量
	df -Th | grep ${lvMountDir}
	Volume02RetParse "df -Th | grep ${lvMountDir}"

	# 访问创建文件和目录
	touch ${lvMountDir}/testfile
	Volume02RetParse "touch ${lvMountDir}/testfile"
	mkdir ${lvMountDir}/testdir
	Volume02RetParse "mkdir ${lvMountDir}/testdir"
	# 取消挂载
	umount ${lvMountDir}
	Volume02RetParse "umount /dev/${vgName}/${lvName}"
	
	# 查看文件系统完整性
	e2fsck -fy /dev/${vgName}/${lvName} > /dev/null 
	Volume02RetParse "e2fsck -fy /dev/${vgName}/${lvName}"
	# 使逻辑卷调容到20M
	resize2fs /dev/${vgName}/${lvName} 20M > /dev/null
	Volume02RetParse "resize2fs /dev/${vgName}/${lvName} 20M"
	# 减小逻辑卷到20M
	lvreduce -f -L 20M /dev/${vgName}/${lvName} > /dev/null
	Volume02RetParse "lvreduce -f -L 20M /dev/${vgName}/${lvName}"
	# 使逻辑卷调容生效
	resize2fs /dev/${vgName}/${lvName} > /dev/null
	Volume02RetParse "resize2fs /dev/${vgName}/${lvName}"
	# 挂载
	mount /dev/${vgName}/${lvName} ${lvMountDir}
	Volume02RetParse "mount /dev/${vgName}/${lvName} ${lvMountDir}"
	# 打印逻辑卷容量
	df -Th | grep ${lvMountDir}
	Volume02RetParse "df -Th | grep ${lvMountDir}"

	# 取消挂载
	umount ${lvMountDir}
	Volume02RetParse "umount /dev/${vgName}/${lvName}"
	# 删除逻辑卷
	lvremove -f /dev/${vgName}/${lvName} > /dev/null
	Volume02RetParse "lvremove -f /dev/${vgName}/${lvName}"
	# 取消激活卷组
	vgchange -a n ${vgName}	> /dev/null
	Volume02RetParse "vgchange -a n ${vgName}"
	# 删除卷组
	vgremove ${vgName} > /dev/null
	Volume02RetParse "vgremove ${vgName}"
	# 删除物理卷,包括扩容物理卷	 
	pvremove ${pvDevList[*]} ${extendDev} >/dev/null
	Volume02RetParse "pvremove ${pvDevList[*]} ${extendDev}"

	return ${TPASS}
}


## TODO : 测试收尾清除工作
##
Volume02Clean(){
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

	# 判断是否使用扩展文件，挂载到回环设备
	losetup -a | grep -q ${extendDev}
	if [ $? -eq 0 ];then
		losetup -d ${extendDev}
	fi

	# 删除挂载目录
	if [ -d "${lvMountDir}" ];then
		rm -rf ${lvMountDir}
	fi

	# 删除扩展虚拟文件
	if [ -f "${extendFile}" ];then
		rm -rf ${extendFile}
	fi

	# 删除虚拟文件
	local imgfile=""
	for imgfile in ${imgFileList[*]}
	do
		if [ -f "${imgfile}" ];then
			rm -rf ${imgfile}
		fi
	done

	unset -v pvDevList lvMountDir imgFileList vgName lvName extendDev extendFile 
}


## TODO: 解析函数返回值
## In  : $1 => log
##     : $2 => 是否退出测试,False不退出
Volume02RetParse(){
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
		Volume02Clean
		if [ "Z$flag" != "ZFalse" ];then
			exit ${TFAIL}
		else
			VOLUME02RET=${TFAIL}
		fi
	fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
Volume02Main(){
	Volume02USAGE

	Volume02Init

	Volume02Test

	Volume02Clean

	return ${TPASS}
}


Volume02Main
exit ${VOLUME02RET}
