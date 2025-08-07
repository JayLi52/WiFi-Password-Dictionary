#!/bin/bash

# 显示破解结果统计脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== WiFi密码破解结果统计 ===${NC}"
echo ""

# 查找最新的结果目录或单个结果文件
LATEST_RESULT_DIR=$(ls -td crack_results_* 2>/dev/null | head -1)
SINGLE_RESULT_FILE=$(ls -t crack_*.log 2>/dev/null | head -1)

if [ -z "$LATEST_RESULT_DIR" ] && [ -z "$SINGLE_RESULT_FILE" ]; then
    echo -e "${RED}未找到破解结果${NC}"
    echo "请先运行破解脚本"
    exit 1
fi

# 确定是批量结果还是单个结果
if [ -n "$LATEST_RESULT_DIR" ]; then
    RESULT_TYPE="batch"
    RESULT_PATH="$LATEST_RESULT_DIR"
else
    RESULT_TYPE="single"
    RESULT_PATH="."
fi

if [ "$RESULT_TYPE" = "batch" ]; then
    echo -e "${YELLOW}批量破解结果目录: $LATEST_RESULT_DIR${NC}"
else
    echo -e "${YELLOW}单次破解结果文件: $SINGLE_RESULT_FILE${NC}"
fi
echo ""

# 统计信息
TOTAL_DICTS=0
SUCCESSFUL_DICTS=0
TOTAL_KEYS_TESTED=0

echo -e "${PURPLE}破解结果详情:${NC}"
echo "========================================"

if [ "$RESULT_TYPE" = "batch" ]; then
    # 批量结果
    for log_file in "$RESULT_PATH"/crack_*.log; do
    if [ -f "$log_file" ]; then
        dict_name=$(basename "$log_file" .log | sed 's/crack_//')
        TOTAL_DICTS=$((TOTAL_DICTS + 1))
        
        # 检查是否成功
        if grep -q "KEY NOT FOUND" "$log_file"; then
            status="${RED}失败${NC}"
            # 提取测试的密钥数量
            keys_tested=$(grep -o '[0-9]\+/[0-9]\+ keys tested' "$log_file" | head -1 | cut -d'/' -f2 | cut -d' ' -f1)
            if [ -n "$keys_tested" ]; then
                TOTAL_KEYS_TESTED=$((TOTAL_KEYS_TESTED + keys_tested))
            fi
        else
            status="${GREEN}成功${NC}"
            SUCCESSFUL_DICTS=$((SUCCESSFUL_DICTS + 1))
        fi
        
        # 提取文件大小
        file_size=$(ls -lh "$log_file" | awk '{print $5}')
        
        printf "%-30s %-10s %-10s\n" "$dict_name" "$status" "$file_size"
    fi
done
else
    # 单次结果
    if [ -f "$SINGLE_RESULT_FILE" ]; then
        dict_name=$(basename "$SINGLE_RESULT_FILE" .log | sed 's/crack_//')
        TOTAL_DICTS=1
        
        # 检查是否成功
        if grep -q "KEY NOT FOUND" "$SINGLE_RESULT_FILE"; then
            status="${RED}失败${NC}"
            # 提取测试的密钥数量
            keys_tested=$(grep -o '[0-9]\+/[0-9]\+ keys tested' "$SINGLE_RESULT_FILE" | head -1 | cut -d'/' -f2 | cut -d' ' -f1)
            if [ -n "$keys_tested" ]; then
                TOTAL_KEYS_TESTED=$keys_tested
            fi
        else
            status="${GREEN}成功${NC}"
            SUCCESSFUL_DICTS=1
        fi
        
        # 提取文件大小
        file_size=$(ls -lh "$SINGLE_RESULT_FILE" | awk '{print $5}')
        
        printf "%-30s %-10s %-10s\n" "$dict_name" "$status" "$file_size"
    fi
fi

echo "========================================"
echo ""
echo -e "${BLUE}统计摘要:${NC}"
echo -e "总字典数量: ${YELLOW}$TOTAL_DICTS${NC}"
echo -e "成功破解: ${GREEN}$SUCCESSFUL_DICTS${NC}"
echo -e "失败破解: ${RED}$((TOTAL_DICTS - SUCCESSFUL_DICTS))${NC}"
echo -e "总测试密钥数: ${YELLOW}$TOTAL_KEYS_TESTED${NC}"

if [ $SUCCESSFUL_DICTS -gt 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 恭喜！成功找到密码！${NC}"
    echo "请查看对应的日志文件获取详细信息。"
else
    echo ""
    echo -e "${RED}❌ 所有字典都未能破解密码${NC}"
    echo "建议："
    echo "1. 尝试更大的字典文件"
    echo "2. 检查cap文件是否包含有效的握手数据"
    echo "3. 考虑使用其他破解方法"
fi

echo ""
if [ "$RESULT_TYPE" = "batch" ]; then
    echo -e "${YELLOW}详细日志文件位置: $LATEST_RESULT_DIR${NC}"
else
    echo -e "${YELLOW}详细日志文件位置: $SINGLE_RESULT_FILE${NC}"
fi 