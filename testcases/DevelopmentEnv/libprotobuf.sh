#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename:   libprotobuf.sh
# Version:    1.0
# Date:       2019/11/11
# Author:     Lz
# Email:      lz843723683@163.com
# History：     
#             Version 1.0, 2019/11/11
# Function:   libprotobuf.sh  - 测试支持libprotobuf开发和运行环境
# Out:        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 搭建运行环境
#
Setup_PTB(){
	# 工具名称,需要和XML文件中CaseName一致
        local toolName="libprotobuf"

	# 加载运行环境工具函数
        if [ -f "$(dirname $0)/lib/developmentEnv.sh"  ];then
        	source $(dirname $0)/lib/developmentEnv.sh
        else
                echo "TCONF : Can't found library file ($(dirname $0)/lib/developmentEnv.sh)"
                exit 2
        fi

	# 注册函数
        RegisterFunc_DME "Init_PTB" "Install_PTB" "Run_PTB" "Assert_PTB" "Clean_PTB"
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
Init_PTB(){
        local ret=0
	
	# 临时头文件
	headFile_evt="libprotobuf.pb.h"
	if [ -f "${headFile_evt}"  ];then
		rm ${headFile_evt}
	fi
	# 临时源文件
	srcFile_evt="libprotobuf.pb.cc"
	if [ -f "${srcFile_evt}"  ];then
		rm ${srcFile_evt}
	fi
	# 二进制名
	exeFile_evt="libprotobuf.elf"
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi
	# 结果文件名
	retFile_evt="libprotobuf.ret"
	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

	# 判断命令是否存在
	which protoc &>/dev/null
	ret=$?
	[ ${ret} -ne 0 ] && { echo "protoc :Command not found ";return ${ret}; }
	
        return $ret
}


## TODO :进行编译安装等操作
#
Install_PTB(){
	local ret=0

	# 生成c++源码
	protoc --cpp_out=./ libprotobuf.proto
	ret=$?
	[ $ret -ne 0 ] && return ${ret}

	# 编译
	g++ ${headFile_evt} ${srcFile_evt} libprotobuf.cc -o ${exeFile_evt} -lprotobuf
	ret=$?

	return ${ret}
}


## TODO：运行测试
#
Run_PTB(){
	local ret=0

        ./${exeFile_evt} > ${retFile_evt}
	ret=$?

	return ${ret}
}


## TODO : 断言分析
# 
Assert_PTB(){
	local ret=0

	# 判断结果是否正确
	cat ${retFile_evt} | grep -q "hello world"
	if [ $? -ne 0 ];then
		echo "Libprotobuf Assert Failed !"
		return 1
	fi
	cat ${retFile_evt} | grep -q "lz"
	if [ $? -ne 0 ];then
		echo "Libprotobuf Assert Failed !"
		return 1
	fi

	return ${ret}
}


## TODO : 清除生成的文件
#
Clean_PTB(){
	if [ -f "${headFile_evt}"  ];then
		rm ${headFile_evt}
	fi

	if [ -f "${srcFile_evt}"  ];then
		rm ${srcFile_evt}
	fi

	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi

	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi
	
	unset -v headFile_evt srcFile_evt exeFile_evt retFile_evt
}

Main_PTB(){
        Setup_PTB

        # 调用主函数
        Main_DME $@
}

Main_PTB $@

exit $?

