#!/bin/bash

# 进入脚本所在目录（假设和 batch_crack.sh 在同一目录）
cd "$(dirname "$0")"

# 遍历 hands 目录下所有 .cap 文件
for capfile in ./hands/*.cap; do
    if [ -f "$capfile" ]; then
        echo "正在批量破解: $capfile"
        sudo ./batch_crack.sh "$capfile"
    fi
done