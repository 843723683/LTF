#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-volume.sh
# Version:    1.0
# Date:       2019/10/15
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   volume - 01创建和删除逻辑卷、卷组、物理卷
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------

# 结果判断
VOLUME01RET=${TPASS}


## TODO: 使用ctrl+c退出
##
Volume01OnCtrlC(){
	echo "正在优雅的退出..."
	Volume01Clean

	exit ${TCONF}
}


## TODO: 用户界面
##
Volume01USAGE(){
	cat >&1 <<EOF
--------- volume - 01创建和删除逻辑卷、卷组、物理卷 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
Volume01Init(){
	# 判断root用户
	if [ `id -u` -ne 0 ];then
		echo "Must use root ！"
		exit ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'Volume01OnCtrlC' INT

	# 虚拟镜像文件名称
	imgFileList=("${FSTESTDIR}/volume01-01.img" "${FSTESTDIR}/volume01-02.img")

	# 回环磁盘设备，用作物理卷
	pvDevList=()    

	# 逻辑卷挂载目录
	lvMountDir="${FSTESTDIR}/volume01-lvMntDir"
	[ -d ${lvMountDir} ] && rm -rf ${lvMountDir}
	mkdir ${lvMountDir}
	Volume01RetParse "Create mount dir ${lvMountDir}"

	local imgfile=""
	local pvdev=""
	for imgfile in ${imgFileList[*]}
	do
		# 创建50MB虚拟镜像文件
		dd if=/dev/zero of=${imgfile} bs=1M count=50 &>/dev/null
		Volume01RetParse "Create img File ${imgfile} (50MB)"
    		
		# 虚拟成回环设备
		pvdev="$(losetup -f)"

		losetup -f ${imgfile}
		Volume01RetParse "losetup -f ${imgfile} (${pvdev})"
		pvDevList=(${pvDevList} ${pvdev})
	done

	return ${TPASS} 
}


## TODO : volume - 01创建和删除逻辑卷、卷组、物理卷 
## Out  : 0=> Success
##        1=> Fail
##        other=> TCONF
Volume01Test(){
	# 卷组名
	vgName="volume01-vg"
	# 逻辑卷名
	lvName="volume01-lv"

	# 创建物理卷
	pvcreate ${pvDevList[*]} > /dev/null
	Volume01RetParse "pvcreate ${pvDevList[*]}"
	# 创建卷组
	vgcreate ${vgName} ${pvDevList[*]} > /dev/null
	Volume01RetParse "vgcreate ${vgName} ${pvDevList[*]}"
	# 激活卷组
	vgchange -a y ${vgName}	 > /dev/null
	Volume01RetParse "vgchange -a y ${vgName}"
	# 创建逻辑卷
	lvcreate -n ${lvName} -L 20M ${vgName} > /dev/null
	Volume01RetParse "lvcreate -n ${lvName} -L 20M ${vgName}"
	# 格式化为ext4格式
	mkfs.ext4 /dev/${vgName}/${lvName} &>/dev/null
	Volume01RetParse "mkfs.ext4 /dev/${vgName}/${lvName}"
	# 挂载
	mount /dev/${vgName}/${lvName} ${lvMountDir}
	Volume01RetParse "mount /dev/${vgName}/${lvName} ${lvMountDir}"
	# 访问创建文件和目录
	touch ${lvMountDir}/testfile
	Volume01RetParse "touch ${lvMountDir}/testfile"
	mkdir ${lvMountDir}/testdir
	Volume01RetParse "mkdir ${lvMountDir}/testdir"
	
	# 取消挂载
	umount /dev/${vgName}/${lvName}
	Volume01RetParse "umount /dev/${vgName}/${lvName}"
	# 删除逻辑卷
	lvremove -f /dev/${vgName}/${lvName} > /dev/null
	Volume01RetParse "lvremove -f /dev/${vgName}/${lvName}"
	# 取消激活卷组
	vgchange -a n ${vgName}	> /dev/null
	Volume01RetParse "vgchange -a n ${vgName}"
	# 删除卷组
	vgremove ${vgName} > /dev/null
	Volume01RetParse "vgremove ${vgName}"
	# 删除物理卷	 
	pvremove ${pvDevList[*]} >/dev/null
	Volume01RetParse "pvremove ${pvDevList[*]}"

	return ${TPASS}
}


## TODO : 测试收尾清除工作
##
Volume01Clean(){
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
Volume01RetParse(){
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
		Volume01Clean
		if [ "Z$flag" != "ZFalse" ];then
			exit ${TFAIL}
		else
			VOLUME01RET=${TFAIL}
		fi
	fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
Volume01Main(){
	Volume01USAGE

	Volume01Init

	Volume01Test

	Volume01Clean

	return ${TPASS}
}


Volume01Main
exit ${VOLUME01RET}
