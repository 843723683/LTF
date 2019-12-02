#!/bin/bash


## TODO:搭建运行环境
##
IozoneSetup(){
        # 工具名称,需要和XML文件中CaseName一致
        local toolName="iozone"

        # 运行结果保存文件
        iozoneRetName="${toolName}.xls"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${iozoneRetName}"

	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh
	
	# 注册函数
	RegisterFunc_BHK "IozoneInit" "IozoneInstall" "IozoneRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
IozoneInit(){
	local ret=0
	# 最大测试内存大小，单位GB
	local maxmem="4"
	# 测试文件路径(绝对路径)
	local dirname="/tmp"

	# 判断测试目录是否存在
        if [ ! -d "$dirname" ];then
                echo "[ TCONF ] : No such directory. ($2)"
                return 2
        fi

	# 获取总内存大小
        tmpMemSize=0
	GetTotalMemSizeGB_BHK "tmpMemSize"
        [ $? -ne 0 ] && { echo "[ TCONF ] : 无法获取有效的空闲内存";return 2; }	
	local memsize=${tmpMemSize}
	unset -v tmpMemSize

	# 判断内存是否大于 maxmem
	if [ ${memsize} -gt "${maxmem}" ];then
		echo "[ TCONF ] : Memory is greater than ${maxmem}G ！"
		ret=2
	fi

	# 获取指定目录可用空间大小
	local testdir="/tmp"
	tmpAvailMem=0
	GetDirAvailMemKB_BHK "tmpAvailMem" "${testdir}"
        [ $? -ne 0 ] && { echo "[ TCONF ] :无法获取 ${testdir} 可用空间";return 2; }	
	local availmem=${tmpAvailMem}
	unset -v tmpAvailMem

	# 判断目录可用空间是否充足,是否大于内存两倍
	let local memszKB=memsize*1024*1024*2
	if [ "${availmem}" -lt "${memszKB}"  ];then
		echo "[ TCONF ]:Free directory (${availmem}KB) space is less than twice the memory (${memszKB}KB)"
		ret=2
	fi
	
	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
IozoneInstall(){
	local ret=0
       
        # 编译,判断体系架构
        if [[ "X${AUTOTEST_ARCH}" =~ "aarch64" ]];then
		# arm64
		make linux-arm
                [ $? -ne 0 ] && return 1
        elif [[ "X${AUTOTEST_ARCH}" =~ "x86" ]];then
		# x86
		make linux-AMD64
                [ $? -ne 0 ] && return 1
	else
		# not supported
                echo "TCONF：Architecture is not supported! Current \"${AUTOTEST_ARCH}\" "
                return 2
        fi

	return $ret
}

## TODO：运行测试
##
IozoneRun(){
	# 测试文件路径(绝对路径)
	local dirname="/tmp"

	# 获取总内存大小
        tmpMemSize=0
	GetTotalMemSizeGB_BHK "tmpMemSize"
        [ $? -ne 0 ] && { echo "无法获取有效的空闲内存";return 2; }	
	local memSize=${tmpMemSize}
	unset -v tmpMemSize
        echo "当前总内存大小: ${memSize}GB"
	
	# 指定测试内存大小	
	local testmemSize=0
	let testmemSize=${memSize}*2
	echo "./iozone -a -y 4k -n 1G -i 0 -i 1 -g ${testmemSize}G -f ${dirname}/iozone -Rb ./${iozoneRetName}"
	./iozone -a -y 4k -n 1G -i 0 -i 1 -g ${testmemSize}G -f ${dirname}/iozone -Rb ./${iozoneRetName}
}


main(){
	# 加载必要文件
	IozoneSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
