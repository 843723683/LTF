#!/bin/bash


## TODO:搭建运行环境
##
FioSetup(){
	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh

        # 工具名称,需要和XML文件中CaseName一致
        local toolName="fio"
        # 运行结果保存文件
        fioRetName="${toolName}.ret"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${fioRetName}"
	
	# 注册函数
	RegisterFunc_BHK "FioInit" "FioInstall" "FioRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
FioInit(){
	local ret=0

	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
FioInstall(){
	local ret=0
       
	# 配置
        ./configure
        [ "$?" -ne "0" ] && return 1
        # 编译
        make
        [ "$?" -ne "0" ] && return 1
        # 安装
        make install
        [ "$?" -ne "0" ] && return 1

	return $ret
}

## TODO：运行测试
##
FioRun(){
        # 运行fio测试
        echo "Run fio test!!!"
	
	# 测试
        echo "No test~" | tee ${fioRetName}
}


main(){
	# 加载必要文件
	FioSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
