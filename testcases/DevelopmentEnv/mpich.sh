#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename : mpich.sh 
# Version  : 1.0
# Date     : 2019/11/12
# Author   : Lz
# Email    : lz843723683@163.com
# History  :     
#            Version 1.0, 2019/11/12
# Function : mpich.sh  - 测试支持 mpich 开发和运行环境
# Out      :        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 搭建运行环境
#
Setup_MPICH(){
	# 工具名称,需要和XML文件中CaseName一致
        local toolName="mpich"

	# 加载运行环境工具函数
        if [ -f "$(dirname $0)/lib/developmentEnv.sh"  ];then
        	source $(dirname $0)/lib/developmentEnv.sh
        else
                echo "TCONF : Can't found library file ($(dirname $0)/lib/developmentEnv.sh)"
                exit 2
        fi

	# 注册函数
        RegisterFunc_DME "Init_MPICH" "Install_MPICH" "Run_MPICH" "Assert_MPICH" "Clean_MPICH"
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
Init_MPICH(){
        local ret=0
	# 默认使用第一组进行测试
	indexCmd=0
	
	# 二进制名
	exeFile_evt="mpich.elf"
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi
	# 结果文件名
	retFile_evt="mpich.ret"
	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

	# 编译命令路径列表(由于U系和R系区别)
	cmdMpiccList=()
	which mpicc &>/dev/null
	if [ $? -eq 0 ];then
		# 查找标准路径中命令地址
		cmdMpiccList=($(which mpicc))
	else
		# 查找/usr/lib64/mpich*路径是否存在命令地址
		cmdMpiccList=($(find /usr/lib64/mpich* -name mpicc))
		if [ ${#cmdMpiccList} -lt 1 ];then
			# /usr/lib64/mpich*中未找到命令
			echo "mpicc : No Command found"
			return 1
		fi
	fi

	# 运行命令路径列表
	cmdMpirunList=()
	which mpirun &>/dev/null
	if [ $? -eq 0 ];then
		# 查找标准路径中命令地址
		cmdMpirunList=($(which mpirun))
	else
		# 查找/usr/lib64/mpich*路径是否存在命令地址
		cmdMpirunList=($(find /usr/lib64/mpich* -name mpirun))
		if [ ${#cmdMpirunList} -lt 1 ];then
			# /usr/lib64/mpich*中未找到命令
			echo "mpirun : No Command found"
			return 1
		fi
	fi

	# 判断编译命令和运行命令是否一一对应
	if [ ${#cmdMpirunList[@]} -ne ${#cmdMpiccList[@]}  ];then
		echo "mpirun 和 mpicc 命令数量不对应"
		echo "mpicc :${#cmdMpiccList[@]} ${cmdMpiccList[@]}"	
		echo "mpirun:${#cmdMpirunList[@]} ${cmdMpirunList[@]}"	
		
		return 1
	fi

        return $ret
}


## TODO :进行编译安装等操作
#
Install_MPICH(){
	local ret=0

	# 编译
	eval ${cmdMpiccList[${indexCmd}]} mpich.c -o ${exeFile_evt}
	ret=$?
	
	return ${ret}
}


## TODO：运行测试
#
Run_MPICH(){
	local ret=0

	eval ${cmdMpirunList[${indexCmd}]} -np 5 ./${exeFile_evt} > ${retFile_evt}
	ret=$?

	return ${ret}
}


## TODO : 断言分析
# 
Assert_MPICH(){
	local ret=0

	# 判断结果是否正确
	local strnum=0
	strnum=$(cat ${retFile_evt} | grep "hello world" | wc -l)
        # 判断结果是否正确
        if [ ${strnum} -ne 5 ];then
		echo "MPICH Assert Failed !"
                return 1
        fi

	return ${ret}
}


## TODO : 清除生成的文件
#
Clean_MPICH(){
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi

	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

	unset -v exeFile_evt retFile_evt cmdMpiccList cmdMpirunList indexCmd
}

Main_MPICH(){
        Setup_MPICH

        # 调用主函数
        Main_DME $@
}

Main_MPICH $@

exit $?

