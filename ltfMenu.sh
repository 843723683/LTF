#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Filename :   ltfMenu.sh
# Version  :   1.0
# Date     :   2020/05/09
# Author   :   Lz
# Email    :   lz843723683@gmail.com
# History  :     
#              Version 1.0, 2020/05/09
# Function :   图形化ltf测试  
#      Out :        
#              0 => TPASS
#              1 => TFAIL
#              other=> TCONF
# ----------------------------------------------------------------------


## TODO : 初始化操作
#
Init_LTFMenu(){
	# 进入LTF根目录
	cd `dirname $0`

	# LTF根目录
	LTFMENU_ROOT=`pwd`

	# LTF config目录
	LTFMENU_CONFIG_ROOT="${LTFMENU_ROOT}/config"
	# LTF xml config 目录
	LTFMENU_XMLCONFIG_ROOT="${LTFMENU_CONFIG_ROOT}/xml"
	
	# xml说明文件名
	CONFIG_XML_README="readme_xml"

        # Benchmark 脚本文件路径
        CONFIG_BENCHMARK_PATH="${LTFMENU_ROOT}/testcases/Benchmarks"
	if [ ! -d "${CONFIG_BENCHMARK_PATH}" ];then
		echo "Can't found ${CONFIG_BENCHMARK_PATH}"	
		exit 1
	fi

	# read超时退出
	TMOUT_LTFMENU=120

	# 测试项对应的xml文件路径
	testCasePathArr_menu=()
	# 测试项名称
	testCaseNameArr_menu=()
	# 测试项描述
	testCaseLogArr_menu=()

	# 主菜单用户输入
	UserInputArr=()
	# 安装测试标识
	INSTALLFLAG="false"

	# 是否生成新XML
	NEWXML_MENU="false"
	# 新XML文件名
	NEWXMLFILENAME_MENU=""
}


## TODO : 解析CONFIG_XML_README说明文件
#
ReadmeParse_LTFMenu(){
	# 数组计数
	local num=0

	# xml描述文件路径	
	local readmelogpath=""
	local readmelog=""
	# xml 整体路径
	local xmlpath=""
	# 存储xml文件的最后一级目录
	local xmldir=""
	for xmlpath in `find ${LTFMENU_XMLCONFIG_ROOT} -type f | sort | grep "\.xml$"`	
	do
		xmldir="${LTFMENU_XMLCONFIG_ROOT##*/}"
		# 获取xml文件路径
		testCasePathArr_menu[$num]=${xmlpath#*${xmldir}/}
		
		# 判断是否存在目录标识"/"
		echo "${testCasePathArr_menu[$num]}" | grep -q "/"
		if [ $? -eq 0 ];then
			# 存在目录
			readmelogpath="${LTFMENU_XMLCONFIG_ROOT}/${testCasePathArr_menu[$num]%/*}/${CONFIG_XML_README}"
		else
			# 不存在目录
			readmelogpath="${LTFMENU_XMLCONFIG_ROOT}/${CONFIG_XML_README}"
		fi
		
		# 判断是否存在xml说明文件
		if [ -f "${readmelogpath}" ];then
			# 存在xml说明文件
			readmelog=`cat ${readmelogpath} | grep ${testCasePathArr_menu[$num]}`
		else
			# 不存在xml说明文件
			readmelog=""
		fi

		# 判断是否有 xml文件是否有对应描述
		if [ "Z${readmelog}" != "Z" ];then
		# 说明文件中存在对应条目
			# 获取xml对应专业名称
			testCaseNameArr_menu[$num]=$(echo ${readmelog} | cut -d ":" -f 2)
			# 获取xml对应描述
			testCaseLogArr_menu[$num]=$(echo ${readmelog} | cut -d ":" -f 3)
		else
		# 说明文件中不存在对应条目
			testCaseNameArr_menu[$num]=${testCasePathArr_menu[$num]%*.xml}
			testCaseLogArr_menu[$num]="#####"
		fi

		let num=num+1
	done
}


## TODO : 打印LOG 
#     In: $1 => 右移倍数,可以不提供
#
LogUsage_LTFMenu(){
	local rshift="\t\t"
	local rshiftreal="\t"
	if [ $# -eq 1 ];then
		local index=0
		for i in `seq 2 $1`
		do
			local rshiftreal="${rshiftreal}${rshift}"
		done
	fi

        printf " \n\
${rshiftreal}#       #######   ######\n \
${rshiftreal}#          #      #\n \
${rshiftreal}#          #      #####\n \
${rshiftreal}#          #      #\n \
${rshiftreal}#          #      #\n \
${rshiftreal}######     #      #\n\n"
}


## TODO : 打印测试项(new)
#
TestCaseUsageNew_LTFMenu(){
	# 基础参数
	# 一列最多15项
	local rowmax=15
	which stty &>/dev/null
	if [ $? -eq 0 ];then
		let rowmax=$(stty size | awk '{print $1}')-20
	else
		rowmax=15
	fi

	# 总共测试项
	local itemnum=${#testCaseNameArr_menu[@]}
	# 总共列数
	let local colmax=${itemnum}/${rowmax}
	let local colmax_remainder=${itemnum}%${rowmax}
	if [ ${colmax_remainder} -gt 1 ];then
		let colmax=colmax+1
	fi
	
	# 基础格式
	# 格式
	local fmt_1="%-s"
	local fmt_2="%s %s %s"
	# 参数
	local prmt_1="-------------------------------------"
	local prmt_2="No Test-Item Description"
	local prmt_3="-- --------- -----------"

	# 打印格式
	local fmtreal_1="${fmt_1}"
	local fmtreal_2="${fmt_2}"
	local prmtreal_1="${prmt_1}"
	local prmtreal_2="${prmt_2}"
	local prmtreal_3="${prmt_3}"
	local prmtreal_4=""

	local index=0
	for index in $(seq 2 ${colmax})
	do
		fmtreal_2="$fmtreal_2 $fmt_2"
		prmtreal_1="${prmtreal_1}${prmt_1}"
		prmtreal_2="${prmtreal_2} ${prmt_2}"
		prmtreal_3="${prmtreal_3} ${prmt_3}"
	done

	# 打印LOG
	LogUsage_LTFMenu $colmax

	# 打印界面
	local ltfuserfile="/tmp/ltfuserfile"
	[ -f "$ltfuserfile" ] && rm $ltfuserfile
	printf "${fmtreal_1}\n" $prmtreal_1
	printf "${fmtreal_2}\n" $prmtreal_2 > ${ltfuserfile}
	printf "${fmtreal_2}\n" $prmtreal_3 >> ${ltfuserfile}

	# 打印测试项
	local testcasename=""
	local num=0
	local tmpnum=0
	for testcasename in ${testCaseNameArr_menu[@]}
	do
		# 判断是否大于最大行数
		if [ $num -ge $rowmax ];then
			break
		fi

		for index in `seq 1 $colmax`
		do
			if [ $index -eq 1 ];then
				prmtreal_4="$num ${testcasename} ${testCaseLogArr_menu[$num]}"
			else
				let tmpnum=num+${index}*${rowmax}-${rowmax}
				if [ $tmpnum -ge $itemnum ];then
					continue
				fi
				prmtreal_4="$prmtreal_4 $tmpnum ${testCaseNameArr_menu[$tmpnum]} ${testCaseLogArr_menu[$tmpnum]}"
			fi
		done

		printf "${fmtreal_2}\n" ${prmtreal_4} >> ${ltfuserfile}
		let num=num+1
	done

	# 打印排序测试项
	column -t ${ltfuserfile}
	[ -f "$ltfuserfile" ] && rm $ltfuserfile

	local rshirft="\t\t"
	local rshirftreal=""
	for index in `seq 2 $colmax`
	do
		rshirftreal="${rshirftreal}${rshirft}"
	done

	# 选择benchmarks	
	printf "\n${rshirftreal}%-2s : %-20s %-20s\n" "s" "Select Benchmark" "自定义性能工具"

	# 退出界面
	printf "${rshirftreal}%-2s : %-20s %-20s\n" "q" "Quit" "退出"
	printf "${fmtreal_1}\n" $prmtreal_1
}


## TODO : 打印测试项(old)
#
TestCaseUsageOld_LTFMenu(){
	local testcasename=""
	local num=0

	printf "%-s\n" "---------------------------------------------------"
	printf "\t%-2s   %-20s %-20s\n" "No" "Test Item" "Description"
	printf "\t%-2s   %-20s %-20s\n" "--" "---------" "-----------"
	# 打印测试项
	for testcasename in ${testCaseNameArr_menu[@]}
	do
		printf "\t%-2s : %-20s %-20s\n" "$num" "${testcasename}" "${testCaseLogArr_menu[$num]}"
		let num=num+1
	done

	# 选择benchmarks	
	printf "\n\t%-2s : %-20s %-20s\n" "s" "Select Benchmark" "自定义性能工具"

	# 退出界面
	printf "\t%-2s : %-20s %-20s\n" "q" "Quit" "退出"
	printf "%-s\n" "---------------------------------------------------"
}


## TODO : 打印界面 
#
Usage_LTFMenu(){
	# 清屏
	clear

	# 打印测试项
	which column &>/dev/null
	if [ $? -eq 0 ];then
		TestCaseUsageNew_LTFMenu
	else
		# 打印LOG
		LogUsage_LTFMenu

		TestCaseUsageOld_LTFMenu
	fi
}


## TODO : 用户主界面，读取用户输入, 必须使用空格作为分隔符,赋值UserInputArr变量
#    In : $1 => outtime
#   Out : 2 => 新增xml文件
Read_MainPage_LTFMenu(){
	# 测试项数量
        local testcasenum=${#testCaseNameArr_menu[@]}
	# 等待时间
	local outtime="$1"

        # 必须使用空格作为分隔符
        printf "%s\n" "Separate multiple items with spaces (e.g. 1 2)"

        # 临时变量，测试项数量减1
        let local tmpindex=$testcasenum-1
        # 输入参数
        local userinput=""
        local num=""
        local flag="true"
        # 无限循环
        while :
        do
		# 读取输入
		if read -t ${outtime} -p "Please Enter selection [0-${tmpindex}] -> " userinput ;then
			# 转化为数组
			UserInputArr=($userinput)
		else
			# 超时退出
			printf "\nInput time out\n"
			exit 1
		fi
	
		# 判断输入有效性
		for num in ${UserInputArr[@]}
		do
			# 判断用户输入是否属于常规序列号中
			if [ $num -lt ${testcasenum} -a $num -gt 0 ] 2>/dev/null ;then
				# 用户输入正常
				true
			elif [ $num -eq 0 ] 2>/dev/null ;then
				# 用户输入0,全量测试,判断是否只输入一个字符
				if [ ${#UserInputArr[@]} -ne 1 ];then
					printf "Warn: 0 and other options cannot be set at the same time\n"
					flag="false"
				fi
			elif [ "$num" == "s" ];then
				# 新增xml文件
				SelectBenchmark_LTFMenu ${TMOUT_LTFMENU}
				NEWXML_MENU="true"
				return 0	
			elif [ "$num" == "q" ];then
				# 判断是否为退出字符q
				printf "\n\n%s\n" "Quit"
				exit 0
			else
				# 非法输入
				printf "Error: Invalid entry.(%s)\n" "$num"
				flag="false"
			fi
		done

		if [ $flag == "false" ];then
			# 存在无效的输入
			flag="true"
			continue
		else
			# 输入成功，退出while循环
			break
		fi
	done
}


## TODO : 判断是否存在性能测试
#   Out : 
#         0 => 存在性能测试工具
#         1 => 不存在性能测试工具
EnableBenchmark_LTFMenu(){
	local num=""
        # Benchmark XML配置文件路径
        local benchmarkpath="${CONFIG_BENCHMARK_PATH}"

	for num in ${UserInputArr[@]}
	do
		if [ "Z${testCaseNameArr_menu[$num]}" == "ZBenchmarks" -o "Z${testCaseNameArr_menu[$num]}" == "ZAll-Test-Item" ];then
			# 存在性能测试
			return 0
		fi
		
		# 判断自建文件是否存在benchmark性能测试
		local filename=""
		local index=0
		for filename in `find ${benchmarkpath} -maxdepth 1 -type f`
		do
			# 判断是否用户选择的测试项中是否存在性能测试
			cat ${LTFMENU_XMLCONFIG_ROOT}/${testCasePathArr_menu[$num]} | grep -q "${filename##*/}"
			if [ $? -eq 0 ];then
				# 存在性能测试
				return 0
			fi

			let index=index+1
		done
	done
	
	# 不存在性能测试
	return 1
}


## TODO : 保存 benchmark XML
#    In : 用户选择的benchmark脚本名
SaveXml_LTFMenu(){
	local testcase="$1"
	local newxmlpath="${LTFMENU_XMLCONFIG_ROOT}/${NEWXMLFILENAME_MENU}"

	printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n" > ${newxmlpath}
	local tmpfile=
	for tmpfile in $testcase 
	do
		cat >>${newxmlpath} <<-EOF
        <TestCase>
                <CaseName>${tmpfile/%.sh}</CaseName>
                <CaseDir>Benchmarks</CaseDir>
                <CaseScript>${tmpfile}</CaseScript>
                <CaseRun>True</CaseRun>
        </TestCase>
	EOF
	done
	printf "<TestGroup>" >> ${newxmlpath}
	printf "</TestGroup>" >> ${newxmlpath}
}


## TODO : 读取benchmark XML保存文件名
#    In : $1 => outtime
GetXmlName_LTFMenu(){
	local outtime=$1
	local xmlname=""

        # 必须以xml结尾 
        printf "%s\n" "!!!Requiers : .xml end (e.g. test.xml)"

	while :
	do
		if read -t ${outtime} -p "Please enter the configuration file name -> " xmlname ;then
			true
		else
			# 超时退出
			printf "\nInput time out\n"
			exit 1
		fi
		
		# 判断是否已xml结尾
		echo $xmlname | grep -q "\.xml$"
		if [ $? -ne 0 ];then
			printf "Error: Invalid entry ($xmlname)\n"
			continue
		fi
		# 判断是否已经存在
		echo "${testCasePathArr_menu[@]}" | grep -q ${xmlname}
		if [ $? -eq 0 ];then
			# 存在相同的xml文件
			printf "Error: Filename repeat! ($xmlname)\n"
			continue
		else
			# 通过验证
			NEWXMLFILENAME_MENU=$xmlname
			break
		fi
	done
}


## TODO : 选择性能测试工具进行测试
#    In : $1 => outtime
SelectBenchmark_LTFMenu(){
	local outtime=$1
        # Benchmark XML配置文件路径
        local benchmarkpath="${CONFIG_BENCHMARK_PATH}"
	
	# benchmark界面
	clear
	LogUsage_LTFMenu
	printf "%-s\n" "---------------------------------------------------"
	printf "\t%-2s\t%-20s\n" "No" "Benchmark Test Suit"
	printf "\t%-2s\t%-20s\n" "--" "-------------------"

	local benchmarkfilearr=()
	local filename=""
	local num=0
	for filename in `find ${benchmarkpath} -maxdepth 1 -type f`
	do
		benchmarkfilearr[$num]="${filename##*/}"
		printf "\t%-2s:\t%-20s\n" "$num" "${benchmarkfilearr[$num]}"
		let num=num+1
	done
	
        # 必须使用空格作为分隔符
        printf "%s\n" "Separate multiple items with spaces (e.g. 1 2)"

        # 临时变量，测试项数量减1
        let local tmpindex=${#benchmarkfilearr[@]}-1
        # 输入参数
        local userinput=""
        local userinputarr=""
	local userbenchmarkarr=""
        local flag="true"
        # 无限循环
        while :
        do
		# 读取输入
		if read -t ${outtime} -p "Please Enter selection [0-${tmpindex}] -> " userinput ;then
			# 转化为数组
			userinputarr=($userinput)
		else
			# 超时退出
			printf "\nInput time out\n"
			exit 1
		fi

		# 判断输入正确性
		local tmpnum=0
		# 置为空
		userbenchmarkarr=""
		for userinput in ${userinputarr[@]}
		do
			if [ $userinput -ge 0 -a $userinput -lt ${#benchmarkfilearr[@]} ] 2>/dev/null ;then
				# 有效输入
				userbenchmarkarr[$tmpnum]="${benchmarkfilearr[$userinput]}"
				let tmpnum=$tmpnum+1
			else
				# 无效输入
				printf "Error: Invalid entry.(%s)\n" "$userinput"
				flag="false"
			fi
		done

		if [ $flag == "false" ];then
			# 存在无效的输入
			flag="true"
			continue
		else
			# 输入成功，退出while循环
			break
		fi
	done

	# 获取xml文件名
	GetXmlName_LTFMenu ${outtime}

	# 保存xml文件,这里必须用*，不能用@
	SaveXml_LTFMenu "${userbenchmarkarr[*]}"
}


## TODO : 设置是否只进行安装测试
#    In : $1 => outtime
SetInstallBenchmark_LTFMenu(){
	# 等待时间
	local outtime="$1"
	
	local flag="true"
	local installflag=""
	# 判断是否需要安装测试
	while :
	do
		# 读取输入
		if read -t ${outtime} -p "Benchmark only for installation testing [y/n] -> " installflag ;then
			if [ "Z$installflag" == "Zy" ];then
				# 只进行安装测试
				INSTALLFLAG="true"
			elif [ "Z$installflag" == "Zn" ];then
				INSTALLFLAG="false"
			else
				flag="false"	
			fi
		else
			# 超时退出
			printf "\nInput time out\n"
			exit 1
		fi
	
		if [ $flag == "false" ];then
			# 存在无效的输入
			flag="true"
			continue
		else
			# 输入成功，退出while循环
			break
		fi
	done
}


## TODO : 读取用户输入, 必须使用空格作为分隔符,赋值UserInputArr变量
#
Read_LTFMenu(){
	# 等待时间
	local outtime=${TMOUT_LTFMENU}
	
	# 主页面
	Read_MainPage_LTFMenu ${outtime}
	# 新增xml文件，直接退出，更新列表
	if [ ${NEWXML_MENU} == "true" ];then
		return 0
	fi
	
	# 判断是否存在性能测试
	EnableBenchmark_LTFMenu
	if [ $? -eq 0 ];then
	# 存在性能测试
		# 设置是否仅进行安装测试标签
		SetInstallBenchmark_LTFMenu ${outtime}
	fi
	
	return 0
}



## TODO : 运行LTF工具
#
RunLTF_LTFMenu(){
	# 清除屏幕
	clear

	local xmlpath=""
	local input=""
	for input in ${UserInputArr[@]}
	do
		# 判断是否为全量测试
		if [ "Z${testCaseNameArr_menu[$input]}" == "ZAll-Test-Item" ];then
			if [ "Z$INSTALLFLAG" == "Ztrue" ];then
				printf "Comand : ./Run.sh -a -i \n"
				./Run.sh -a -i
			else
				printf "Comand : ./Run.sh -a \n"
				./Run.sh -a
			fi
			return 0
		fi

		# 收集测试项
		if [ "Z$xmlpath" == "Z" ];then
			xmlpath="${testCasePathArr_menu[$input]}"
		else
			xmlpath="$xmlpath:${testCasePathArr_menu[$input]}"
		fi
	done

	# 运行指定测试
	if [ "Z$INSTALLFLAG" == "Ztrue" ];then
		printf "Command : ./Run.sh -f $xmlpath -i \n"
		./Run.sh -f  $xmlpath -i
	else
		printf "Command : ./Run.sh -f $xmlpath \n"
		./Run.sh -f  $xmlpath
	fi
}


## TODO : 主函数
#
Main_LTFMenu(){
	while :
	do
		# 初始化
		Init_LTFMenu

		# 解析config/readme文件
		ReadmeParse_LTFMenu

		# 用户界面
		Usage_LTFMenu

		# 读取用户输入
		Read_LTFMenu
		if [ ${NEWXML_MENU} == "true" ];then
			NEWXML_MENU="false"
		else
			#没有增加xml
			break
		fi
	done

	# 执行Run.sh文件
	RunLTF_LTFMenu
}

Main_LTFMenu
