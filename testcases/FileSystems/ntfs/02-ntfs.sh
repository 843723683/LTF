#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   02-ntfs.sh
# Version:    1.0
# Date:       2019/10/12
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   ntfs - 02访问/读写ntfs文件系统
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 使用ctrl+c退出
##
NTFS02OnCtrlC(){
    echo "正在优雅的退出..."
    NTFS02Clean

    exit ${TCONF}
}


## TODO: 用户界面
##
NTFS02USAGE(){
    cat >&1 <<EOF
--------- ntfs - 02访问/读写ntfs文件系统 ---------
EOF
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
NTFS02Init(){
    # 判断root用户
    if [ `id -u` -ne 0 ];then
        echo "Must use root ！"
        exit ${TCONF}
    fi

    # 信号捕获ctrl+c
    trap 'NTFS02OnCtrlC' INT

    # 虚拟镜像文件名称
    imgFile="/var/tmp/ntfs02.img"

    # 挂载目录
    imgMountDir="/var/tmp/ntfs02-dir"
    [ -d ${imgMountDir} ] && rm -rf ${imgMountDir}
    mkdir ${imgMountDir}
    NTFS02RetParse "Create mount dir ${imgMountDir}"

    # 创建50MB大小的ntfs虚拟镜像文件
    dd if=/dev/zero of=${imgFile} bs=1M count=50 &>/dev/null
    NTFS02RetParse "Create img File ${imgFile} (50MB)"

    return ${TPASS} 
}


## TODO : 测试前的初始化 
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
NTFS02Test(){
    # 虚拟成第一个未使用的回环设备
    loopDev="$(losetup -f)"

    losetup -f ${imgFile}
    NTFS02RetParse "losetup -f ${imgFile}"
    
    # 格式化为ntfs格式
    mkfs.ntfs ${loopDev} &>/dev/null
    NTFS02RetParse "mkfs.ntfs ${loopDev}"

    # 挂载
    mount ${loopDev} ${imgMountDir}
    NTFS02RetParse "mount ${loopDev} ${imgMountDir}"

    # 访问创建文件和目录
    touch ${imgMountDir}/testfile
    NTFS02RetParse "touch ${imgMountDir}/testfile"
    mkdir ${imgMountDir}/testdir
    NTFS02RetParse "mkdir ${imgMountDir}/testdir"

    # 取消挂载
    umount ${loopDev}
    NTFS02RetParse "umount ${loopDev}"

    # 卸载回环设备
    if [ "Z${loopDev}" != "Z" ];then
        losetup -d ${loopDev}
        NTFS02RetParse "losetup -d ${loopDev}"
    fi

    return ${TPASS}
}


## TODO : 测试收尾清除工作
##
NTFS02Clean(){
    # 判断是否挂在
    mount | grep -q ${loopDev}
    if [ $? -eq 0 ];then
        umount ${loopDev}
    fi

    # 判断是否使用回环设备
    losetup -a | grep -q ${loopDev}
    if [ $? -eq 0 ];then
        losetup -d ${loopDev}
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
NTFS02RetParse(){
    local ret=$?
    local logstr=""

    if [ $# -eq 1 ];then
        logstr="$1"
    fi

    if [ $ret -eq 0 ];then       
        echo "[pass] : ${logstr}"
    else
        echo "[fail] : ${logstr}"
        NTFS02Clean
        exit $TFAIL
    fi
}


## TODO : Main
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
NTFS02Main(){
    NTFS02USAGE

    NTFS02Init

    NTFS02Test

    NTFS02Clean

    return ${TPASS}
}


NTFS02Main
exit $?
