#!/bin/bash


## TODO:搭建运行环境
##
StreamSetup(){
	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh

        # 工具名称,需要和XML文件中CaseName一致
        local toolName="stream"
        # 运行结果保存文件
        streamRetName_one="${toolName}-1.ret"
        streamRetName_N="${toolName}-N.ret"
        # 源结果目录名
        streamRetPath="${toolName}-ret"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${streamRetPath}"
	
	# 注册函数
	RegisterFunc_BHK "StreamInit" "StreamInstall" "StreamRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
StreamInit(){
	local ret=0

	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
StreamInstall(){
	local ret=0

        gcc -O stream.c -o stream-1.elf
        [ $? -ne 0 ] && return 1
        gcc -O -fopenmp stream.c -o stream-N.elf
        [ $? -ne 0 ] && return 1

	return $ret
}

## TODO：运行测试
##
StreamRun(){
        # 创建结果保存目录
        [ ! -d ${streamRetPath} ] && mkdir ${streamRetPath}

        local index=0
        for index in `seq 1 5`
        do
                ./stream-1.elf | tee -a ${streamRetPath}/${streamRetName_one}
        done
        for index in `seq 1 5`
        do
                ./stream-N.elf | tee -a ${streamRetPath}/${streamRetName_N}
        done
}


main(){
	# 加载必要文件
	StreamSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
