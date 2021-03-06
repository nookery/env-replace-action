#!/bin/bash

#--------------------------------------------------
#  输出关键参数
#--------------------------------------------------
#

echo -e "\033[32m---- 参数 ----\033[0m"

echo -e "待处理的文件：$INPUT_TARGET"

if [ "$INPUT_REMOTE_SCRIPT" ];then
  echo -e "变量脚本文件：$INPUT_USERNAME@$INPUT_HOST:$INPUT_REMOTE_SCRIPT"
fi

echo -e "\033[32m----\033[0m \r\n"

#--------------------------------------------------
#  从远程服务器下载变量配置脚本
#--------------------------------------------------
#

if [ "$INPUT_REMOTE_SCRIPT" ];then
  echo -e "\033[32m---- 从远程服务器下载变量配置脚本 ----\033[0m"

  # 复制私钥到本地
  echo "$INPUT_KEY" > key
  chmod 400 key

  if [ "$INPUT_KEY" == ""];then
    echo -e "\033[5;31m---- 连接远程服务器的私钥为空 \r\n \033[0m"
    exit 1
  fi

  # 从远程服务器下载变量配置脚本
  scp -i key -o "StrictHostKeyChecking no" -P "$INPUT_PORT" "$INPUT_USERNAME"@"$INPUT_HOST":"$INPUT_REMOTE_SCRIPT" ./script

  # 执行变量配置脚本
  source ./script
  echo -e "\033[32m----\033[0m \r\n"
else
  echo '' > key
  echo '' > ./script
fi

#--------------------------------------------------
#  将所有变量存入文件，用于下文判断变量是否存在
#--------------------------------------------------
#

env > env.txt
cat script env.txt > variables.txt

#
#--------------------------------------------------
#  将.env文件中的{{ABC}}替换成环境变量ABC的值
#--------------------------------------------------
#

echo -e "\033[32m---- 将${INPUT_TARGET}文件中的环境变量替换成配置的值 ----\033[0m"

# 找出配置文件中的所有的环境变量并存入数组中
# shellcheck disable=SC2046
# shellcheck disable=SC2062
keys=$(eval echo $(sed -n "s/{{\([A-Z0-9a-z_]\{1,200\}\)}}$/\1/p" "$INPUT_TARGET" | grep -o -e =.*|awk -F = '{ print $2 }'));
# shellcheck disable=SC2206
array=(${keys// / })

# 逐个替换
# shellcheck disable=SC2068
hasError=false
for key in ${array[@]}; do
    eval value=\$"${key}"
    # 转义value中的特殊字符（比如&符号，不转义会被下面的sed命令识别成特殊符号）
    value=${value/\&/\\&}

    if grep -q "^$key=" variables.txt ; then
      # 找出配置文件中的环境变量，并替换，请根据实际的格式修改这里的表达式
      echo -e "- 替换${key}"
      sed -i "s/{{$key}}/$value/" "$INPUT_TARGET"
    else
      echo -e "\033[5;31m- $key的值未配置 \033[0m"
      hasError=true
    fi
done

if [ $hasError == true ];then
  echo -e "\033[5;31m---- 部分变量值未配置 \r\n \033[0m"
  exit 1
fi

echo -e "\033[32m---- 环境变量替换处理完成\r\n\033[0m"

#echo -e "\033[32m---- $INPUT_TARGET 文件内容 ----\033[0m"
#cat "$INPUT_TARGET"
#echo -e "\033[32m----\033[0m \r\n"

#
#--------------------------------------------------
#  清理
#--------------------------------------------------
#

cat /dev/null > ~/.bash_history
rm key
rm env.txt
rm variables.txt
rm script
