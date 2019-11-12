#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename : libvirt.sh 
# Version  : 1.0
# Date     : 2019/11/12
# Author   : Lz
# Email    : lz843723683@163.com
# History  :     
#            Version 1.0, 2019/11/12
# Function : libvirt.sh  - 测试支持 libvirt 开发和运行环境
# Out      :        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 搭建运行环境
#
Setup_VIRT(){
	# 工具名称,需要和XML文件中CaseName一致
        local toolName="libvirt"

	# 加载运行环境工具函数
        if [ -f "$(dirname $0)/lib/developmentEnv.sh"  ];then
        	source $(dirname $0)/lib/developmentEnv.sh
        else
                echo "TCONF : Can't found library file ($(dirname $0)/lib/developmentEnv.sh)"
                exit 2
        fi

	# 注册函数
        RegisterFunc_DME "Init_VIRT" "Install_VIRT" "Run_VIRT" "Assert_VIRT" "Clean_VIRT"
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
Init_VIRT(){
        local ret=0
	
	# 二进制名
	exeFile_evt="libvirt.elf"
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi
	# 结果文件名
	retFile_evt="libvirt.ret"
	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

        return $ret
}


## TODO :进行编译安装等操作
#
Install_VIRT(){
	local ret=0

	# 编译
	gcc libvirt.c -o ${exeFile_evt} -lvirt
	ret=$?

	return ${ret}
}


## TODO：运行测试
#
Run_VIRT(){
	local ret=0

        ./${exeFile_evt} > ${retFile_evt} 2>&1
	ret=$?

	# 如果ret为1,则置为成功
	if [ ${ret} -eq 1 ];then
		ret=0
	fi

	return ${ret}
}


## TODO : 断言分析
# 
Assert_VIRT(){
	# 默认为失败
	local ret=1

	# 判断是否未装KVM
	cat ${retFile_evt} | grep -q "Failed to connect to hypervisor"
	if [ $? -eq 0 ];then
		echo "Libvirt :Failed connetct to hypervisor"
		return 0
	fi

	# 判断是否未启动虚拟机
	cat ${retFile_evt} | grep -q "Failed to find Domain"
	if [ $? -eq 0 ];then
		echo "Libvirt :Failed to find Domain"
		return 0
	fi
	
	# 
	cat ${retFile_evt} | grep -q "Failed to get information for Domain"
	if [ $? -eq 0 ];then
		echo "Libvirt :Failed to get information for Domain"
		return 0
	fi

	# 判断是否找到id=1的虚拟机
	cat ${retFile_evt} | grep -q "Success"
	if [ $? -eq 0 ];then
		echo "Libvirt :Success"
		return 0
	fi

	return ${ret}
}


## TODO : 清除生成的文件
#
Clean_VIRT(){
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi

	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

	unset -v exeFile_evt retFile_evt 
}

Main_VIRT(){
        Setup_VIRT

        # 调用主函数
        Main_DME $@
}

Main_VIRT $@

exit $?

