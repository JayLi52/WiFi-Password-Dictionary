#!/bin/bash

# 字典管理脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

DICT_DIR="dictionaries"

echo -e "${BLUE}=== WiFi字典管理工具 ===${NC}"
echo ""

# 检查字典文件夹是否存在
if [ ! -d "$DICT_DIR" ]; then
    echo -e "${RED}字典文件夹不存在，正在创建...${NC}"
    mkdir -p "$DICT_DIR"
    echo -e "${GREEN}字典文件夹已创建: $DICT_DIR${NC}"
    echo ""
fi

# 显示字典文件信息
echo -e "${PURPLE}当前字典文件列表:${NC}"
echo "========================================"

if [ -z "$(ls -A "$DICT_DIR"/*.txt 2>/dev/null)" ]; then
    echo -e "${YELLOW}字典文件夹为空${NC}"
    echo "请将字典文件（.txt格式）放入 $DICT_DIR 文件夹"
else
    total_files=0
    total_size=0
    total_lines=0
    
    for dict_file in "$DICT_DIR"/*.txt; do
        if [ -f "$dict_file" ]; then
            total_files=$((total_files + 1))
            file_size=$(stat -f%z "$dict_file" 2>/dev/null || stat -c%s "$dict_file" 2>/dev/null)
            total_size=$((total_size + file_size))
            
            # 计算行数（密码数量）
            line_count=$(wc -l < "$dict_file" 2>/dev/null || echo "0")
            total_lines=$((total_lines + line_count))
            
            # 格式化文件大小
            if [ $file_size -gt 1048576 ]; then
                size_str=$(echo "scale=1; $file_size/1048576" | bc -l 2>/dev/null || echo "0")"MB"
            elif [ $file_size -gt 1024 ]; then
                size_str=$(echo "scale=1; $file_size/1024" | bc -l 2>/dev/null || echo "0")"KB"
            else
                size_str="${file_size}B"
            fi
            
            printf "%-35s %-10s %-10s\n" "$(basename "$dict_file")" "$size_str" "${line_count}行"
        fi
    done
    
    echo "========================================"
    echo -e "${BLUE}统计信息:${NC}"
    echo -e "字典文件数量: ${YELLOW}$total_files${NC}"
    echo -e "总文件大小: ${YELLOW}$(echo "scale=1; $total_size/1048576" | bc -l 2>/dev/null || echo "0")MB${NC}"
    echo -e "总密码数量: ${YELLOW}$total_lines${NC}"
fi

echo ""
echo -e "${PURPLE}操作选项:${NC}"
echo "1. 添加新字典文件到 $DICT_DIR 文件夹"
echo "2. 查看字典文件内容预览"
echo "3. 删除字典文件"
echo "4. 退出"

read -p "请选择操作 (1-4): " choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}请将字典文件复制到 $DICT_DIR 文件夹${NC}"
        echo "支持的格式: .txt"
        echo "示例: cp your_dict.txt $DICT_DIR/"
        ;;
    2)
        echo ""
        read -p "请输入要预览的字典文件名: " preview_file
        if [ -f "$DICT_DIR/$preview_file" ]; then
            echo -e "${GREEN}文件前10行内容:${NC}"
            echo "========================================"
            head -10 "$DICT_DIR/$preview_file"
            echo "========================================"
        else
            echo -e "${RED}文件不存在: $DICT_DIR/$preview_file${NC}"
        fi
        ;;
    3)
        echo ""
        read -p "请输入要删除的字典文件名: " delete_file
        if [ -f "$DICT_DIR/$delete_file" ]; then
            read -p "确认删除 $delete_file? (y/N): " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                rm "$DICT_DIR/$delete_file"
                echo -e "${GREEN}文件已删除: $delete_file${NC}"
            else
                echo -e "${YELLOW}取消删除${NC}"
            fi
        else
            echo -e "${RED}文件不存在: $DICT_DIR/$delete_file${NC}"
        fi
        ;;
    4)
        echo -e "${GREEN}退出字典管理工具${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}无效选择${NC}"
        ;;
esac 