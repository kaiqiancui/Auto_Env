#!/bin/bash

# 在任何命令失败时立即退出
set -e

# --- 配置 ---
# 安装包文件名
ANACONDA_INSTALLER="Anaconda3-2024.02-1-Linux-x86_64.sh"
# Anaconda安装目录
INSTALL_DIR="$HOME/anaconda3"
# 虚拟环境名称
ENV_NAME="try"

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始自动配置环境...${NC}"

# 1. 下载Anaconda (如果尚未下载)
cd ~/Downloads
if [ ! -f "$ANACONDA_INSTALLER" ]; then
    echo -e "${YELLOW}下载Anaconda安装包: $ANACONDA_INSTALLER...${NC}"
    wget -c "https://repo.anaconda.com/archive/$ANACONDA_INSTALLER"
else
    echo -e "${GREEN}Anaconda安装包已存在，跳过下载。${NC}"
fi

# 2. 【关键】以非交互式模式静默安装Anaconda
echo -e "${YELLOW}正在安装Anaconda至 $INSTALL_DIR...${NC}"
# -b: Batch mode (非交互式)
# -p: Installation prefix (指定安装路径)
bash ./"$ANACONDA_INSTALLER" -b -p "$INSTALL_DIR"

# 3. 初始化conda环境，使其在当前脚本中可用
echo -e "${YELLOW}初始化conda环境...${NC}"
source "$INSTALL_DIR/bin/activate"
conda init bash

# 立即应用 ~/.bashrc 的更改到当前shell会话
echo -e "${YELLOW}应用环境变量...${NC}"
source ~/.bashrc

# 4. 配置conda镜像源 (清华源)
echo -e "${YELLOW}配置conda镜像源...${NC}"
cat > ~/.condarc << EOF
channels:
  - defaults
  - conda-forge
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
EOF

# 清理索引缓存以确保镜像源生效
conda clean -i -y

# 5. 创建并激活虚拟环境
echo -e "${YELLOW}创建虚拟环境 $ENV_NAME...${NC}"
conda create -y -n "$ENV_NAME" python=3.12

# 6. 配置pip镜像源
echo -e "${YELLOW}配置pip镜像源...${NC}"
# 使用conda run确保在正确的环境中执行
conda run -n "$ENV_NAME" python -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
conda run -n "$ENV_NAME" python -m pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn

# 7. 安装PyTorch
echo -e "${YELLOW}在环境 $ENV_NAME 中安装PyTorch...${NC}"
conda run -n "$ENV_NAME" pip install torch torchvision torchaudio

# 8. 创建requirements.txt文件
echo -e "${YELLOW}创建requirements.txt文件...${NC}"
cd ~
cat > requirements.txt << EOF
diffusers>=0.29.0
transformers>=4.42.0
accelerate>=0.31.0
safetensors>=0.4.0
xformers>=0.0.26
bitsandbytes>=0.43.0
invisible-watermark>=0.2.0
Pillow>=10.0.0
sentencepiece>=0.2.0
tensorboard>=2.8.0
wandb>=0.12.0
# Jupyter相关
jupyter
notebook
matplotlib
pyyaml
nvitop
EOF

# 9. 安装其他依赖
echo -e "${YELLOW}在环境 $ENV_NAME 中安装其他依赖...${NC}"
conda run -n "$ENV_NAME" pip install -r requirements.txt

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}环境配置完成!${NC}"
echo -e "${GREEN}然后使用 'conda activate $ENV_NAME' 来激活并开始使用新环境。${NC}"
echo -e "${GREEN}=====================================${NC}"