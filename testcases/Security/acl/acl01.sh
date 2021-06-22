#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   01-acl.sh
# Version:    1.0
# Date:       2019/12/10
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   acl - 01 设置和查看文件、目录设置访问权限
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

set -u

## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Init(){
	# 创建临时目录
	testDir_acl01="${TmpTestDir_LTFLIB}/diracl01"
	mkdir ${testDir_acl01}
	[ ! -d "${testDir_acl01}" ] && return $TCONF

	# 创建临时文件
	testFile_acl01="${TmpTestDir_LTFLIB}/fileacl01"
	touch ${testFile_acl01}
	[ ! -f "${testFile_acl01}" ] && return $TCONF

	return $TPASS
}


## TODO : 测试文件，chmod设置读写执行
test1(){
	# 赋予读写执行权限
	chmod a+wrx ${testFile_acl01}
	CommRetParse_LTFLIB "chmod a+wrx ${testFile_acl01}" "True"
	
	# 写
	echo "echo helloworld" > ${testFile_acl01}
	CommRetParse_LTFLIB "echo \"echo helloworld\" > ${testFile_acl01}" "True"
	# 读
	cat "${testFile_acl01}" > /dev/null
	CommRetParse_LTFLIB "cat ${testFile_acl01}" "True"
	# 执行
	bash ${testFile_acl01} | grep -q "helloworld"
	CommRetParse_LTFLIB "bash ${testFile_acl01}" "True"
	
	# 去除读写执行权限
	chmod a-wrx ${testFile_acl01}
	CommRetParse_LTFLIB "chmod a-wrx ${testFile_acl01}" "True"

	# 写
	echo "echo helloworld" > ${testFile_acl01}
	CommRetParse_LTFLIB "echo \"echo helloworld\" > ${testFile_acl01}" "True"
	# 读
	cat "${testFile_acl01}" > /dev/null
	CommRetParse_LTFLIB "cat ${testFile_acl01}" "True"
	# 执行
	bash ${testFile_acl01} | grep -q "helloworld"
	CommRetParse_LTFLIB "bash ${testFile_acl01}" "True"
	
	# 目录
	chmod a+wrx ${testDir_acl01}
	CommRetParse_LTFLIB "chmod a+wrx ${testDir_acl01}" "True"
	
	return $TPASS
}


## TODO : 运行测试集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
RunAll(){
	test1
	TestRetParse_LTFLIB

	return $TPASS
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Clean(){
	Debug_LLE "rm -rf ${testDir_acl01} ${testFile_acl01}"
	rm -rf ${testDir_acl01} ${testFile_acl01}

	return $TPASS
}

#------------------------------------#

## TODO : 搭建运行环境
Setup(){
	# 加载库函数
	local libfile="${LIB_ROOT}/ltfLib.sh"
	if [ -f "${libfile}" ];then
		source ${libfile}
	else
                TConf_LLE "Can't found file(${libfile}) !"
                exit ${TCONF}
	fi
		
	# 注册函数
	RegFunc_LTFLIB "Init" "RunAll" "Clean"

	return ${TPASS}	
}


## TODO : 主函数
Main(){
	# 设置
	Setup
	TestRetParse_LTFLIB

	# 调用主函数
	Main_LTFLIB
	TestRetParse_LTFLIB
}


Main $@
Exit_LTFLIB $?
