#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   fs-lib.sh
# Version:    1.0
# Date:       2019/10/12
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   定义用于文件系统测试常用变量和函数
# ----------------------------------------------------------------------
readonly TPASS=0
readonly TFAIL=1
readonly TCONF=2

# FS测试临时目录
readonly FSTESTDIR="/var/tmp"


export TPASS
export TFAIL
export TCONF

export FSTESTDIR
