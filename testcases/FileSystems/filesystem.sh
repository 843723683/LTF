#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   filesystem.sh
# Version:    1.0
# Date:       2019/10/12
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/10/12
# Function:   调用不同的文件系统测试程序
# In :        filesystem testcase name(testcase dir name)
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO : 测试前的初始化验证 
## In   : $1=>testcase dir name
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
FSInit(){
	local testdir="$1"
    # 加载库函数
    if [ -f "./lib/fs-lib.sh" ];then
        source ./lib/fs-lib.sh
    else
        echo "./lib/fs-lib.sh : Can't find !"
        return 1
    fi

	# 判断目录有效性
	if [ -d "${testdir}" ];then
		echo "Start Test FileSystem - ${testdir}"
	else
		echo "TCONF : Can't find testcases (${testdir})"
		return ${TCONF}
	fi

	return ${TPASS}
}


## TODO : 执行测试
## In   : $1=>testcase dir name
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
FSRun(){
	# 测试文件目录
	local testdir="$1"
	# 测试文件，通过数组保存
	local testfilelist=($(find ${testdir} -type f | sort))
	# 测试文件路径
	local testfile=""
	local ret="${TPASS}"

	for testfile in ${testfilelist[*]}
	do
		[[ "$testfile" =~ "readme"|"swp" ]] && continue
		if [ -x "$testfile" ];then
			bash $testfile
			ret=$?
		else
			echo "[ TFAIL ] $testfile : No executable permissions"
			continue
		fi

		if [ $ret -eq ${TPASS} ];then
			echo "[ TPASS ] - $testfile"
		elif [ $ret -eq ${TFAIL} ];then
			echo "[ TFAIL ] - $testfile"
		else
			echo "[ TCONF ] - $testfile"
		fi
	done

	return $ret
}

## TODO: 解析函数返回值
FSRetParse(){
	local ret=$?
	if [ $ret -ne ${TPASS} ];then
		exit $ret
	fi
}


## TODO: fsmain
## In: $1=>testcase dir name
## Out  : 
##        0=> Success
##        1=> Fail
##        other=> TCONF
FSMain(){
	local testdir=$(basename $1)
	cd $(dirname $1)

	FSInit ${testdir}
	FSRetParse

	FSRun ${testdir}
	FSRetParse

	return ${TPASS}
}

FSMain $*
exit $?