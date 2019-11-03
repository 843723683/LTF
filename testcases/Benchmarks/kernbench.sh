#!/bin/bas

## TODO: 搭建运行环境
##
KernbenchSetup(){
	# 工具名称,需要和XML文件中CaseName一致
	local toolName="kernbench"
	# 运行结果保存文件名
	kernbenchRetName="${toolName}.ret"
	# 源结果路径.若存在于解压包中，可以用":"代替
	local toolOrigRetDir=":"
	# 源结果文件或目录名 
	local toolOrigRetName="${kernbenchRetName}"
	
	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh
	
	# 注册函数
	RegisterFunc_BHK "KernbenchInit" "KernbenchInstall" "KernbenchRun"
	
	# 注册变量
	RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
KernbenchInit(){
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
KernbenchInstall(){
	local ret=0
       
        # 获取CPU个数
        tmpCpuNum=0
        GetCpuNum_BHK "tmpCpuNum"
        [ $? -ne 0 ] && { echo "无法获取有效的CPU个数";return 2; }
        local cpuNum=${tmpCpuNum}
        unset -v tmpCpuNum
        echo "当前CPU的个数: ${cpuNum}" 

	# 配置
	./configure
	[ $? -ne 0 ] &&  return 1

	#编译
	if [ "$cpuNum" -gt "1" ];then
		make 
	else
		make -j ${cpuNum}
	fi
	[ $? -ne 0 ] &&  return 1

	#安装
	make install
	[ $? -ne 0 ] &&  return 1
	
	#判断是否存在kernbench
	if [  -f "/opt/ltp/testcases/bin/kernbench" ];then
		# 存在则拷贝到源码包目录
		cp /opt/ltp/testcases/bin/kernbench ./
		
		# 修改头文件位置
		cat kernbench | grep "if \[\[ \! \-f include/linux/kernel.h \]\]"
	        if [ "$?" -eq "0" ];then
        	        sed -i 's/if \[\[ \! \-f include/if \[\[ \! \-f \/usr\/include/' kernbench
	        fi
	else
		echo "Can't find /opt/ltp/testcases/bin/kernbench "
		return 1
	fi

	return $ret
}

## TODO：运行测试
##
KernbenchRun(){
	./kernbench | tee ${kernbenchRetName} 
}


main(){
	# 加载benchmark.sh文件
	KernbenchSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
