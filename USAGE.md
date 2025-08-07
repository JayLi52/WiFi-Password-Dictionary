# WiFi密码暴力破解工具使用说明

## 文件说明

### 脚本文件
- `crack_wifi.sh` - 单次破解脚本
- `batch_crack.sh` - 批量破解脚本（推荐使用）
- `show_results.sh` - 破解结果统计脚本
- `manage_dicts.sh` - 字典管理脚本

### 字典文件夹
- `dictionaries/` - 包含所有字典文件的文件夹
  - `默认常用字典.txt` - 常用密码字典（24KB，2494行）
  - `少量弱密码+常用单词字典.txt` - 弱密码+常用单词（23KB，2189行）
  - `弱密码精装版不含生日.txt` - 弱密码字典（147KB，15147行）
  - `英文单词字典合集.txt` - 英文单词字典（1.9MB）
  - `一位字母开头加生日数字的字典.txt` - 字母+生日组合（4.6MB）
  - `全1960-2014生日八位数字密码.txt` - 生日密码
  - `全十位数密码.txt` - 十位数字密码
  - `全部八位数字密码.txt` - 八位数字密码

### 抓包文件
- `work-01.cap` - WiFi握手包文件
- `work-02.cap` - WiFi握手包文件
- `work-03.cap` - WiFi握手包文件

## 使用方法

### 1. 单次破解（使用指定字典）
```bash
# 使用默认设置（work-01.cap + 字典文件夹中的第一个字典）
sudo ./crack_wifi.sh

# 指定cap文件和字典文件
sudo ./crack_wifi.sh work-03.cap dictionaries/英文单词字典合集.txt
```

### 2. 批量破解（推荐）
```bash
# 使用默认cap文件（work-01.cap）
sudo ./batch_crack.sh

# 指定cap文件
sudo ./batch_crack.sh work-03.cap
```

### 3. 查看破解结果
```bash
# 显示最新破解结果的统计信息
./show_results.sh
```

### 4. 管理字典文件
```bash
# 查看和管理字典文件
./manage_dicts.sh
```

批量破解会自动从 `dictionaries/` 文件夹中读取所有字典文件，按文件名排序进行破解。

**注意**：脚本会自动检测字典文件夹中的所有 `.txt` 文件，无需手动指定字典列表。

## 安装依赖

### macOS
```bash
# 安装Homebrew（如果未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装aircrack-ng
brew install aircrack-ng
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install aircrack-ng
```

## 注意事项

1. **需要root权限**：所有脚本都需要使用sudo运行
2. **时间消耗**：破解时间取决于字典大小和密码复杂度
3. **成功率**：成功率取决于目标WiFi密码是否在字典中
4. **合法使用**：仅用于测试自己的WiFi网络，请遵守当地法律法规

## 输出结果

- 单次破解：直接在终端显示结果
- 批量破解：结果保存在 `crack_results_YYYYMMDD_HHMMSS/` 目录中
- 每个字典的破解日志单独保存
- 成功破解时会显示密码

## 停止破解

按 `Ctrl+C` 可以随时停止破解过程。 