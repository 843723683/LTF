#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   tar 
# Version:    1.0
# Date:       2021/01/12
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2021/01/12
# Function:   tar 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="tar 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="tar"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-tar"
	cat > ${testFile} <<EOF
test tar
EOF
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"

	testTar="${TmpTestDir_LTFLIB}/test-tar.tar"
	
	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testFile} ${testTar}"
	rm -rf ${testFile} ${testTar}
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	tar -cf ${testTar} ${testFile} 
	CommRetParse_LTFLIB "tar -cf ${testTar} ${testFile}"

	rm ${testFile} -rf
	
	tar -xf ${testTar} -C / &&  grep -q 'test tar' ${testFile}
	CommRetParse_LTFLIB "tar -xf ${testTar} -C /"
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
