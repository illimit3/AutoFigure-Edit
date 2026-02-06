# 📦 GitHub 推送和服务器部署操作流程

## 第一步：推送代码到 GitHub

### 1. 初始化本地仓库（如果还没做）

```bash
cd /Users/intro/github_project/AutoFigure-Edit

# 检查当前 git 状态
git status

# 如果还没有 git 仓库，初始化
git init

# 添加远程仓库（你的 fork）
git remote add origin https://github.com/illimit3/AutoFigure-Edit.git

# 检查远程仓库
git remote -v
```

### 2. 提交所有更改

```bash
# 查看修改的文件
git status

# 添加所有文件到暂存区
git add .

# 提交（包含 jiekou provider 支持）
git commit -m "Add JieKou.AI provider support and deployment scripts

- Add jiekou provider with v3 API for image generation
- Add deployment guide (DEPLOYMENT.md)
- Add one-click deployment script (deploy.sh)
- Update web UI to support jiekou provider
- Update README with deployment instructions"
```

### 3. 推送到 GitHub

```bash
# 推送到主分支（首次推送）
git push -u origin main

# 如果是 master 分支
# git push -u origin master

# 后续推送直接用
# git push
```

### 4. 验证推送成功

访问 https://github.com/illimit3/AutoFigure-Edit 确认代码已上传。

---

## 第二步：在服务器上部署

### 1. SSH 登录服务器

```bash
ssh your_username@your_server_ip

# 例如
# ssh ubuntu@192.168.1.100
```

### 2. 安装系统依赖（首次部署）

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y python3.12 python3.12-venv git

# 检查 CUDA 和 GPU
nvidia-smi

# 如果没有 CUDA，需要先安装
# https://developer.nvidia.com/cuda-downloads
```

### 3. 克隆仓库

```bash
# 进入工作目录
cd ~  # 或 cd /opt/apps/

# 克隆你的 fork
git clone https://github.com/illimit3/AutoFigure-Edit.git

cd AutoFigure-Edit
```

### 4. 运行一键部署脚本

```bash
# 给脚本执行权限
chmod +x deploy.sh

# 运行部署脚本
./deploy.sh
```

脚本会自动：
- ✅ 检查 Python 和 CUDA 版本
- ✅ 创建虚拟环境
- ✅ 安装依赖
- ✅ 克隆并安装 SAM3
- ✅ 配置 Hugging Face 认证
- ✅ 创建输出目录

### 5. 配置 API Key

**方式一：环境变量（推荐）**

```bash
nano .env

# 添加以下内容
JIEKOU_API_KEY=your_api_key_here
```

**方式二：Web UI 输入**

直接在浏览器界面输入 API Key（每次会话需要重新输入）

### 6. 启动服务

**前台运行（测试）**

```bash
source venv/bin/activate
python server.py
```

按 `Ctrl+C` 停止。

**后台运行（生产环境）**

```bash
# 方法 1: nohup
nohup python server.py > server.log 2>&1 &

# 查看日志
tail -f server.log

# 停止服务
ps aux | grep server.py
kill <PID>
```

```bash
# 方法 2: screen（推荐）
screen -S autofigure
python server.py

# 分离会话: Ctrl+A, D
# 重新连接: screen -r autofigure
# 停止: screen -X -S autofigure quit
```

```bash
# 方法 3: systemd（最推荐）
# 见 DEPLOYMENT.md 中的 systemd 配置
```

### 7. 配置防火墙

```bash
# 允许端口 5001
sudo ufw allow 5001

# 或仅允许特定 IP
sudo ufw allow from YOUR_IP to any port 5001
```

### 8. 访问服务

```
http://your_server_ip:5001
```

---

## 第三步：后续更新流程

### 本地更新代码后推送

```bash
# 本地机器
cd /Users/intro/github_project/AutoFigure-Edit

git add .
git commit -m "Your update message"
git push
```

### 服务器上拉取更新

```bash
# 服务器
cd ~/AutoFigure-Edit

# 拉取最新代码
git pull

# 更新依赖（如果 requirements.txt 有变化）
source venv/bin/activate
pip install -r requirements.txt --upgrade

# 重启服务
# 如果用 systemd:
sudo systemctl restart autofigure

# 如果用 nohup:
ps aux | grep server.py
kill <PID>
nohup python server.py > server.log 2>&1 &

# 如果用 screen:
screen -X -S autofigure quit
screen -S autofigure
python server.py
# Ctrl+A, D 分离
```

---

## 常用命令速查

### Git 操作

```bash
# 查看状态
git status

# 查看修改
git diff

# 撤销修改
git checkout -- <file>

# 查看提交历史
git log --oneline

# 创建新分支
git checkout -b feature-name

# 合并分支
git merge feature-name
```

### 服务器管理

```bash
# 查看服务状态（systemd）
sudo systemctl status autofigure

# 查看日志
sudo journalctl -u autofigure -f

# 查看进程
ps aux | grep python

# 查看端口占用
sudo lsof -i :5001

# 查看 GPU 使用
nvidia-smi

# 查看磁盘空间
df -h

# 查看内存使用
free -h
```

### Python 环境

```bash
# 激活虚拟环境
source venv/bin/activate

# 查看已安装包
pip list

# 更新包
pip install <package> --upgrade

# 导出依赖
pip freeze > requirements.txt
```

---

## 🔧 故障排查

### Q1: git push 失败（认证）

```bash
# 使用 SSH 方式
git remote set-url origin git@github.com:illimit3/AutoFigure-Edit.git

# 或配置 token
git config --global credential.helper store
```

### Q2: 服务器端口无法访问

```bash
# 检查服务是否运行
ps aux | grep server.py

# 检查端口监听
sudo lsof -i :5001

# 检查防火墙
sudo ufw status

# 如果是云服务器，检查安全组规则
```

### Q3: SAM3 导入失败

```bash
cd sam3
pip install -e .
```

### Q4: CUDA 版本不匹配

```bash
# 检查 CUDA
nvidia-smi

# 重装 PyTorch（替换为你的 CUDA 版本）
pip uninstall torch torchvision
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu126
```

---

## 📋 检查清单

部署前确认：

- [ ] Git 仓库已推送到 GitHub
- [ ] 服务器有 NVIDIA GPU
- [ ] CUDA 12.6 已安装
- [ ] Python 3.12+ 已安装
- [ ] 有 JieKou.AI API Key
- [ ] 已申请 SAM3 Hugging Face 访问权限
- [ ] 防火墙/安全组已配置

部署后确认：

- [ ] `http://server_ip:5001` 可访问
- [ ] Web UI 加载正常
- [ ] 可以提交测试任务
- [ ] 日志无报错
- [ ] GPU 正常工作（`nvidia-smi`）

---

## 🎯 生产环境推荐配置

1. ✅ 使用 systemd 管理服务（开机自启）
2. ✅ 配置 Nginx 反向代理（HTTPS）
3. ✅ 设置日志轮转
4. ✅ 定期备份 `outputs/` 目录
5. ✅ 监控 GPU 和磁盘使用
6. ✅ 配置告警通知

详见 [DEPLOYMENT.md](DEPLOYMENT.md)
