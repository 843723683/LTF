#!/bin/bash


## TODO:搭建运行环境
##
MemtesterSetup(){
        # 工具名称,需要和XML文件中CaseName一致
        local toolName="memtester"
        # 运行结果保存目录名
        memtesterRetPath="${toolName}-ret"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${memtesterRetPath}"

	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh
	
	# 注册函数
	RegisterFunc_BHK "MemtesterInit" "MemtesterInstall" "MemtesterRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
MemtesterInit(){
	local ret=0

        # 获取CPU个数
        tmpCpuNum=0
	GetCpuNum_BHK "tmpCpuNum"
        [ $? -ne 0 ] && { echo "无法获取有效的CPU个数";ret=2; }
        unset -v tmpCpuNum
	
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
MemtesterInstall(){
	local ret=0
       
	#  编译
	make
        [ $? -ne 0 ]&& return 1

	# 安装
        make install
        [ $? -ne 0 ]&& return 1

	return $ret
}

## TODO：运行测试
##
MemtesterRun(){
	# 创建结果保存目录
        [ ! -d ${memtesterRetPath} ] && mkdir ${memtesterRetPath}
        
        # 获取CPU个数
        tmpCpuNum=0
	GetCpuNum_BHK "tmpCpuNum"
        [ $? -ne 0 ] && { echo "无法获取有效的CPU个数";return 2; }
	local cpuNum=${tmpCpuNum}
        unset -v tmpCpuNum
	echo "当前CPU的个数: ${cpuNum}"
	
	# 获取总内存大小
        tmpMemSize=0
	GetFreeMemSizeMB_BHK "tmpMemSize"
        [ $? -ne 0 ] && { echo "无法获取有效的空闲内存";return 2; }	
	local memSize=${tmpMemSize}
	unset -v tmpMemSize
        echo "当前剩余内存大小: ${memSize}MB"

	# 计算每个线程需要测试内存
        avg_mem_size=$((${memSize}/${cpuNum}))
	echo "每个线程测试内存大小: ${avg_mem_size}MB"

        # 进行测试
        if [ ${cpuNum} -gt 1 ];then
                local i=0
                local border=$((${cpuNum}-2))
                for i in `seq 0 ${border}`
                do
                        #过滤掉所有的控制字符之后输出
                        echo "memtester thread $i"
                        memtester ${avg_mem_size}M 1 | col -b > ${memtesterRetPath}/memtester-${i}.ret &
                done
        fi
        memtester ${avg_mem_size}M 1 | col -b > ${memtesterRetPath}/memtester-end.ret

        # 判断所有的memtester进程是否退出
        local count=`ps -ef |grep "memtester" |grep -v "grep" |grep -v ".sh" |wc -l`
        while [ "$count" -ne "0" ]
        do
                echo "Wait memtester stop. count = $count "
                echo `ps -ef |grep "memtester" |grep -v "grep" |grep -v ".sh"`
                sleep 60
                count=`ps -ef |grep "memtester" |grep -v "grep" |grep -v ".sh" |wc -l`
        done
}


main(){
	# 加载必要文件
	MemtesterSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
