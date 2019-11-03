#!/bin/bash


## TODO:搭建运行环境
##
StressapptestSetup(){
	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh

        # 工具名称,需要和XML文件中CaseName一致
        local toolName="stressapptest"
        # 运行结果保存文件
        stressapptestRetName="${toolName}.ret"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${stressapptestRetName}"
	
	# 注册函数
	RegisterFunc_BHK "StressapptestInit" "StressapptestInstall" "StressapptestRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
StressapptestInit(){
	local ret=0

        # 获取总内存大小
        tmpMemSize=0
        GetFreeMemSizeMB_BHK "tmpMemSize"
        [ $? -ne 0 ] && { echo "无法获取有效的空闲内存";ret=2; }
        unset -v tmpMemSize

	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
StressapptestInstall(){
	local ret=0
       
        # 配置,判断体系架构
        if [[ "X${AUTOTEST_ARCH}" =~ "Xaarch64" ]];then
                echo "TCONF：Arm is not supported! Try x86_64, i686, powerpc, or armv7a"
                return 2
        else
                ./configure
                [ $? -ne 0 ] && return 1
        fi

        # 编译
        make
        [ $? -ne 0 ] && return 1
        # 安装
        make install
        [ $? -ne 0 ] && return 1

	return $ret
}

## TODO：运行测试
##
StressapptestRun(){
        # 获取总内存大小
        tmpMemSize=0
        GetFreeMemSizeMB_BHK "tmpMemSize"
        [ $? -ne 0 ] && { echo "无法获取有效的空闲内存";return 2; }
        local memSize=${tmpMemSize}
        unset -v tmpMemSize
        echo "当前剩余内存大小: ${memSize}MB"
	
	echo "Cmd: stressapptest -M ${memSize} -s 1200"
        # 测试
        stressapptest -M ${memSize} -s 1200 | tee ${stressapptestRetName}
}


main(){
	# 加载必要文件
	StressapptestSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
