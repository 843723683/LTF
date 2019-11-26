#!/bin/bash


## TODO:搭建运行环境
##
X11perfSetup(){
	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh

        # 工具名称,需要和XML文件中CaseName一致
        local toolName="x11perf"
        # 运行结果保存文件
        x11perfRetName="${toolName}.ret"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${x11perfRetName}"
	
	# 注册函数
	RegisterFunc_BHK "X11perfInit" "X11perfInstall" "X11perfRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
X11perfInit(){
	local ret=0
	
	# 判断是否在Init 5
	local runlvl="$(runlevel | awk '{print $2}')"
	if [ ${runlvl} -ne 5 ];then
		echo "Runlevel must be equal to 5. Current runlevel = ${runlvl}"
		ret=2
	fi

	# 判断是否存在x11perf
	which x11perf > /dev/null
	if [ $? -ne 0 ];then
		echo "Can't found x11perf !"
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
#  Out :0=>TPASS
#	1=>TFAIL
#       2=>TCONF
X11perfInstall(){
	local ret=0

	return $ret
}


## TODO：运行测试
X11perfRun(){
        # 判断能否关闭垂直同步
        export vblank_mode=0

        # 运行x11perf测试
	# 点
	echo "# start x11perf -dot" > ${x11perfRetName}
	x11perf -dot >> ${x11perfRetName}
	# 线
	echo "# start x11perf -seg100" >> ${x11perfRetName}
	x11perf -seg100 >> ${x11perfRetName}
	# 三角形
	echo "# start x11perf -triangle100" >> ${x11perfRetName}
	x11perf -triangle100 >> ${x11perfRetName}
	# 平行四边形
	echo "# start x11perf -rect100" >> ${x11perfRetName}
	x11perf -rect100 >> ${x11perfRetName}
	# 正方形
	echo "# start x11perf -bigosrect100" >> ${x11perfRetName}
	x11perf -bigosrect100 >> ${x11perfRetName}
	# 多边形
	echo "# start x11perf -complex100" >> ${x11perfRetName}
	x11perf -complex100 >> ${x11perfRetName}
}


main(){
	# 加载必要文件
	X11perfSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
