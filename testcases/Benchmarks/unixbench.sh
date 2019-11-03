#!/bin/bash


## TODO:搭建运行环境
##
UnixbenchSetup(){
        # 工具名称,需要和XML文件中CaseName一致
        local toolName="unixbench"
        # 运行结果保存文件名
        unixbenchRetName="${toolName}.ret"
        # 运行结果保存目录名
        unixbenchRetPath="results"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${unixbenchRetPath}"
	
	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh

	# 注册函数
	RegisterFunc_BHK "UnixbenchInit" "UnixbenchInstall" "UnixbenchRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
UnixbenchInit(){
	local ret=0

        # 获取CPU个数
        tmpCpuNum=0
	GetCpuNum_BHK "tmpCpuNum"
        [ $? -ne 0 ] && { echo "无法获取有效的CPU个数";ret=2; }
        unset -v tmpCpuNum
	
	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
UnixbenchInstall(){
	local ret=0

	# 修改配置文件，用于满足大于16核测试       
        UnixbenchSetThread
        ret=$?
        [ "$ret" -ne "0" ] && return $ret

        # 编译
        make
        [ "$?" -ne "0" ] && return 1

	return $ret
}

## TODO：运行测试
##
UnixbenchRun(){
        # 获取CPU个数
        tmpCpuNum=0
	GetCpuNum_BHK "tmpCpuNum"
        [ $? -ne 0 ] && { echo "无法获取有效的CPU个数";return 2; }
	local cpuNum=${tmpCpuNum}
        unset -v tmpCpuNum
	echo "当前CPU的个数: ${cpuNum}"
	
        if [ ${cpuNum} -eq 1 ];then
                ./Run -c 1 | tee ./${unixbenchRetPath}/${unixbenchRetName}
        else
                ./Run -c 1 -c ${cpuNum} | tee ./${unixbenchRetPath}/${unixbenchRetName}
        fi
}


## TODO:设置Run文件最大运行的CPU
## Out :0=>TPASS
##      1=>TFAIL
##      2=>TCONF
UnixbenchSetThread(){
        # 获取CPU个数
        tmpCpuNum=0
	GetCpuNum_BHK "tmpCpuNum"
        [ $? -ne 0 ] && { echo "无法获取有效的CPU个数";return 2; }
	local cpuNum=${tmpCpuNum}
        unset -v tmpCpuNum
	echo "当前CPU的个数: ${cpuNum}"
	
        if [ $cpuNum -le 16 ];then
                return 0
        fi

        echo "Set Cpu num = ${cpuNum}"  
        # 设置unixbench支持多线程
        sed -i "s/\"System Benchmarks\", 'maxCopies' => 16/\"System Benchmarks\", 'maxCopies' => $cpuNum/" Run
        [ $? -ne 0 ] && { echo "FAIL:Set cpuNum to \"Run\" ";return 2; }

        return 0
}


main(){
	# 加载必要文件
	UnixbenchSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
