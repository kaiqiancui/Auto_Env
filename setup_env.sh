#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始自动配置环境...${NC}"

# 1. 下载Anaconda (如果尚未下载)
cd ~/Downloads
if [ ! -f "Anaconda3-2023.09-0-Linux-x86_64.sh" ]; then
    echo -e "${YELLOW}下载Anaconda安装包...${NC}"
    wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
fi

# 2. 安装Anaconda
echo -e "${YELLOW}安装Anaconda...${NC}"
bash Anaconda3-2023.09-0-Linux-x86_64.sh -b -p $HOME/anaconda3

# 3. 配置环境变量
echo -e "${YELLOW}配置环境变量...${NC}"
if ! grep -q "anaconda3" ~/.bashrc; then
    echo '# Anaconda配置' >> ~/.bashrc
    echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
    echo 'alias ca="conda activate"' >> ~/.bashrc
    echo 'alias cda="conda deactivate"' >> ~/.bashrc
    echo 'alias cl="conda list"' >> ~/.bashrc
    echo 'alias ce="conda env list"' >> ~/.bashrc
fi

# 4. 应用环境变量
echo -e "${YELLOW}应用环境变量...${NC}"
source ~/.bashrc
source $HOME/anaconda3/bin/activate

# 5. 配置conda镜像源
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

# 6. 创建虚拟环境
echo -e "${YELLOW}创建虚拟环境 try...${NC}"
conda create -y -n try python=3.12

# 7. 配置pip镜像源
echo -e "${YELLOW}配置pip镜像源...${NC}"
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

# 8. 激活环境并安装PyTorch
echo -e "${YELLOW}激活环境并安装PyTorch...${NC}"
source $HOME/anaconda3/bin/activate try
pip install torch torchvision torchaudio

# 9. 创建requirements.txt文件
echo -e "${YELLOW}创建requirements.txt文件...${NC}"
cd ~
cat > requirements.txt << EOF
# 基础科学计算包
numpy>=1.21.0
scipy>=1.7.0
pandas>=1.3.0
matplotlib>=3.4.0
seaborn>=0.11.0

# 机器学习工具
scikit-learn>=1.0.0
opencv-python>=4.5.0
pillow>=8.0.0

# 实验管理和可视化
tensorboard>=2.8.0
wandb>=0.12.0

# Jupyter相关
jupyter>=1.0.0
jupyterlab>=3.0.0
ipywidgets>=7.6.0

# 工具包
tqdm>=4.62.0
pyyaml>=5.4.0
EOF

# 10. 安装其他依赖
echo -e "${YELLOW}安装其他依赖...${NC}"
pip install -r requirements.txt

echo -e "${GREEN}环境配置完成!${NC}"
echo -e "${GREEN}请运行 'source ~/.bashrc' 以应用所有更改${NC}"
echo -e "${GREEN}然后使用 'conda activate try' 激活环境${NC}"
