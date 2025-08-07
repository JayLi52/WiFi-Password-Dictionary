#!/bin/bash

# WiFi密码暴力破解脚本
# 使用方法: ./crack_wifi.sh [cap文件] [字典文件]

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用sudo运行此脚本${NC}"
    echo "使用方法: sudo ./crack_wifi.sh"
    exit 1
fi

# 检查aircrack-ng是否安装
if ! command -v aircrack-ng &> /dev/null; then
    echo -e "${RED}错误: 未找到aircrack-ng，请先安装${NC}"
    echo "macOS安装命令: brew install aircrack-ng"
    exit 1
fi

# 默认参数
CAP_FILE="work-01.cap"
DICT_DIR="dictionaries"

# 如果提供了参数，使用提供的参数
if [ $# -ge 1 ]; then
    CAP_FILE="$1"
fi

if [ $# -ge 2 ]; then
    WORDLIST="$2"
else
    # 如果没有指定字典，使用字典文件夹中的第一个字典
    if [ -d "$DICT_DIR" ]; then
        FIRST_DICT=$(ls "$DICT_DIR"/*.txt 2>/dev/null | head -1)
        if [ -n "$FIRST_DICT" ]; then
            WORDLIST="$FIRST_DICT"
        else
            echo -e "${RED}错误: 字典文件夹中没有找到字典文件${NC}"
            exit 1
        fi
    else
        echo -e "${RED}错误: 字典文件夹不存在${NC}"
        exit 1
    fi
fi

# 检查cap文件是否存在
if [ ! -f "$CAP_FILE" ]; then
    echo -e "${RED}错误: 找不到cap文件 '$CAP_FILE'${NC}"
    echo "可用的cap文件:"
    ls -la *.cap 2>/dev/null || echo "当前目录没有cap文件"
    exit 1
fi

# 检查字典文件是否存在
if [ ! -f "$WORDLIST" ]; then
    echo -e "${RED}错误: 找不到字典文件 '$WORDLIST'${NC}"
    echo "可用的字典文件:"
    ls -la *.txt 2>/dev/null | grep -E "(字典|wordlist|password)" || echo "当前目录没有字典文件"
    exit 1
fi

echo -e "${BLUE}=== WiFi密码暴力破解工具 ===${NC}"
echo -e "${YELLOW}目标文件: ${CAP_FILE}${NC}"
echo -e "${YELLOW}字典文件: ${WORDLIST}${NC}"
echo -e "${YELLOW}开始时间: $(date)${NC}"
echo ""

# 显示cap文件信息
echo -e "${BLUE}分析cap文件...${NC}"
aircrack-ng "$CAP_FILE"

echo ""
echo -e "${GREEN}开始暴力破解...${NC}"
echo -e "${YELLOW}按 Ctrl+C 可以停止破解过程${NC}"
echo ""

# 开始破解
aircrack-ng "$CAP_FILE" -w "$WORDLIST"

echo ""
echo -e "${BLUE}=== 破解完成 ===${NC}"
echo -e "${YELLOW}结束时间: $(date)${NC}" 