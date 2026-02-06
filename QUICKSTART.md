# 🚀 快速执行指南

## 本地操作（在你的 Mac 上）

### 1. 提交并推送代码

```bash
cd /Users/intro/github_project/AutoFigure-Edit

# 查看状态
git status

# 添加所有文件
git add .

# 提交
git commit -m "Add JieKou.AI provider support and deployment scripts"

# 推送到你的 fork
git push -u origin main
```

---

## 服务器操作（在你的 Linux 服务器上）

### 2. 登录服务器

```bash
ssh your_username@your_server_ip
```

### 3. 克隆并部署

```bash
# 克隆仓库
git clone https://github.com/illimit3/AutoFigure-Edit.git
cd AutoFigure-Edit

# 一键部署
chmod +x deploy.sh
./deploy.sh
```

### 4. 配置 API Key

```bash
nano .env

# 输入以下内容并保存（Ctrl+O, Enter, Ctrl+X）
JIEKOU_API_KEY=your_actual_api_key_here
```

### 5. 启动服务

**推荐：使用 screen**

```bash
screen -S autofigure
source venv/bin/activate
python server.py

# 按 Ctrl+A 然后按 D 分离会话
# 现在可以关闭 SSH，服务继续运行

# 重新连接: screen -r autofigure
```

**或者：后台运行**

```bash
nohup python server.py > server.log 2>&1 &

# 查看日志
tail -f server.log
```

### 6. 开放端口

```bash
# 开放 5001 端口
sudo ufw allow 5001

# 查看状态
sudo ufw status
```

### 7. 访问服务

在浏览器打开：

```
http://your_server_ip:5001
```

---

## ✅ 完成！

现在你可以：

1. ✅ 在浏览器访问 Web UI
2. ✅ 输入 Method 文本
3. ✅ 选择 JieKou.AI provider
4. ✅ 输入 API Key（如果没配置 .env）
5. ✅ 点击生成按钮

---

## 📝 备注

- **查看日志**: `tail -f server.log`
- **停止服务**: `ps aux | grep server.py` 然后 `kill <PID>`
- **重启服务**: 先停止，再 `nohup python server.py > server.log 2>&1 &`
- **更新代码**: `git pull` 然后重启服务

---

## 🆘 遇到问题？

1. 查看 [DEPLOYMENT.md](DEPLOYMENT.md) - 完整部署文档
2. 查看 [SETUP_GUIDE.md](SETUP_GUIDE.md) - 详细操作流程
3. 检查 `server.log` - 服务器日志
4. 运行 `nvidia-smi` - 确认 GPU 可用
