#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始下载环境配置脚本...${NC}"

# 下载主脚本
curl -O https://raw.githubusercontent.com/你的用户名/你的仓库名/main/setup_env.sh

# 添加执行权限
chmod +x setup_env.sh

# 运行主脚本
./setup_env.sh

# 应用环境变量更改
echo -e "${GREEN}自动应用环境变量更改...${NC}"
source ~/.bashrc

