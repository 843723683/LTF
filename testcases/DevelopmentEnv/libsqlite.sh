#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename : libsqlite.sh 
# Version  : 1.0
# Date     : 2019/11/12
# Author   : Lz
# Email    : lz843723683@163.com
# History  :     
#            Version 1.0, 2019/11/12
# Function : libsqlite.sh  - 测试支持 libsqlite 开发和运行环境
# Out      :        
#              0=> Success
#              1=> Fail
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO: 搭建运行环境
#
Setup_SQL(){
	# 工具名称,需要和XML文件中CaseName一致
        local toolName="libsqlite"

	# 加载运行环境工具函数
        if [ -f "$(dirname $0)/lib/developmentEnv.sh"  ];then
        	source $(dirname $0)/lib/developmentEnv.sh
        else
                echo "TCONF : Can't found library file ($(dirname $0)/lib/developmentEnv.sh)"
                exit 2
        fi

	# 注册函数
        RegisterFunc_DME "Init_SQL" "Install_SQL" "Run_SQL" "Assert_SQL" "Clean_SQL"
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
Init_SQL(){
        local ret=0
	
	# 二进制名
	exeFile_evt="libsqlite.elf"
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi
	# 结果文件名
	retFile_evt="libsqlite.ret"
	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

	# libsqlite.c生成的数据库文件名
	dbFile_evt="my.db"
	if [ -f "${dbFile_evt}"  ];then
		rm ${dbFile_evt}
	fi

        return $ret
}


## TODO :进行编译安装等操作
#
Install_SQL(){
	local ret=0

	# 编译
	gcc libsqlite.c -o ${exeFile_evt} -lsqlite3
	ret=$?

	return ${ret}
}


## TODO：运行测试
#
Run_SQL(){
	local ret=0

        ./${exeFile_evt} > ${retFile_evt}
	ret=$?

	return ${ret}
}


## TODO : 断言分析
# 
Assert_SQL(){
	local ret=0

	# 判断结果是否正确
	cat ${retFile_evt} | grep -q "open db success!"
	if [ $? -ne 0 ];then
		echo "Libsqlite Assert Failed !"
		return 1
	fi

	# 判断是否生成数据库文件
	if [ ! -f "${dbFile_evt}" ];then
		echo "Libsqlite Assert Failed !"
		return 1
	fi

	return ${ret}
}


## TODO : 清除生成的文件
#
Clean_SQL(){
	if [ -f "${exeFile_evt}"  ];then
		rm ${exeFile_evt}
	fi

	if [ -f "${retFile_evt}"  ];then
		rm ${retFile_evt}
	fi

	# libsqlite.c生成的数据库文件名
	if [ -f "${dbFile_evt}"  ];then
		rm ${dbFile_evt}
	fi

	
	unset -v exeFile_evt retFile_evt dbFile_evt
}

Main_SQL(){
        Setup_SQL

        # 调用主函数
        Main_DME $@
}

Main_SQL $@

exit $?

