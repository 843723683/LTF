#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   libevent.sh
# Version:    1.0
# Date:       2019/11/11
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/11/11
# Function:   libevent.sh - 测试支持libevent开发和运行环境
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 搭建运行环境
#
Setup_EVT(){
	# 工具名称,需要和XML文件中CaseName一致
        local toolName="libevent"

	# 加载运行环境工具函数
        if [ -f "$(dirname $0)/lib/developmentEnv.sh"  ];then
        	source $(dirname $0)/lib/developmentEnv.sh
        else
                echo "TCONF : Can't found library file ($(dirname $0)/lib/developmentEnv.sh)"
                exit 2
        fi

	# 注册函数
        RegisterFunc_BHK "Init_EVT" "Install_EVT" "Run_EVT" "Assert_EVT" "Clean_EVT"
	RetParse_BHK

	# 注册变量
	RegisterVar_BHK "${toolName}"	
	RetParse_BHK
}


## TODO: 个性化安装前检查,自定义检查CPU或者内存等
#  Out : 0=>TPASS
#        1=>TFAIL
#        2=>TCONF
# 
Init_EVT(){
        local ret=0

	# 二进制名
	exeFile_evt="libevent.elf"
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi
	# 结果文件名
	retFile_evt="libevent.ret"
	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

        return $ret
}


## TODO :进行编译安装等操作
#
Install_EVT(){
	local ret=0
	# 编译
	gcc libevent.c -o ${exeFile_evt} -levent
	ret=$?

	return ${ret}
}


## TODO：运行测试
#
Run_EVT(){
	local ret=0

        ./${exeFile_evt} > ${retFile_evt}
	ret=$?

	return ${ret}
}


## TODO : 断言分析
# 
Assert_EVT(){
	local strnum=0
	strnum=$(cat ${retFile_evt} | grep "hello world" | wc -l)
	# 判断结果是否正确
	if [ ${strnum} -ne 5 ];then
		echo "Libevent Assert Failed !"
		return 1
	fi

	return ${ret}
}


## TODO : 清除生成的文件
#
Clean_EVT(){
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi

	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi
	
	unset -v exeFile_evt retFile_evt
}

Main_EVT(){
        # 加载benchmark.sh文件
        Setup_EVT

        # 调用主函数
        Main_BHK $@
}

Main_EVT $@

exit $?

