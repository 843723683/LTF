#!/bin/bash


## TODO:搭建运行环境
##
BonnieSetup(){
        # 工具名称,需要和XML文件中CaseName一致
        local toolName="bonnie"

        # 运行结果保存目录名
        bonnieRetPath="${toolName}-ret"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${bonnieRetPath}"

	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh
	
	# 注册函数
	RegisterFunc_BHK "BonnieInit" "BonnieInstall" "BonnieRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
BonnieInit(){
	local ret=0
        # 最大测试内存大小，单位GB
        local maxmem="4"
	
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

	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
BonnieInstall(){
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
BonnieRun(){
        # 创建结果保存目录
        [ ! -d ${bonnieRetPath} ] && mkdir ${bonnieRetPath}

	# 获取总内存大小
        tmpMemSize=0
	GetTotalMemSizeGB_BHK "tmpMemSize"
        [ $? -ne 0 ] && { echo "无法获取有效的空闲内存";return 2; }	
	local memSize=${tmpMemSize}
	unset -v tmpMemSize
        echo "当前总内存大小: ${memSize}GB"
	
	# 设置测试内存大小
        local testmemMB=0
        let testmemMB=${memSize}*1024*2

	# 测试
	echo "./boonnie++ -d / -s ${testmemMB} -u root:root "
	./bonnie++ -d / -s ${testmemMB} -u root:root | tee ${bonnieRetPath}/bonnie.ret
	
	# 格式化结果为html
	cat ${bonnieRetPath}/bonnie.ret | sed -n '$p' | bon_csv2html > ${bonnieRetPath}/bonnie.html
}


main(){
	# 加载必要文件
	BonnieSetup

	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
