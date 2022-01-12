#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   cron 
# Version:    1.0
# Date:       2021/06/25
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/06/25
#             Version 2.0, 2021/12/29
# Function:   cron 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="cron 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="run-parts"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
	testFiles="/etc/cron.hourly/test.sh \
		/etc/cron.daily/test.sh \
		/etc/cron.weekly/test.sh"
	for i in ${testFiles}
	do
		cat > ${i}<<EOF
#!/bin/bash
echo 'test'
EOF
        	CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"
	done

	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	for i in ${testFiles}
	do
		Debug_LLE "rm -rf ${i}"
		rm -rf ${i}
	done
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	for i in ${testFiles}
	do
		chmod a+x $i >/dev/null	
		run-parts $(dirname $i) | grep -q "test"
		CommRetParse_LTFLIB "run-parts $(dirname $i) | grep -q \"test\"" "true" "no"
	done
}

## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
