#!/bin/bash

# AutoFigure-Edit 一键部署脚本
# 用法: ./deploy.sh

set -e  # 遇到错误立即退出

echo "========================================="
echo "AutoFigure-Edit 部署脚本"
echo "========================================="

# 检查 Python 版本
echo ""
echo "检查 Python 版本..."
if ! command -v python3.12 &> /dev/null; then
    echo "❌ 错误: 需要 Python 3.12+，请先安装"
    echo "Ubuntu: sudo apt install python3.12 python3.12-venv"
    exit 1
fi

PYTHON_VERSION=$(python3.12 --version | awk '{print $2}')
echo "✓ Python 版本: $PYTHON_VERSION"

# 检查 CUDA
echo ""
echo "检查 CUDA..."
if command -v nvidia-smi &> /dev/null; then
    CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $9}')
    echo "✓ CUDA 版本: $CUDA_VERSION"
else
    echo "⚠️  警告: 未检测到 NVIDIA GPU，SAM3 需要 GPU 支持"
    read -p "是否继续安装？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 创建虚拟环境
echo ""
echo "创建 Python 虚拟环境..."
if [ ! -d "venv" ]; then
    python3.12 -m venv venv
    echo "✓ 虚拟环境已创建"
else
    echo "✓ 虚拟环境已存在"
fi

# 激活虚拟环境
source venv/bin/activate

# 升级 pip
echo ""
echo "升级 pip..."
pip install --upgrade pip

# 安装依赖
echo ""
echo "安装 Python 依赖..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo "✓ 依赖安装完成"
else
    echo "⚠️  警告: requirements.txt 不存在"
fi

# 安装 SAM3
echo ""
echo "========================================="
echo "SAM3 安装"
echo "========================================="

if [ -d "sam3" ]; then
    echo "✓ SAM3 目录已存在"
    read -p "是否重新安装 SAM3？(y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf sam3
    else
        echo "跳过 SAM3 安装"
        cd sam3
        pip install -e .
        cd ..
    fi
fi

if [ ! -d "sam3" ]; then
    echo "克隆 SAM3 仓库..."
    git clone https://github.com/facebookresearch/sam3.git
    
    echo "安装 SAM3..."
    cd sam3
    pip install -e .
    cd ..
    echo "✓ SAM3 安装完成"
fi

# Hugging Face 认证
echo ""
echo "========================================="
echo "Hugging Face 认证"
echo "========================================="
echo "SAM3 模型需要 Hugging Face 认证"
echo "1. 访问: https://huggingface.co/facebook/sam3"
echo "2. 点击 'Request Access' 并等待审批"
echo "3. 获取 token: https://huggingface.co/settings/tokens"
echo ""
read -p "是否现在配置 Hugging Face token？(y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    pip install huggingface_hub
    huggingface-cli login
fi

# 创建输出目录
echo ""
echo "创建输出目录..."
mkdir -p outputs
mkdir -p uploads
echo "✓ 输出目录已创建"

# 环境变量配置
echo ""
echo "========================================="
echo "API Key 配置"
echo "========================================="
if [ ! -f ".env" ]; then
    echo "创建 .env 配置文件..."
    read -p "请输入 JieKou.AI API Key (留空可稍后在 Web UI 中输入): " API_KEY
    if [ -n "$API_KEY" ]; then
        echo "JIEKOU_API_KEY=$API_KEY" > .env
        echo "✓ API Key 已保存到 .env"
    else
        echo "# JieKou.AI API Key" > .env
        echo "# JIEKOU_API_KEY=your_key_here" >> .env
        echo "ℹ️  请稍后编辑 .env 文件或在 Web UI 中输入 API Key"
    fi
else
    echo "✓ .env 文件已存在"
fi

# 完成
echo ""
echo "========================================="
echo "✓ 部署完成！"
echo "========================================="
echo ""
echo "启动服务器："
echo "  python server.py"
echo ""
echo "后台运行："
echo "  nohup python server.py > server.log 2>&1 &"
echo ""
echo "访问地址："
echo "  http://localhost:5001"
echo ""
echo "查看完整部署文档："
echo "  cat DEPLOYMENT.md"
echo ""
