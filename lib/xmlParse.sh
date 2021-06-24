#!/bin/bash


## TODO: 一层解析XML
## In  : $1=>xml file
##

XMLParse(){
	itemName_xml=($(sed -n 's/.*<\/\(.*\)>/\1/p' $1 | sort | uniq))
	itemNum_xml=${#itemName_xml[*]}
		
	# 数组边界
	local border_xml=$((${itemNum_xml}-1))
	local index_xml=0
	for index_xml in `seq 0 ${border_xml}`
	do
		eval ${itemName_xml[${index_xml}]}="($(sed -n 's/.*>\(.*\)<\/'${itemName_xml[${index_xml}]}'>/\1/p' $1))"
	done

}

## TODO: 获取XML文件中Item（${1}）所包含的内容并且赋值给${2}
## In  : $1=> Item Name
##       $2=> 保存${1}所对应的内容（数组）
##
XMLGetItemContent(){
	eval $2="($(echo "$"{${1}[*]}))"
}

## TODO: 获取Item（{$1}）中个数并且赋值给${2}
## In  : $1=> 数组
##       $2=> 保存${1}数组中元素个数

XMLGetItemNum(){
	eval $2=$(echo "$"{"#"${1}[*]})
}

XMLUnsetup(){
	local border_xml=$((${itemNum_xml}-1))
	local index_xml=0
	for index_xml in `seq 0 ${border_xml}`
	do
		unset -v ${itemName_xml[${index_xml}]}
	done

	unset -v itemNum_xml
	unset -v itemName_xml
}
