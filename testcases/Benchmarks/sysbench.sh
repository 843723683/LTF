#!/bin/bash


## TODO:搭建运行环境
##
SysbenchSetup(){
        # 工具名称,需要和XML文件中CaseName一致
        local toolName="sysbench"
        # 运行结果保存目录名
        sysbenchRetPath="${toolName}-ret"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${sysbenchRetPath}"

	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh
	
	# 注册函数
	RegisterFunc_BHK "SysbenchInit" "SysbenchInstall" "SysbenchRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
SysbenchInit(){
	local ret=0

        # 获取CPU个数
        tmpCpuNum=0
	GetCpuNum_BHK "tmpCpuNum"
        [ $? -ne 0 ] && { echo "无法获取有效的CPU个数";ret=2; }
        unset -v tmpCpuNum
	
	# 获取总内存大小
        tmpMemSize=0
	GetTotalMemSizeGB_BHK "tmpMemSize"
        [ $? -ne 0 ] && { echo "无法获取有效的空闲内存";ret=2; }	
	unset -v tmpMemSize

	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
SysbenchInstall(){
	local ret=0
       
        ./autogen.sh
        [ "$?" -ne "0" ] && return 1
        # 配置
        ./configure --without-mysql
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
SysbenchRun(){
	# 创建结果保存目录
        [ ! -d ${sysbenchRetPath} ] && mkdir ${sysbenchRetPath}
        
        # 获取CPU个数
        tmpCpuNum=0
	GetCpuNum_BHK "tmpCpuNum"
        [ $? -ne 0 ] && { echo "无法获取有效的CPU个数";return 2; }
	local cpuNum=${tmpCpuNum}
        unset -v tmpCpuNum
	echo "当前CPU的个数: ${cpuNum}"
	
	# 获取总内存大小
        tmpMemSize=0
	GetTotalMemSizeGB_BHK "tmpMemSize"
        [ $? -ne 0 ] && { echo "无法获取有效的空闲内存";return 2; }	
	local memSize=${tmpMemSize}
	unset -v tmpMemSize
        echo "当前总内存大小: ${memSize}GB"
	
        # 内存：单线程-随机
        sysbench --threads=1 --memory-block-size=8k --memory-total-size=${memSize}G --memory-access-mode=rnd memory run | tee ${sysbenchRetPath}/sysbench-rnd-1cpu.ret
        # 内存：单线程-连续
        sysbench --threads=1 --memory-block-size=8k --memory-total-size=${memSize}G --memory-access-mode=seq memory run | tee ${sysbenchRetPath}/sysbench-seq-1cpu.ret

	# cpu数量大于1
	if [ ${cpuNum} -gt 1 ];then
		# 内存：多线程-随机
	        sysbench --threads=${cpuNum} --memory-block-size=8k --memory-total-size=${memSize}G --memory-access-mode=rnd memory run | tee ${sysbenchRetPath}/sysbench-rnd-${cpuNum}cpu.ret
        	# 内存：多线程-连续
	        sysbench --threads=${cpuNum} --memory-block-size=8k --memory-total-size=${memSize}G --memory-access-mode=seq memory run | tee ${sysbenchRetPath}/sysbench-seq-${cpuNum}cpu.ret
	fi	
}


main(){
	# 加载必要文件
	SysbenchSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
