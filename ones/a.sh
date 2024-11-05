#!/bin/bash

# 遍历当前目录下的所有文件
for file in *; do
    # 检查文件名中是否包含空格
    if [[ "$file" == *" "* ]]; then
        # 使用tr命令将空格替换为下划线
        new_name=$(echo "$file" | tr ' ' '_')
        # 重命名文件
        mv "$file" "$new_name"
        echo "Renamed '$file' to '$new_name'"
    fi
done