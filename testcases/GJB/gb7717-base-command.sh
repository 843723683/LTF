#!/bin/bash

# unbound exit
set -u

readonly TPASS=0
readonly TFAIL=1
readonly TCONF=2

# Test Directory
CMDTESTROOT_GJB="/var/tmp"
CMDTESTDIR_GJB="${CMDTESTROOT_GJB}/test-gjb"

# Exists commands
CMDEXISTS_GJB=("NONE")
# Result Flag
CMDRETFLAG_GJB="${TPASS}"


# All commands
readonly COMMANDS="[ ar at awk basename batch bc cat cd  chfn chgrp \
			chmod chown chsh cksum cmp col comm cp cpio crontab \
			csplit cut date dd df diff dirname dmesg du echo \
			ed egrep env expand expr false fgrep file find fold \
			fuser gencat getconf gettext grep groupadd groupdel \
			groupmod groups gunzip gzip head hostname iconv id \
			install ipcrm ipcs join kill killall ln localedef \
			locate logger logname lp lpr \
			ls m4 mailx make man md5sum mkdir mkfifo mknod \
			mktemp more mount msgfmt mv newgrp nice nl nohup \
			od passwd paste patch pathchk pax pidof pr printf \
			ps pwd renice rm rmdir sed sendmail seq sh shutdown \
			sleep sort split strings strip stty su sync tail tar \
			tee test time touch tr true tsort tty umount uname \
			unexpand uniq useradd userdel usermod wc xargs zcat"

#----------------------------------------------------------------------------#

## TODO : Determine if the command exists
#   Out : TPASS => success
#         TFAIL => failed
#         TCONF => conf
CMDExistTest_GJB(){
	local ret=${TPASS}
	# Command that does not exit
	local failstr=""
	# Number of Commands
	local sum=0
	local cmd=""
	for cmd in $COMMANDS
	do
		let sum=sum+1
		which ${cmd} > /dev/null 2>&1
                if [ $? -eq 0 ];then
			CMDEXISTS_GJB=("${CMDEXISTS_GJB[@]}" ${cmd})
			continue
                fi

		type ${cmd} > /dev/null 2>&1
		if [ $? -eq 0 ];then
			CMDEXISTS_GJB=("${CMDEXISTS_GJB[@]}" ${cmd})
			continue
		fi
		
		# Can't found command	
		ret=${TFAIL}
		failstr="${failstr} ${cmd}"
	done

	[ "Z$failstr" != "Z" ] && echo "Can't found commands : $failstr"
	echo "Commands Total : $sum"

	return ${ret}
}


## TODO : Run testcases
#    In : command name
CMDRunTest_GJB(){
	if [ $# -ne 1 ];then
		return ${TCONF}
	fi

	local ret=${TPASS}

	# Run testcases function
	local cmdname="$1"
	if [ "${cmdname}" == "[" ];then
		# Special characters "["
		CMDTest_brackets_GJB
		ret=$?
	else
		# Determine if the function has been defined
		if [ "$(type -t CMDTest_${cmdname}_GJB)" == "function" ];then
			# defined
			eval CMDTest_${cmdname}_GJB ${cmdname}
			ret=$?
		else
			# undefined
			echo "CMDTest_${cmdname}_GJB : Can't found function "
			return ${TCONF}
		fi
	fi

	return ${ret}
}


## TODO : 1 - [ 条件表达式
#    In : $1 => command name
CMDTest_brackets_GJB(){
	local ret=${TPASS}

	[ "True" != "True" ] && return ${TFAIL}

	return ${ret}
}


## TODO     : 2 - ar 建立或修改备存文件,或是从备存文件中抽取文件
#  Function : rv => 打包文件
#           : t  => 显示打包文件的内容 
CMDTest_ar_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	touch a.c b.c

	${cmd} rv one.bak a.c b.c &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} t one.bak > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 3 - at 计划任务,在特定的时间执行某项工作,在特定的时间执行一次
#  Function : at now + 1 minutes <<< "/bin/ls"  => 在一分钟后执行/bin/ls
#           : atq => 查看待处理的作业 
#           : -V  => 查看版本
CMDTest_at_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	at now + 1 minutes <<< "date" &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	atq > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	at -V &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 4 - awk 文本处理工具
#  Function : FS => 分隔符
#             NR => 行数
#             NF => 列数
CMDTest_awk_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	echo hello:world | ${cmd} 'BEGIN {FS = ":"} {print $1}' | grep -q "hello"
	[ $? -ne 0 ] && return ${TFAIL}
	echo hello world | ${cmd} '{print NR}' | grep -q "1"
	[ $? -ne 0 ] && return ${TFAIL}
	echo hello world | ${cmd} '{print NF}' | grep -q "2"
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 5 - basename 获取路径中的文件名或路径名,还可以对末尾字符进行删除
#  Function : --v => 查看版本
#           : -s  => 去除扩展名
#           : -a  => 支持多个参数，并将每个参数都视为一个NAME
CMDTest_basename_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	touch lz.c zl.c

	${cmd} --v > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -s .c lz.c >/dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -a lz.c zl.c > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}


	return ${TPASS}
}


## TODO     : 6 - batch 执行批处理命令
#  Function : 
CMDTest_batch_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	# 没有任何参数
	${cmd} <<< "echo lz" &>/dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	# 休眠，等待任务完成
	sleep 10

	return ${TPASS}
}


## TODO     : 7 - bc 计算器
#  Function : 加减乘除 
CMDTest_bc_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	echo "7/7" | ${cmd} | grep -q 1
	[ $? -ne 0 ] && return ${TFAIL}
	echo "7*7" | ${cmd} | grep -q 49
	[ $? -ne 0 ] && return ${TFAIL}
	echo "7+7" | ${cmd} | grep -q 14
	[ $? -ne 0 ] && return ${TFAIL}
	echo "7-7" | ${cmd} | grep -q 0
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 8 - cat 输出文件内容
#  Function : -n => 由 1 开始对所有输出的行数编号
#             -b => -n 相似，只不过对于空白行不编号
#             -A => 等价于 -vET
#-v 或 --show-nonprinting：使用 ^ 和 M- 符号，除了 LFD 和 TAB 之外。
#-E 或 --show-ends : 在每行结束处显示 $。
#-T 或 --show-tabs: 将 TAB 字符显示为 ^I。
CMDTest_cat_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	touch lz.txt
	echo "lz" > lz.txt
	echo "hello" >> lz.txt

	${cmd} -n lz.txt > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -b lz.txt > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -A lz.txt > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 9 - cd 切换当前目录
#  Function : ../ => 进入上一级目录
#             -   => 返回上一次目录
CMDTest_cd_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} ${CMDTESTDIR_GJB}
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} ../
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} - > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 10 - chfn 提供使用者更改个人资讯
#  Function : -f => 设置真实姓名
#           : -h => 设置家中的电话号码
#           : -o => 设置办公室的地址
CMDTest_chfn_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"
	
	${cmd} -f lz -h 777 -o cs
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 11 - chgrp 改变文件或目录所属群组
#  Function : --version => 查看版本
#           : -h => 只对符号连接的文件作修改，而不更动其他任何相关文件
#           : --reference => 文件lz2.chgrp的群组属性和参考文件lz.chgrp的群组属性相同
CMDTest_chgrp_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	touch lz.chgrp
	touch lz2.chgrp
	
	chgrp --version >/dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	chgrp -h --reference=lz.chgrp lz2.chgrp 
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 12 - chmod 设置文件或目录权限
#  Function : a+xrw => 用户、用户组、其他均由读写执行权限 
CMDTest_chmod_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	touch lz-chmod

	chmod a+xrw lz-chmod
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 13 - chown 将指定文件的拥有者改为指定的用户或组
#  Function : -R => 处理指定目录以及其子目录下的所有文件
#           : -f => 忽略错误信息
#           : -h => 修复符号链接
CMDTest_chown_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

        cd ${CMDTESTDIR_GJB}
        touch lz-chown

	chown -Rfh root:root lz-chown
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 14 - chsh 改变使用者的shell设置
#  Function : -h => 在线帮助
#           : -s => 改变当前的shell设置
CMDTest_chsh_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	local shellenv="$(echo ${SHELL})"
	# 避免误操作导致root无法的登录，需要修改/etc/passwd中bin/***修改为可用的shell环境
	if [ ! -f "$shellenv" ];then
		echo "${shellenv} : Can't found file"	
		return ${TCONF}
	fi

	${cmd} -s ${shellenv}
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 15 - cksum 文件校验
#  Function : --help => 在线帮助
#           : --version => 显示版本信息
#           : => 检查文件的CRC是否正确
CMDTest_cksum_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-cksum

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} lz-cksum > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 16 - cmp 比较文件差异
#  Function : -s => 不显示错误信息
#           : -l => 标示出所有不一样的地方
#           : -c => 标示出所有不一样的地方
CMDTest_cmp_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-cksum1 lz-chsum2

	${cmd} -s lz-cksum1 lz-chsum2
	[ $? -ne 0 ] && return ${TFAIL}

	${cmd} -l -c lz-cksum1 lz-chsum2
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 17 - col 过滤控制字符
#  Function : -x => 以多个空格字符来表示跳格字符
#           : -f => 滤掉RLF字符，但允许将HRLF字符呈现出来
#           : -b => 过滤掉所有的控制字符，包括RLF和HRLF
CMDTest_col_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-col

	cat lz-col | ${cmd} -x -f -b	
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 18 - comm 比较两个已排过序的文件
#  Function : -1 => 不显示只在第1个文件里出现过的列
#           : -2 => 不显示只在第2个文件里出现过的列
#           : -3 => 不显示只在第1和第2个文件里出现过的列
CMDTest_comm_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1 lz-${cmd}-2
	echo "helloworld - ${cmd}" > lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-2

	${cmd} -12 lz-${cmd}-1 lz-${cmd}-2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -3 lz-${cmd}-1 lz-${cmd}-2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 19 - cp 复制文件和目录
#  Function : -p => 复制后目标文件保留源文件的属性（包括所有者、所属组、权限和时间） 
#           : -f => 强行复制文件或目录，不论目标文件或目录是否存在
#           : -R(-r) => 递归复制，用于复制目录
CMDTest_cp_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}
	echo "helloworld - ${cmd}" > lz-${cmd}

	${cmd} -pfR lz-${cmd} lz-${cmd}-bak > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 20 - cpio 建立，还原备份档
#  Function : -o => -o或--create 　执行copy-out模式，建立备份档
#           : -t => 将输入的内容呈现出来
#           : -I => 执行copy-in模式，还原备份档
CMDTest_cpio_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}
	echo "helloworld - ${cmd}" > lz-${cmd}

	ls | ${cmd} -o > ys-${cmd}
	[ $? -ne 0 ] && return ${TFAIL}
	cpio -t -i < ys-${cmd} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 21 - crontab 在固定时间或间隔执行程序
#  Function : -u => 用来设定某个用户的crontab服务
#           : -l => 显示某个用户的crontab文件内容，如果不指定用户，则表示显示当前用户的crontab文件内容
#           : -r => 删除工作表
CMDTest_crontab_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"
        touch lz-${cmd}
	echo "* * * * * ls" > lz-${cmd}

	${cmd} -u root -l &>/dev/null
	if [ $? -ne 0 ];then
		# 没有定时任务
		${cmd} -u root lz-${cmd}
		[ $? -ne 0 ] && return ${TFAIL}
		${cmd} -u root -l > /dev/null
		[ $? -ne 0 ] && return ${TFAIL}
		${cmd} -u root -r
		[ $? -ne 0 ] && return ${TFAIL}
	else
		# 存在定时任务
		${cmd} -u root -l > crontab-bak
		[ $? -ne 0 ] && return ${TFAIL}
		${cmd} -u root -r
		[ $? -ne 0 ] && return ${TFAIL}
		${cmd} -u root crontab-bak
		[ $? -ne 0 ] && return ${TFAIL}
	fi

	return ${TPASS}
}


## TODO     : 22 - csplit 分割文件
#  Function : -q => 不显示指令执行过程
#           : -n => 预设的输出文件名位数其文件名称为xx00,xx01...等，如果你指定输出文件名位数为"3"，则输出的文件名称会变成xx000,xx001...等
#           : -f =>  预设的输出字首字符串其文件名为xx00,xx01...等，如果你指定输出字首字符串为"hello"，则输出的文件名称会变成hello00,hello01...等
CMDTest_csplit_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}
	echo "helloworld - ${cmd}" > lz-${cmd}

	${cmd} -q -n 3 -f ${cmd}- lz-${cmd} 1
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 23 - cut 剪切文件
#  Function : -f => 显示指定字段的内容
#           : -d => 指定字段的分隔符，默认的字段分隔符为“TAB”
#           : -c => 仅显示行中指定范围的字符
CMDTest_cut_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}
	echo "helloworld - ${cmd}" > lz-${cmd}

	${cmd} -f2 -d"-" lz-${cmd}  > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -c1-3 lz-${cmd} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 24 - date 显示或设定系统的日期与时间
#  Function : -R => 以RFC 5322格式输出日期和时间
#           : -u => 显示目前的格林威治时间
#           : --version => 显示版本编号
CMDTest_date_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -R > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -u > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 25 - dd 从标准输入或文件中读取数据，根据指定的格式来转换数据，再输出到文件、设备或标准输出 
#  Function : if => 输入文件名，默认为标准输入。即指定源文件
#           : of => 输出文件名，默认为标准输出。即指定目的文件
#           : bs => 同时设置读入/输出的块大小为bytes个字节
#           : count => 仅拷贝blocks个块，块大小等于ibs指定的字节数
CMDTest_dd_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} if=/dev/zero of=lz-${cmd} bs=1M count=1 &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 26 - df 显示目前在Linux系统上的文件系统的磁盘使用情况统计
#  Function : -h => 使用人类可读的格式(预设值是不加这个选项的
#           : -a => 包含所有的具有 0 Blocks 的文件系统
#           : -i => 列出 inode 资讯，不列出已使用 block
CMDTest_df_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -hai > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 27 - diff 在最简单的情况下,比较两个文件的不同
#  Function : -a => diff预设只会逐行比较文本文件
#           : -e => 此参数的输出格式可用于ed的script文件
#           : -f => 输出的格式类似ed的script文件，但按照原来文件的顺序来显示不同处
CMDTest_diff_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"
	
	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1 lz-${cmd}-2
	echo "helloworld - ${cmd}" > lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-2

	${cmd} -a -e lz-${cmd}-1 lz-${cmd}-2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -f lz-${cmd}-1 lz-${cmd}-2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 28 - dirname 显示文件或者目录所在的路径
#  Function : -z => 获取多个目录列表，以NUL为分隔
#           : --help => 帮助信息
#           : --version => 版本信息
CMDTest_dirname_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -z $0 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 29 - dmesg 显示开机信息
#  Function : -e => 以易读格式显示本地时间和时间差
#           : -k => 显示内核消息
#           : -S => 强制使用 syslog(2) 而非 /dev/kmsg
CMDTest_dmesg_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -e -k > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -S > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 30 - du 显示目录或文件占磁盘空间
#  Function : -a => 显示目录中个别文件的大小
#           : -c => 除了显示个别目录或文件的大小外，同时也显示所有目录或文件的总和
#           : -h => 以K，M，G为单位，提高信息的可读性
CMDTest_du_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -a -c -h > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 31 - echo 显示文本行
#  Function : -n => 输出之后不换行
#           : -e => 启用反斜杠转义的解释
#           : -E => 禁用反斜杠转义的解释（默认）
CMDTest_echo_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -n "hello ${cmd}" > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -e "hello \n ${cmd}" > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -E "hello \n ${cmd}" > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 32 - ed 文本编辑
#  Function : --help => 显示帮助
#           : --version => 显示版本信息
#           : -G => 提供回兼容的功能
CMDTest_ed_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -G <<< "q" > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 33 - egrep 在文件内查找指定字符串
#  Function : -i => 忽略大小写
#           : --help => 显示帮助
#           : -V => 显示版本信息
CMDTest_egrep_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-1

	${cmd} -i "helloworld" lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -V > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	
	return ${TPASS}
}


## TODO     : 34 - env 显示系统中已存在的环境变量
#  Function : -0 => 用NUL而不是换行符结束每个输出行
#           : --help => 显示帮助
#           : --version => 显示版本信息
CMDTest_env_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -0 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 35 - expand 将TAB装化为空格
#  Function : -i => 不转换非空白符后的制表符
#           : -t => 指定一个tab替换为多少个空格，而不是默认的8
#           : --version => 显示版本信息
CMDTest_expand_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-1

	${cmd} -i lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -t 10 lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 36 - expr 对字符串进行处理
#  Function : --version => 显示版本信息
#           : --help => 显示帮助
#           : expr + => 算术运算
CMDTest_expr_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	local count=0
	count=`expr $count + 1`
	[ $count -ne 1 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 37 - false 表示失败,无任何参数
#  Function : 
CMDTest_false_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd}
	[ $? -eq 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 38 - fgrep 匹配字符串
#  Function : -i => 忽略大小写
#           : -n => 输出的同时打印行号
#           : -H => 为每一匹配项打印文件名
CMDTest_fgrep_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-1

	cat lz-${cmd}-1 | ${cmd} -i -n -H "hello" > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 39 - file 辨识文件类型
#  Function : -L => 直接显示符号连接所指向的文件的类别
#           : -b => 列出辨识结果时，不显示文件名称
#           : -i => 列出辨识结果时，不显示文件名称
CMDTest_file_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-1

	${cmd} -Lbi lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 40 - find 查找目录或文件
#  Function : -type => 根据文件类型查找
#           : -user => 根据文件属主查找
#           : -name => 文件名称符合 name 的文件
CMDTest_find_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-1

	${cmd} ./ -type f -user root > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} ./ -name lz*  > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 41 - fold 限制文件列宽
#  Function : -b => 以Byte为单位计算列宽，而非采用行数编号为单位
#           : -s => 以空格字符作为换列点
#           : -w => 设置每列的最大行数
CMDTest_fold_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-1

	${cmd} -bs lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -w 3 lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 42 - fuser 根据文件或文件结构识别进程
#  Function : -a => 显示命令行中指定的所有文件 
#           : -l => 列出所有已知信号名
#           : --version => 显示版本信息
CMDTest_fuser_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -a / &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -l > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 43 - gencat 生成一个格式化消息分类
#  Function : -o => 将输出写入到指定文件中 
#           : --version => 显示版本信息
#           : --help => 显示帮助信息
CMDTest_gencat_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} lz-${cmd}-1 -o new > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 44 - getconf 获取系统信息
#  Function : PAGESIZE => 查看系统内存分页大小
#           : LONG_BIT => 看linux是32位还是64位最简单的方法
#           : -a => 获取全部系统信息
CMDTest_getconf_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} PAGESIZE > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -a > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} LONG_BIT > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 45 - gettext 在消息队列中查找，将自然语言消息翻译成用户本地语言
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -s => 程序的行为类似于'echo'命令
CMDTest_gettext_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "helloworld - ${cmd}" > lz-${cmd}-1

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -s lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 46 - grep 查找文件里符合条件的字符串
#  Function : -i => 忽略字符大小写的差别
#           : -v => 显示不包含匹配文本的所有行
#           : -l => 列出文件内容符合指定的样式的文件名称
CMDTest_grep_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "hello world - ${cmd}" > lz-${cmd}-1
	echo "world - ${cmd}" >> lz-${cmd}-1

	cat lz-${cmd}-1 | ${cmd} -i HELLO > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	cat lz-${cmd}-1 | ${cmd} -v hello > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -l hello lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 47 - groupadd 创建一个新的组
#  Function : -f => 如果指定的组已经存在，此选项将仅以成功状态退出
#           : -r => 创建一个系统组
#           : -p => 为新组使用此加密过的密码
CMDTest_groupadd_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	groupadd -f ltf-testgroup
	[ $? -ne 0 ] && return ${TFAIL}
	groupmod ltf-testgroup -n ltf-testgroup-mod
	[ $? -ne 0 ] && return ${TFAIL}
	groupdel ltf-testgroup-mod
	[ $? -ne 0 ] && return ${TFAIL}

	groupadd -r ltf-testgroup
	[ $? -ne 0 ] && return ${TFAIL}
	groupdel ltf-testgroup
	[ $? -ne 0 ] && return ${TFAIL}

	groupadd -p 123123 ltf-testgroup
	[ $? -ne 0 ] && return ${TFAIL}
	groupmod -p 321321 ltf-testgroup
	[ $? -ne 0 ] && return ${TFAIL}
	groupdel  ltf-testgroup
	[ $? -ne 0 ] && return ${TFAIL}

	groupmod --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	groupdel --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 48 - groupdel 删除群组
#  Function : -f => 删除组，即使它是用户的主要组
#           : --help => 显示帮助信息
#  注       : 必须在groupadd之后测试!!!
CMDTest_groupdel_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	# 注：必须在groupadd之后测试!!!

	return ${TPASS}
}


## TODO     : 49 - groupmod 更改群组识别码或名称
#  Function : -n => 更改群组名
#           : -p => 更改组密码
#           : --help => 显示帮助信息
#  注       : 必须在groupadd之后测试!!!
CMDTest_groupmod_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	# 注：必须在groupadd之后测试!!!

	return ${TPASS}
}


## TODO     : 50 - groups 查看到当前用户所属的组
#  Function : --help => 显示帮助信息
#           : --version => 显示版本信息
CMDTest_groups_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 51 - gunzip 解压文件
#  Function : -f => 强行解开压缩文件，不理会文件名称或硬连接是否存在以及该文件是否为符号连接
#           : -c => 把解压后的文件输出到标准输出设备
#           : -v => 显示指令执行过程
CMDTest_gunzip_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "hello world - ${cmd}" > lz-${cmd}-1

	gzip -frv lz-${cmd}-1 &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	gunzip -cfv lz-${cmd}-1.gz > lz-${cmd}-1.gz &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 52 - gzip 压缩文件
#  Function : -f => 强行压缩文件。不理会文件名称或硬连接是否存在以及该文件是否为符号连接
#           : -r => 递归处理，将指定目录下的所有文件及子目录一并处理
#           : -v => 显示指令执行过程
#  注       : 必须在gunzip之后测试!!!
CMDTest_gzip_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	#  注: 必须在gunzip之后测试!!!

	return ${TPASS}
}


## TODO     : 53 - head 显示文件的开头至标准输出中
#  Function : -c => 显示文件的前n个字节
#           : -n => 显示文件的前n行
#           : -v => 显示文件名
CMDTest_head_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "hello world - ${cmd}" > lz-${cmd}-1

	${cmd} -c 10 lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -n 10 -v lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 54 - hostname 显示或者设置主机名
#  Function : -a => 显示主机别名 
#           : -f => 表示输出当前主机中的FQDN（全限定域名）
#           : -s => 显示短主机名称，在第一个点处截断
CMDTest_hostname_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -a > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -f > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -s > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 55 - iconv 文件转码命令
#  Function : -f => 原编码
#           : -t => 目标编码
#           : -o => 输出文件
CMDTest_iconv_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	
	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "hello world - ${cmd}" > lz-${cmd}-1

	${cmd} -f ASCII -t UTF-32 lz-${cmd}-1 -o newfile
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 56 - id 显示用户的ID，以及所属群组的ID
#  Function : -g => 显示用户所属群组的ID 
#           : -G => 显示用户所属附加群组的ID
#           : -u => 显示用户ID
CMDTest_id_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -g > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -G > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -u > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 57 - install 安装或升级软件或备份数据
#  Function : -p => 以<来源>文件的访问/修改时间作为相应的目的地文件的时间属性
#           : -D => 创建<目的地>前的所有主目录，然后将<来源>复制至 <目的地>；在第一种使用格式中有用 
#           : -m => 自行设定权限模式 (像chmod)，而不是rwxr－xr－x
CMDTest_install_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1 lz-${cmd}-2
	echo "hello world - ${cmd}" > lz-${cmd}-1

	${cmd} -p -D -m 0755 lz-${cmd}-1 lz-${cmd}-2
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 58 - ipcrm 移除一个消息对象。或者共享内存段，或者一个信号集
#  Function : -v => --verbose 解释正在做什么
#           : --help => 显示帮助信息
#           : --version => 显示版本信息
CMDTest_ipcrm_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -v
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 59 - ipcs 显示进程间通信方式的信息，包括共享内存，消息队列，信号
#  Function : -m => 打印出使用共享内存进行进程间通信的信息
#           : -q => 打印出使用消息队列进行进程间通信的信息
#           : -s => 打印出使用信号进行进程间通信的信息
CMDTest_ipcs_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1
	echo "hello world - ${cmd}" > lz-${cmd}-1

	${cmd} -mqs lz-${cmd}-1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 60 - join 将两个文件中，指定栏位内容相同的行连接起来
#  Function : -t => 使用栏位的分隔字符
#           : -a => 除了显示原来的输出内容之外，还显示指令文件中没有相同栏位的行
#           : -1 => 连接[文件1]指定的栏位
CMDTest_join_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1 lz-${cmd}-2
	echo "hello world - ${cmd}" > lz-${cmd}-1
	echo "hello world - ${cmd}" > lz-${cmd}-2

	${cmd} -t '-' lz-${cmd}-1 lz-${cmd}-2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -a1 lz-${cmd}-1 lz-${cmd}-2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 61 - kill 杀死执行中的进程
#  Function :  
CMDTest_kill_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz_kill_1
	cat > lz_kill_1 << EOF
#!/bin/bash
sleep 2
EOF
	cp lz_kill_1 lz_kill_2
	chmod a+x lz_kill_1 lz_kill_2

	local kill_pid=0
	./lz_kill_1 &
	kill_pid="$!"
	ps -aux | grep ${kill_pid} | grep "./lz_kill_1" > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	kill -2 ${kill_pid}
	[ $? -ne 0 ] && return ${TFAIL}

	./lz_kill_2 &
	kill_pid="$!"
	ps -aux | grep ${kill_pid} | grep "./lz_kill_2" > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	kill -9 ${kill_pid}
	[ $? -ne 0 ] && return ${TFAIL}
	kill -l > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	# 等待结束
	sleep 2

	return ${TPASS}
}


## TODO     : 61 - killall 杀死指定名字的进程
#  Function : -q => 静默输出
#           : -w => 等待进程死亡
#           : --version => 显示版本信息
CMDTest_killall_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz_killall
	cat > lz_killall << EOF
#!/bin/bash
for i in \$(seq 0 2)
do
	echo "hello" > /dev/null
	sleep 1
done
EOF
	chmod a+x lz_killall

	${cmd} -l > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	./lz_killall &
	[ $? -ne 0 ] && return ${TFAIL}
	local retstr=$(${cmd} -q lz_killall)

	[ "Z$retstr" != "Z" ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 63 - ln 链接文件或目录
#  Function : -f => 强制执行
#           : -v => 显示详细的处理过程
#           : -s => 软链接(符号链接)
CMDTest_ln_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch lz-${cmd}-1 
	echo "hello world - ${cmd}" > lz-${cmd}-1

	${cmd} -fv lz-${cmd}-1 ${cmd}-link1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -s lz-${cmd}-1 ${cmd}-link2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 64 - localedef 将依赖于语言环境信息（诸如整理、日期和时间格式以及字符属性）定义的源文件转化为运行时需要使用的语言环境对象代码
#  Function : --list-archive => 查看语言支持列表
#           : --help => 显示帮助信息
#           : --version => 显示版本信息
CMDTest_localedef_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --list-archive > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 65 - locate 查找文件
#  Function : -i => 匹配模式时忽略大小写区别
#           : -b => 只匹配路径名的基本名称
#           : -c => 只显示找到的条目的数目
CMDTest_locate_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	# 更新数据库
	updatedb &>/dev/null

	${cmd} -i ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -bc ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 66 - logger shell命令接口，可以通过该接口使用Syslog的系统日志模块，还可以从命令行直接向系统日志文件写入一行信息
#  Function : -i => 逐行记录每次logger进程id
#           : -t => 指定标记记录
#           : -s => 输出标准错误到系统日志
CMDTest_logger_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -i -t root -s "ltf hello world" &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 67 - logname 显示用户名称
#  Function : --help => 显示帮助信息
#           : --version => 显示版本信息
CMDTest_logname_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 68 - lp 打印文件
#  Function : -c => 先拷贝再打印
#           : -m => 打印结束后发送电子邮件到用户
#           : -n => 打印份数
CMDTest_lp_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile

	${cmd} -c -m -n30 ${cmd}testfile &>/dev/null
	if [ $? -ne 0 ];then
		# 判断是否无打印机
		${cmd} -c -m -n30 ${cmd}testfile 2>&1 | grep -q -i -v "unknown"
		if [ $? -ne 0 ];then
			return ${TFAIL}
		fi
	fi

	# 删除所有打印任务
	lprm - &> /dev/null 

	return ${TPASS}
}


## TODO     : 69 - lpr 将一个或多个文件放入打印队列等待打印
#  Function : -E => 使用加密模式
#           : -U => 设置别名
#           : -m => 打印完成后发送邮件
CMDTest_lpr_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile
	
	${cmd} -E -U test -m ${cmd}testfile &>/dev/null
	if [ $? -ne 0 ];then
		# 判断是否无打印机
		 ${cmd} -E -U test -m ${cmd}testfile 2>&1 | grep -q -i -v "unknown"
		if [ $? -ne 0 ];then
			return ${TFAIL}
		fi
	fi

	# 删除所有打印任务
	lprm - &> /dev/null 

	return ${TPASS}
}


## TODO     : 70 - ls 查看文件或目录属性
#  Function : -l => 列出文件的详细信息
#           : -h => 以合适的单位换算大小
#           : -t => 按时间进行文件排序
CMDTest_ls_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"
	
	${cmd} -lht > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 71 - m4 宏处理器
#  Function : -E => 第一次：警告变成错误，第二次:停止执行在第一次错误后
#           : -P => 强制为所有的内建添加一个"m4"前缀
#           : -i => 取消缓冲输出，忽略中断
CMDTest_m4_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile
	
	${cmd} -Ei ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -P ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 72 - mailx 处理邮件收发
#  Function : -i => 忽略终端发出的信息
#           : -s => 指定邮件的主题
#           : -V => 显示版本信息
#       FAQ : 
# 1. 出现cannot send message: Process exited with a non-zero status错误
#  sudo dpkg-reconfigure postfix
#  配置选择：Internet Site=>System mail name:保持默认（如：ubuntu）=>其他的都选默认的，配置完成后就存在/etc/postfix/main.cf文件了
CMDTest_mailx_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	echo "hellworld" | ${cmd} -i -s "${cmd}" test@qq.com > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -V > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 73 - make 按规则执行批量程序
#  Function : -d => 打印大量调试信息
#           : -B => 无条件 make 所有目标
#           : -p => 打印 make 的内部数据库
CMDTest_make_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile.c

	cat > ${cmd}testfile.c << EOF
#include <stdio.h>
int main(void){
	printf("hello world\n");
	return 0;
}
EOF
	cat > Makefile <<EOF
${cmd}testfile:${cmd}testfile.c
	gcc -o ${cmd}testfile ${cmd}testfile.c
EOF

	${cmd} -dB > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -p > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 74 - man 在线帮助手册
#  Function : -f => 等同于whatis
#           : -w => 输出手册页的物理位置
#           : --help => 显示帮助信息
CMDTest_man_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -f ls > /dev/null	
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -w ls > /dev/null	
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null	
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 75 - md5sum 生成文件的MD5散列值
#  Function : -b => 把输入文件作为二进制文件
#           : -t => 把输入文件作为文本文件
#           : --help => 显示帮助信息
CMDTest_md5sum_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile

	${cmd} -b ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -t ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 76 - mkdir 创建目录
#  Function : -p => 可一次性建立多个目录
#           : -v => 每次创建新目录都显示信息
#           : -Z => 为创建的文件设立selinux安全文本
CMDTest_mkdir_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}

	${cmd} -p ${cmd}testdir1
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -vZ ${cmd}testdir2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 77 - mkfifo 创建管道文件
#  Function : -m => 设置创建的FIFO的模式为 mode, 这可以是 chmod(1) 中的符号模式
#           : --help => 显示帮助信息
#           : --version => 显示配置帮助信息
CMDTest_mkfifo_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}

	${cmd} -m "a+rwx" ${cmd}testfile 
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 78 - mknod 建立块专用或字符专用文件
#  Function : --help => 显示帮助信息
#           : c => 表示字符设备文件与设备传送数据的时候是以字符的形式传送，一次传送一个字符
#           : --version => 显示版本信息 
CMDTest_mknod_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} ${cmd}testfile c 1 1 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 79 - mktemp  建立一个暂存文件，供 shellscript 使用
#  Function : -q => 发生错误的时候不显示提示信息
#           : -d => 创建目录
#           : --tmpdir => 指定临时文件的路径，如果tmpdir后面没有路径，那么使用变量$TMPDIR；如果这个变量也没指定，那么临时文件创建在/tmp目录下。使用此选项，模板不能是绝对名称。与“-t“不同，模板可能包含斜杠，但mktemp只创建最终组件
CMDTest_mktemp_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}

	${cmd} -q --tmpdir=${CMDTESTDIR_GJB} ${cmd}.XXX > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -d --tmpdir=${CMDTESTDIR_GJB} ${cmd}.XXXX > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 80 - more 显示文件信息
#  Function : -p => 不以卷动的方式显示每一页，而是先清除屏幕后再显示内容
#           : -u =>
#           : -V => 不显示下引号 
CMDTest_more_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile

	${cmd} -V > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -p ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -u ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 81 - mount 挂载文件系统
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -l => 显示已加载的文件系统列表
CMDTest_mount_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -l > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 82 - msgfmt 产生二进制消息目录的程序，这个命令主要用来本地化 
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -O => 将输出写入指定文件
CMDTest_msgfmt_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -o ${cmd}testfile.mo ${cmd}testfile
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 83 - mv 移动或者改名现有的文件或目录
#  Function : --help => 显示版本信息
#           : -v => 解释正在做什么
#           : -f => 在mv操作要覆盖某已有的目标文件时不给任何指示
CMDTest_mv_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -v ${cmd}testfile ${cmd}testfile-bak > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -f ${cmd}testfile-bak ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 84 - newgrp 如果一个用户属于多个用户组，则可以通过该命令切换到其他组下面
#  Function : 无参数 
CMDTest_newgrp_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} <<< exit
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 85 - nice 设置程序运行的优先级
#  Function : --help => 显示帮助信息
#           : -n => 选项后面跟具体的niceness值。niceness值的范围-20~19，小于-20或大于19的值分别记为-20和19
#           : --version => 显示版本信息
CMDTest_nice_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -n -20 ls > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 86 - nl 显示文件的行号
#  Function : -b a => 表示不论是否为空行，也同样列出行号(类似 cat -n)
#           : -b t => 如果有空行，空的那一行不要列出行号(默认值)
#           : -n ln => 行号在萤幕的最左方显示 
CMDTest_nl_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile

	${cmd} -b a ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -b t ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -n ln ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 87 - nohup 让某个程序在后台运行 
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
CMDTest_nohup_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"
	
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} ls &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 88 - od 以八进制或其他格式显示文件
#  Function : --help => 显示帮助信息
#           : -f => 即 -t fF，指定浮点数对照输出格式
#           : -l => 即 -t dL，指定十进制长整数对照输出格式
CMDTest_od_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -f ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -l ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 89 - passwd 设置账户登录密码
#  Function : --help => 显示帮助信息
#           : -S => 查询用户密码的状态，也就是 /etc/shadow 文件中此用户密码的内容。仅 root 用户可用
CMDTest_passwd_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -S root > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 90 - paste 合并文件的列
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -s => 合并指定文件的多行数据
CMDTest_paste_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -s ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 91 - patch 根据原文件和补丁文件生成新的目标文件
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -p0 => 设置欲剥离几层路径名称
CMDTest_patch_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile1 ${cmd}testfile2
	echo "hello world - ${cmd}" > ${cmd}testfile1
	echo "patch ${cmd}" > ${cmd}testfile2

	diff ${cmd}testfile1 ${cmd}testfile2 > ${cmd}testfile.patch

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -p0 ${cmd}testfile1 ${cmd}testfile.patch > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 92 - pathchk 检查文件名的合法性和可移植性
#  Function : --help => 显示帮助信息
#           : -p => 检查大多数的POSIX系统
#           : --portability => 检查所有的POSIX系统，等同于“-P-p”选项
CMDTest_pathchk_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}file
	echo "hello world - ${cmd}" > ${cmd}file

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -p ${cmd}file
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --portability ${cmd}file
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 93 - pax 将文件拷贝到磁盘
#  Function : -rw => 将olddir目录层次结构复制到newdir
#           : -v => 写进程的信息 
CMDTest_pax_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        mkdir tmpdir1
        mkdir tmpdir2

	${cmd} -rwv tmpdir1 tmpdir2 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 94 - pidof 查找指定进程的进程 ID
#  Function : -s => 表示只返回1个 pid
#           : -x => 表示同时返回运行给定程序的 shell 的 pid
#           : -o => 表示告诉 piod 表示忽略后面给定的 pid ，可以使用多个 -o 
CMDTest_pidof_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -s ${cmd} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -x ${cmd} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -o 1 ${cmd} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 95 - pr 将文件分成适当大小的页送给打印机
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -h => 为页指定标题
CMDTest_pr_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch ${cmd}testfile
	echo "hello world - ${cmd}" > ${cmd}testfile

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -h "LTF!" ${cmd}testfile > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 96 - printf 文本格式输出
#  Function : %s => 字符串
#           : %d => 整形
#           : %f => 浮点形
CMDTest_printf_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} "%-10s %-8d %-4.2f\n" hello 7 7.77 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 97 - ps 显示进程状态
#  Function : -a => 显示所有终端机下执行的进程，除了阶段作业领导者之外
#           : -u => 以用户为主的格式来显示进程状况
#           : -x => 显示所有进程，不以终端机来区分
CMDTest_ps_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -aux > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 98 - pwd 显示当前工作目录的绝对路径
#  Function : -L => 目录连接链接时，输出连接路径
#           : -P => 输出物理路径
CMDTest_pwd_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -L > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -P > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 99 - renice 修改正在运行进程优先权
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -p => 标识符指定为进程ID
CMDTest_renice_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
        touch renicefile
	cat > renicefile << EOF
#!/bin/bash
for i in \$(seq 0 1)
do
	echo "hello" > /dev/null
	sleep 1
done
EOF
	chmod a+x renicefile

	${cmd} --version > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}
	./renicefile &
	[ $? -ne 0 ] && return ${TFAIL}
	local tmppid="$!"
	${cmd} 8 -p ${tmppid} > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}

	# 等待结束
	sleep 2

	return ${TPASS}
}


## TODO     : 100 - rm 删除一个文件或者目录
#  Function : --help => 显示帮助信息 
#           : -f => 即使原档案属性设为唯读，亦直接删除，无需逐一确认
#           : -r => 将目录及以下之档案亦逐一删除
CMDTest_rm_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} : helloworld" > ${tmpfile}

	${cmd} -rf ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 101 - rmdir 删除空的目录
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息 
#           : -p => 当子目录被删除后使它也成为空目录的话，则顺便一并删除
CMDTest_rmdir_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpdir="tmpdir"
        mkdir ${tmpdir}

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -p ${tmpdir} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 102 - sed 利用脚本来处理文本文件
#  Function : -n =>  仅显示script处理后的结果
#           : s => 取代
#           : p => 打印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行
#           : g => 对数据中所有匹配到的内容进行替换，如果没有 g，则只会在第一次匹配成功时做替换操作
CMDTest_sed_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	echo "helloworld" | ${cmd} -n "s/l/z/gp" > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 103 - sendmail 发送邮件的代理程序，它负责发送邮件到远程服务器，并且可以接收邮件
#  Function : -bp => 列出邮件列表
#           : -bm => 从标准输入读取邮件
#           : -f => 指定发送者
#       FAQ : 
#  1. 此命令一直不退出
#  安装sendmail命令相关包（postfix）
CMDTest_sendmail_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -bp > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	echo "helloworld" | ${cmd} -bm -f a b
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 104 - seq 从首数开始打印数字到尾数
#  Function : -s => 使用指定的字符串分割数字
#           : -f => 格式
#           : -w => 在列前添加0 使得宽度相同
CMDTest_seq_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -s, 3 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -f "%02g" 3 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -w 10 > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 105 - sh shell命令语言解释器
#  Function : -n => 进行shell脚本的语法检查
#           : -x => 实现shell脚本逐条语句的跟踪
#           : -v => Shell在读取时将其输入写入标准错误。 对于调试很有用
CMDTest_sh_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "echo helloworld" > ${tmpfile}

	${cmd} -n ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -x -v ${tmpfile} &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 106 - shutdown 系统关机指令
#  Function : --help => 显示帮助信息
CMDTest_shutdown_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 107 - sleep 休眠
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : s => 秒
CMDTest_sleep_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} 1s > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 108 - sort 命令用于将文本文件内容加以排序
#  Function : -b => 忽略每行前面开始出的空格字符
#           : -c => 检查文件是否已经按照顺序排序
#           : -r => 以相反的顺序来排序
CMDTest_sort_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "echo helloworld" > ${tmpfile}

	${cmd} -b ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -c ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -r ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 109 - split 切割文件
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -b => 指定每多少字节切成一个小文件c
CMDTest_split_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	${cmd} -b 5 ${tmpfile}
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 110 - strings 对文件的内容进行分析输出
#  Function : -n => 找到并且输出所有NUL终止符序列
#           : -t => 输出字符的位置，基于八进制，十进制或者十六进制
#           : -a => 扫描整个文件而不是只扫描目标文件初始化和装载段
CMDTest_strings_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	${cmd} -n 2 ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -t d ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -a ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 111 - strip 从特定文件中剥掉一些符号信息和调试信息
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : --info => 列出支持的对象格式和体系结构
CMDTest_strip_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --info > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 112 - stty 输出或修改终端参数
#  Function : --all => 以可读性较好的方式输出全部当前设置
#           : --help => 显示帮助信息
#           : --version => 显示版本信息
CMDTest_stty_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --all > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 113 - su 变更为其他使用者的身份
#  Function : -l => 这个参数加了之后，就好像是重新 login 为该使用者一样，大部份环境变数（HOME SHELL USER等等）都是以该使用者（USER）为主，并且工作目录也会改变，如果没有指定 USER ，内定是 root
#           : --help => 显示帮助信息
#           : -c => 变更为帐号为 USER 的使用者并执行指令（command）后再变回原来使用者
CMDTest_su_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} root -c ls --preserve-environment > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 114 - sync 将缓存区内数据写入磁盘
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息 
CMDTest_sync_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 115 - tail 从末尾显示文件
#  Function : -v => 显示详细的处理信息
#           : -n => 显示文件的尾部 n 行内容
#           : -q => 不显示处理信息
CMDTest_tail_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	${cmd} -v -n10 ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -q -n10 ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 116 - tar 解压与压缩命令
#  Function : -c => 不显示处理信息
#           : -v => 显示详细的tar处理的文件信息
#           : -f => 要操作的文件名
CMDTest_tar_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	${cmd} -czf ${tmpfile}.tar.gz ${tmpfile}
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 117 - tee 读取标准输入，将其输出到文件中
#  Function : -a => 附加到既有文件的后面，而非覆盖它
#           : -i => 忽略中断信号
#           : --help => 显示帮助信息
CMDTest_tee_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	echo "helloworld ${cmd}" | ${cmd} -a ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	echo "helloworld ${cmd}" | ${cmd} -i ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 118 - test 比较值
#  Function : -n => 字符串的长度不为零则为真
#           : -z => 字符串的长度为零则为真
#           : -f => 如果文件存在且为普通文件则为真 
CMDTest_test_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	${cmd} -n "ltf"
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} ! -z "ltf"
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -f "${tmpfile}"
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 119 - time 量测特定指令执行时所需消耗的时间及系统资源等资讯
#  Function : -o => 设定结果输出档。这个选项会将 time 的输出写入 所指定的档案中。如果档案已经存在，系统将覆写其内容
#           : -a => 配合 -o 使用，会将结果写到档案的末端，而不会覆盖掉原来的内容
#           : -v => 这个选项会把所有程序中用到的资源通通列出来，不但如一般英文语句，还有说明。对不想花时间去熟习格式设定或是刚刚开始接触这个指令的人相当有用
#     time 的 man 手册中说，它不仅可以测量运行时间，还可以测量内存、I/O 等的使用情况，但为什么上面示例中的 time 命令的结果中却没有显示出这些信息呢？难道是 man 手册出现了错误？
#     NO，NO，NO（重要的事情要说三遍），其实上面使用的 time 真的是“巧妇难为无米之炊”，我们之前所用的 time 命令是 Bash 的内置命令，功能比较弱；而更强大的 time 命令隐藏在 /usr/bin/ 目录下，这个命令才是世外高人。

CMDTest_time_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	local cmdfile="$(which ${cmd})"
	${cmdfile} -o ${tmpfile} -a -v ls > ${tmpfile}
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 120 - touch
#  Function : --help => 显示帮助信息
#           : -a => 只更改访问时间
#           : -m => 只更改修改时间
CMDTest_touch_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	${cmd} -a ${tmpfile}
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -m ${tmpfile}
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 121 - tr 转换或删除文件中的字符
#  Function : CHAR1-CHAR2 => 字符范围从 CHAR1 到 CHAR2 的指定，范围的指定以 ASCII 码的次序为基础，只能由小到大，不能由大到小 
#           : --version => 显示版本信息
#           : --help => 显示帮助信息
CMDTest_tr_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	cat ${tmpfile} | ${cmd} a-z A-Z > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 122 - true 只设置退出码为0
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
CMDTest_true_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	local cmdfile="$(which ${cmd})"
	${cmdfile}
	[ $? -ne 0 ] && return ${TFAIL}
	${cmdfile} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmdfile} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 123 - tsort 文本文件中的数据进行拓扑排
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : - => 如果不指定文件，或者文件为"-"，则从标准输入读取数据
CMDTest_tsort_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	echo "hello world" | ${cmd} - > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 124 - tty
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -s => 静默输出
CMDTest_tty_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -s
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 125 - umount
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -v => 执行时显示详细的信息
CMDTest_umount_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -v --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 126 - uname 
#  Function : -a => 显示全部的信息
#           : -r => 显示操作系统的发行编号
#           : -m => 显示电脑类型
CMDTest_uname_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} -r > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -a > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -m > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 127 - unexpand 用于将给定文件中的空白字符（space）转换为制表符（TAB），并把转换结果显示在标准输出设备
#  Function : --first-only => 仅转换开头的空白字符
#           : -t => 指定TAB所代表的N个（N为整数）字符数，默认N值是8
#           : -a => 转换文件中所有的空白字符
CMDTest_unexpand_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	${cmd} --first-only -t 8 -a ${tmpfile} > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 128 - uniq 删除文件中重复出现的行
#  Function : --help => 显示帮助信息
#           : -c => 在每列旁边显示该行重复出现的次数
#           : -d => 仅显示重复出现的行列
CMDTest_uniq_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	cd ${CMDTESTDIR_GJB}
	local tmpfile="tmpfile"
        touch ${tmpfile}
	echo "${cmd} helloworld" > ${tmpfile}

	cat ${tmpfile} | ${cmd} -c > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	cat ${tmpfile} | ${cmd} -d
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 129 - useradd 账号建立或者更新新用户信息
#  Function : -m => 自动建立用户的登入目录
#           : -M => 不要自动建立用户的登入目录 
#           : --help => 显示帮助信息
CMDTest_useradd_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"
	
	local tmpuser="ltptmpuser129"

	useradd -m ${tmpuser} 
	[ $? -ne 0 ] && return ${TFAIL}
	usermod -c "helloworld useradd" ${tmpuser}
	[ $? -ne 0 ] && return ${TFAIL}
	userdel -r ${tmpuser} 
	[ $? -ne 0 ] && return ${TFAIL}

	useradd -M ${tmpuser} 
	[ $? -ne 0 ] && return ${TFAIL}
	usermod -f 30 ${tmpuser}
	[ $? -ne 0 ] && return ${TFAIL}
	userdel -f -r ${tmpuser} &> /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	useradd --help > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}
	usermod --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	userdel --help > /dev/null 
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 130 - userdel 删除用户账号及相关信息
#  Function : --help => 显示帮助信息
#           : -r => 删除用户的同时删除用户的家目录
#           : -f => 强制删除用户(甚至当用户已经登陆Linux系统此选项任然生效)
CMDTest_userdel_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	# 必须在useradd测试之后

	return ${TPASS}
}


## TODO     : 131 - usermod 修改用户账号
#  Function : -c => 修改用户帐号的备注文字
#           : -f => 修改在密码过期后多少天即关闭该帐号
#           : --help => 显示帮助信息
CMDTest_usermod_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	# 必须在useradd测试之后

	return ${TPASS}
}


## TODO     : 132 - wc 计算字数
#  Function : -c => 只显示字节数
#           : -m => 只显示字符数
#           : -l => 只显示行数
CMDTest_wc_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	echo "helloworld" | ${cmd} -c > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	echo "helloworld" | ${cmd} -m > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	echo "helloworld" | ${cmd} -l > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 133 - xargs 构造参数列表并且运行命令
#  Function : -t => 先打印命令，然后再执行 
#           : -s => 命令行的最大字符数，指的是 xargs 后面那个命令的最大命令行字符数
#           : -n => 后面加次数，表示命令在执行的时候一次用的argument的个数，默认是用所有的
CMDTest_xargs_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	echo "hello*world" | ${cmd} -s 77 -n 221 -d* echo > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


## TODO     : 134 - zcat 将压缩文件解压到标准输出
#  Function : --version => 显示版本信息
#           : --help => 显示帮助信息
#           : -L => 显示gzip的版本并且退出
CMDTest_zcat_GJB(){
	# Determine if the parameters are correct
	if [ $# -ne 1 ];then
		echo "Parameters error"
		return ${TONF}
	fi
	local cmd="$1"

	${cmd} --version > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} --help > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}
	${cmd} -L > /dev/null
	[ $? -ne 0 ] && return ${TFAIL}

	return ${TPASS}
}


### TODO     :  - 
##  Function :  
#CMDTest_a_GJB(){
#	# Determine if the parameters are correct
#	if [ $# -ne 1 ];then
#		echo "Parameters error"
#		return ${TONF}
#	fi
#	local cmd="$1"
#
#	${cmd}
#	[ $? -ne 0 ] && return ${TFAIL}
#
#	return ${TCONF}
#}


#----------------------------------------------------------------------------#


## TODO: 使用ctrl+c退出
#
CMDOnCtrlC_GJB(){
	echo "正在优雅的退出..."
	CMDClean_GJB

	exit ${TCONF}
}


## TODO : Init
#
CMDInit_GJB(){
	# root!
	if [ $(id -u) -ne 0 ];then
		echo "Operation not permitted"
		return ${TCONF}
	fi

	# Determine if there is a test root directory
	if [ ! -d "${CMDTESTROOT_GJB}" ];then
		echo "Init Error : Can't found ${CMDTESTROOT_GJB}"
		return ${TCONF}
	fi

	# Determine if there is a test directory
	if [ -d "${CMDTESTDIR_GJB}" ];then
		rm -rf ${CMDTESTDIR_GJB}
		if [ $? -ne 0 ];then
			 echo "${CMDTESTDIR_GJB} : Failed to rm directory"
			 return ${TCONF}
		fi
	fi
	
	mkdir -p ${CMDTESTDIR_GJB}
	if [ $? -ne 0 ];then
		 echo "${CMDTESTDIR_GJB} : Failed to create directory"
		 return ${TCONF}
	fi

	# 信号捕获ctrl+c
	trap 'CMDOnCtrlC_GJB' INT

	return ${TPASS}
}


## TODO : Empty directory
#
CMDCleanEmpty_GJB(){
	if [ -d "${CMDTESTDIR_GJB}" ];then
		rm -rf ${CMDTESTDIR_GJB}/*
		if [ $? -ne 0 ];then
			 echo "${CMDTESTDIR_GJB} : Failed to rm ${CMDTESTDIR_GJB}/*"
			 return ${TCONF}
		fi
	fi
	
	return ${TPASS}
}


## TODO : delete directory
#
CMDClean_GJB(){
	if [ -d "${CMDTESTDIR_GJB}" ];then
		rm -rf ${CMDTESTDIR_GJB}
		if [ $? -ne 0 ];then
			 echo "${CMDTESTDIR_GJB} : Failed to rm directory"
			 return ${TCONF}
		fi
	fi
}


## TODO : Return value analysis
#    In : $1 => string log
#         $2 => False:Do not exit
CMDRetAna_GJB(){
	local ret=$?
	local strlog="$1"

	local flag=""
	if [ $# -eq 2 ];then
		flag="$2"
	fi

	if [ $ret -eq ${TPASS} ];then
		echo "[ TPASS ] ${strlog}"
	elif [ $ret -eq ${TFAIL} ];then
		echo "[ TFAIL ] ${strlog}"
		CMDRETFLAG_GJB=${ret}
		if [ "Z${flag}" != "ZFalse" ];then
			CMDClean_GJB
			exit ${CMDRETFLAG_GJB}
		fi
	else
		echo "[ TCONF ] ${strlog}"
		CMDRETFLAG_GJB=${TCONF}
		if [ "Z${flag}" != "ZFalse" ];then
			CMDClean_GJB
			exit ${CMDRETFLAG_GJB}
		fi
	fi
}


## TODO : Main
#
CMDMain_GJB(){
	CMDInit_GJB
	CMDRetAna_GJB "Init"

	CMDExistTest_GJB
	CMDRetAna_GJB "Commands exists" "False"

	local index=0
	local border=0
	let border=${#CMDEXISTS_GJB[@]}-1

	for index in $(seq 1 ${border})
	do
		# Run test
		CMDRunTest_GJB ${CMDEXISTS_GJB[${index}]}
		#CMDRetAna_GJB "${CMDEXISTS_GJB[${index}]}" "False"
		CMDRetAna_GJB "[ $index ] : ${CMDEXISTS_GJB[${index}]}"

		CMDCleanEmpty_GJB
	done

	CMDClean_GJB
	CMDRetAna_GJB "Clean ${CMDTESTDIR_GJB}"
}

CMDMain_GJB
exit ${CMDRETFLAG_GJB}
