#!env bash

# ----------------------------------------------------------------------
# Filename:   hashsums 
# Version:    1.0
# Date:       2022/01/14
# Author:     Lz
# Email:      lz843723683@gmail.com
# History：     
#             Version 1.0, 2022/01/14
# Function:   hashsums 功能验证
# Out:        
#             0 => TPASS
#             1 => TFAIL
#             2 => TCONF
# ----------------------------------------------------------------------

# 测试主题
Title_Env_LTFLIB="hashsums 功能测试"

# 本次测试涉及的命令
CmdsExist_Env_LTFLIB="sha1sum sha224sum sha256sum sha384sum sha512sum md5sum"


## TODO : 个性化,初始化
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestInit_LTFLIB(){
        # 创建临时文件和目录
        testFile="${TmpTestDir_LTFLIB}/test-hashsums"
	echo "abcdefghijklmnopqrstuvwxyz1234567890" > ${testFile}
        CommRetParse_FailDiy_LTFLIB ${ERROR} "创建文件失败${testFile}"

	return ${TPASS}
}


## TODO : 清理函数
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
TestClean_LTFLIB(){
	Debug_LLE "rm -rf ${testFile}"
	rm -rf ${testFile}
	return ${TPASS}
}


## TODO : 测试用例
testcase_1(){
	sha1sum ${testFile} | grep -q f2cc9f1b642d1962f244ba7b0ab206649d5f153c
	CommRetParse_LTFLIB "sha1sum ${testFile} | grep -q f2cc9f1b642d1962f244ba7b0ab206649d5f153c"
}


## TODO : 测试用例
testcase_2(){
	sha224sum ${testFile} | grep -q 00f95b5eb233164f4690f1963447fd42d2055ff6e660ee9b9a1943f4
	CommRetParse_LTFLIB "sha224sum ${testFile} | grep -q 00f95b5eb233164f4690f1963447fd42d2055ff6e660ee9b9a1943f4"
}

testcase_3(){
	sha256sum ${testFile} | grep -q e125e4eabe1eaac7988796098acb9e1eb8e81628ebf9937a4ec502411e461107
	CommRetParse_LTFLIB "sha256sum ${testFile} | grep -q e125e4eabe1eaac7988796098acb9e1eb8e81628ebf9937a4ec502411e461107"
}


testcase_4(){
	sha384sum ${testFile} | grep -q 8bfefc0ba5512fc53c55a99f2e5d686e3c63c33fb4553edb1ea8844543492d6db5845470e5d6366a09596fd5cbeffce9
	CommRetParse_LTFLIB "sha384sum ${testFile} | grep -q 8bfefc0ba5512fc53c55a99f2e5d686e3c63c33fb4553edb1ea8844543492d6db5845470e5d6366a09596fd5cbeffce9"
}


testcase_5(){
	sha512sum ${testFile} | grep -q 7ff71e3ce6dcabd62738506f37cba533fb42393981cb526c423ea24528a72d6561bc120eefbb679d831f49abc75de9c35829ea4ec2ea59f74903d15107f90b50
	CommRetParse_LTFLIB "sha512sum ${testFile} | grep -q 7ff71e3ce6dcabd62738506f37cba533fb42393981cb526c423ea24528a72d6561bc120eefbb679d831f49abc75de9c35829ea4ec2ea59f74903d15107f90b50"
}


testcase_6(){
	md5sum ${testFile} | grep -q 6c6506b6cb9e6d9a85ec9f8621d85864
	CommRetParse_LTFLIB "md5sum ${testFile} | grep -q 6c6506b6cb9e6d9a85ec9f8621d85864"
}


## TODO : 测试用例集
#   Out : 0=>TPASS
#         1=>TFAIL
#         2=>TCONF
Testsuite_LTFLIB(){
	testcase_1
	testcase_2
	testcase_3
	testcase_4
	testcase_5
	testcase_6

	return $TPASS
}


#----------------------------------------------#

source "${LIB_LTFLIB}"
Main_LTFLIB $@
