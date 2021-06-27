#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   git 
# Version:    1.0
# Date:       2021/06/26
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/26
# Function:   git 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="git 功能验证"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="git"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
	testdir1_git=${TmpTestDir_LTFLIB}/testdir1
	mkdir ${testdir1_git}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建目录失败${testdir1_git}"

	testdir2_git=${TmpTestDir_LTFLIB}/testdir2

	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	[ -f "${testdir1_git}" ] && rm -rf ${testdir1_git}
	[ -f "${testdir2_git}" ] && rm -rf ${testdir2_git}

	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	sha1_git=`echo "hello world" | git hash-object --stdin`
	CommRetParse_LTFLIB "echo \"hello world\" | git hash-object --stdin"
}


## TODO : 测试用例
testcase_2(){
	git init ${testdir1_git} --bare
	CommRetParse_LTFLIB "echo \"hello world\" | git hash-object --stdin"

	git clone ${testdir1_git} ${testdir2_git}
	CommRetParse_LTFLIB "git clone ${testdir1_git} ${testdir2_git}"

	cd ${testdir2_git}
	CommRetParse_FailDiy_LTFLIB ${ERROR} "进入目录失败 ${testdir2_git}"

	git config user.email "ltf@ltf.org"
	CommRetParse_LTFLIB "git config user.email \"ltf@ltf.org\""

	git config user.name "ltf git test"
	CommRetParse_LTFLIB "git config user.name \"ltf git test\""

	echo "hello world" > ${testdir2_git}/hello
	CommRetParse_FailDiy_LTFLIB ${ERROR} "echo \"hello world\" > ${testdir2_git}/hello"

	git add hello
	CommRetParse_LTFLIB "git add hello"

	git commit -m "LTF git test"
	CommRetParse_LTFLIB "git commit -m \"LTF git test\""
	
	git push origin master
	CommRetParse_LTFLIB "git push origin master"
}

## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1
	testcase_2

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
