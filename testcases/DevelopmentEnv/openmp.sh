#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename : openmp.sh 
# Version  : 1.0
# Date     : 2019/11/12
# Author   : Lz
# Email    : lz843723683@163.com
# History  :     
#            Version 1.0, 2019/11/12
# Function : openmp.sh  - 测试支持 openmp 开发和运行环境
# Out      :        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 搭建运行环境
#
Setup_OPENMP(){
	# 工具名称,需要和XML文件中CaseName一致
        local toolName="openmp"

	# 加载运行环境工具函数
        if [ -f "$(dirname $0)/lib/developmentEnv.sh"  ];then
        	source $(dirname $0)/lib/developmentEnv.sh
        else
                echo "TCONF : Can't found library file ($(dirname $0)/lib/developmentEnv.sh)"
                exit 2
        fi

	# 注册函数
        RegisterFunc_DME "Init_OPENMP" "Install_OPENMP" "Run_OPENMP" "Assert_OPENMP" "Clean_OPENMP"
	RetParse_DME

	# 注册变量
	RegisterVar_DME "${toolName}"	
	RetParse_DME
}


## TODO: 个性化安装前检查,自定义检查CPU或者内存等
#  Out : 0=>TPASS
#        1=>TFAIL
#        2=>TCONF
# 
Init_OPENMP(){
        local ret=0
	
	# 二进制名
	exeFile_evt="openmp.elf"
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi
	# 结果文件名
	retFile_evt="openmp.ret"
	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

        return $ret
}


## TODO :进行编译安装等操作
#
Install_OPENMP(){
	local ret=0

	# 编译
	gcc -O -fopenmp stream.c -o ${exeFile_evt}
	ret=$?

	return ${ret}
}


## TODO：运行测试
#
Run_OPENMP(){
	local ret=0

        ./${exeFile_evt} > ${retFile_evt}
	ret=$?

	return ${ret}
}


## TODO : 断言分析
# 
Assert_OPENMP(){
	local ret=0

	# 判断结果是否正确
	cat ${retFile_evt} | grep -q "STREAM version"
	if [ $? -ne 0 ];then
		echo "OPENMP Assert Failed !"
		return 1
	fi

	# 判断结果是否正确
	cat ${retFile_evt} | grep -q "Copy"
	if [ $? -ne 0 ];then
		echo "OPENMP Assert Failed !"
		return 1
	fi

	return ${ret}
}


## TODO : 清除生成的文件
#
Clean_OPENMP(){
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi

	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

	unset -v exeFile_evt retFile_evt 
}

Main_OPENMP(){
        Setup_OPENMP

        # 调用主函数
        Main_DME $@
}

Main_OPENMP $@

exit $?

