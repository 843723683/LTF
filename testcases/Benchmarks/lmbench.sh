#!/bin/bash


## TODO:搭建运行环境
##
LmbenchSetup(){
        # 工具名称,需要和XML文件中CaseName一致
        local toolName="lmbench"
        # 运行结果保存文件名
        lmbenchRetName="${toolName}.ret"
        # 源结果目录名
        lmbenchRetPath="results"
        # 源结果路径.若存在于解压包中，可以用":"代替
        local toolOrigRetDir=":"
        # 源结果文件或目录名 
        local toolOrigRetName="${lmbenchRetPath}"

	# 加载benchmark工具函数
	source $(dirname $0)/lib/benchmark.sh

	# 注册函数
	RegisterFunc_BHK "LmbenchInit" "LmbenchInstall" "LmbenchRun"

        # 注册变量
        RegisterVar_BHK "${toolName}" "${toolOrigRetDir}" "${toolOrigRetName}"
}


## TODO: 个性化,安装前检查
## Out : 0=>TPASS
##	 1=>TFAIL
##       2=>TCONF
##
LmbenchInit(){
	local ret=0

	return $ret
}


## TODO：安装测试工具
## Out :0=>TPASS
##	1=>TFAIL
##      2=>TCONF
LmbenchInstall(){
	local ret=0
       
	# 判断配置文件是否存在
	local lmbenchconfigfile="$(dirname $0)/config/lmbench.config"
	local lmbenchrunfile="$(dirname $0)/config/config-run"
	if [ -f "${lmbenchconfigfile}" -a -f "${lmbenchrunfile}" ];then
		# 拷贝文件到scripts目录
        	cp ${lmbenchconfigfile} ${lmbenchrunfile} ./scripts
	else
		echo "No such lmbench configuration file: ${lmbenchconfigfile} or ${lmbenchrunfile}"
		return 2
	fi
 
        # 创建必须的目录和文件
        if [ ! -d "./SCCS/"  ];then
                mkdir ./SCCS
                if [ "$?" -ne "0"  ];then
                        return 2
                fi
        fi

        if [ ! -f "./SCCS/s.ChangeSet"  ];then
                touch ./SCCS/s.ChangeSet
                if [ "$?" -ne "0"  ];then
                        return 2
                fi
        fi

        # 编译
        make build
        [ $? -ne 0 ] && return 2

	return $ret
}

## TODO：运行测试
##
LmbenchRun(){
        #运行测试
        make results
        #统计结果
        make see | tee ${lmbenchRetPath}/${lmbenchRetName}
}


main(){
	# 加载必要文件
	LmbenchSetup
	
	# 调用主函数
	Main_BHK $@
}

main $@

exit $?
