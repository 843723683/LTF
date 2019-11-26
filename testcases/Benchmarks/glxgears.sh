#!/bin/bash


## TODO:搭建运行环境
##
GlxgearsSetup(){
	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh

        # 工具名称,需要和XML文件中CaseName一致
        local toolName="glxgears"
        # 运行结果保存文件
        glxRetName="${toolName}.ret"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${glxRetName}"
	
	# 注册函数
	RegisterFunc_BHK "GlxgearsInit" "GlxgearsInstall" "GlxgearsRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
GlxgearsInit(){
	local ret=0
	
	# 判断是否在Init 5
	local runlvl="$(runlevel | awk '{print $2}')"
	if [ ${runlvl} -ne 5 ];then
		echo "Runlevel must be equal to 5. Current runlevel = ${runlvl}"
		ret=2
	fi

	# 判断是否存在glxgears
	which glxgears > /dev/null
	if [ $? -ne 0 ];then
		echo "Can't found glxgears !"
		ret=2
	fi

	# 判断能否关闭垂直同步
	export vblank_mode=0
	if [ $? -ne 0 ];then
		echo "Fail : export vblank_mode=0 !"
		ret=2
	fi

	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
GlxgearsInstall(){
	local ret=0

	return $ret
}

## TODO：运行测试
##
GlxgearsRun(){
	# 关闭垂直同步
	export vblank_mode=0

        # 运行glxgears测试
	glxgears > ${glxRetName} &
	
	# 获取pid
	local glxpid="$!"

	# 运行5分钟
	sleep 300s
	
	# kill -9 
	kill -9 ${glxpid}
	
	# 等待子进程退出
	wait
}


main(){
	# 加载必要文件
	GlxgearsSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
