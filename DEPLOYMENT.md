# AutoFigure-Edit 部署指南

## 前置要求

### 系统要求
- **操作系统**: Linux (推荐 Ubuntu 20.04+)
- **Python**: 3.12+
- **PyTorch**: 2.7+
- **CUDA**: 12.6 (GPU 版本)
- **GPU**: NVIDIA GPU with 16GB+ VRAM (推荐)

### 账号要求
- Hugging Face 账号（用于下载 SAM3 模型）
- JieKou.AI API Key（或其他支持的 LLM 提供商）

---

## 部署步骤

### 1. 克隆仓库

```bash
git clone https://github.com/illimit3/AutoFigure-Edit.git
cd AutoFigure-Edit
```

### 2. 创建 Python 虚拟环境

```bash
python3.12 -m venv venv
source venv/bin/activate
```

### 3. 安装基础依赖

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. 安装 SAM3

SAM3 是独立的依赖项，需要单独安装：

```bash
# 克隆 SAM3 仓库到当前目录
git clone https://github.com/facebookresearch/sam3.git
cd sam3

# 安装 SAM3
pip install -e .

cd ..
```

#### SAM3 Hugging Face 认证

SAM3 模型托管在 Hugging Face，需要先申请访问权限：

1. 访问 https://huggingface.co/facebook/sam3
2. 点击 "Request Access"
3. 等待审批通过

然后在服务器上登录：

```bash
pip install huggingface_hub
huggingface-cli login
# 输入你的 Hugging Face token
```

### 5. 下载 RMBG 模型（可选）

```bash
# RMBG 模型会在首次运行时自动下载
# 如果需要手动下载，可以提前执行：
python -c "from transformers import AutoModelForImageSegmentation; AutoModelForImageSegmentation.from_pretrained('briaai/RMBG-2.0', trust_remote_code=True)"
```

### 6. 配置环境变量

创建 `.env` 文件（可选，也可以通过 Web UI 输入）：

```bash
cat > .env << 'EOF'
# JieKou.AI API Key
JIEKOU_API_KEY=your_api_key_here

# 或者使用其他提供商
# BIANXIE_API_KEY=your_key
# OPENROUTER_API_KEY=your_key
EOF
```

### 7. 启动服务

```bash
# 前台运行（测试）
python server.py

# 后台运行（生产环境）
nohup python server.py > server.log 2>&1 &

# 或使用 screen/tmux
screen -S autofigure
python server.py
# Ctrl+A, D 分离会话
```

### 8. 访问服务

默认运行在 `http://localhost:5001`

- 浏览器访问: `http://your-server-ip:5001`
- 如需外网访问，请配置防火墙和反向代理（见下文）

---

## 生产环境配置（推荐）

### 使用 systemd 管理服务

创建服务文件：

```bash
sudo nano /etc/systemd/system/autofigure.service
```

内容：

```ini
[Unit]
Description=AutoFigure-Edit Server
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/path/to/AutoFigure-Edit
Environment="PATH=/path/to/AutoFigure-Edit/venv/bin"
ExecStart=/path/to/AutoFigure-Edit/venv/bin/python server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable autofigure
sudo systemctl start autofigure
sudo systemctl status autofigure
```

### 使用 Nginx 反向代理

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # 支持 Server-Sent Events
        proxy_buffering off;
        proxy_read_timeout 86400;
    }
}
```

---

## 常见问题

### Q1: SAM3 导入失败

确保 SAM3 已正确安装在同一个虚拟环境中：

```bash
source venv/bin/activate
cd sam3
pip install -e .
```

### Q2: CUDA 相关错误

确认 PyTorch 安装了正确的 CUDA 版本：

```bash
python -c "import torch; print(torch.cuda.is_available())"
```

如果返回 `False`，重新安装 PyTorch：

```bash
pip uninstall torch torchvision
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu126
```

### Q3: Triton 模块错误

Triton 是 NVIDIA GPU 专用库，CPU 环境无法使用 SAM3。必须在有 NVIDIA GPU 的服务器上运行。

### Q4: 端口被占用

修改 `server.py` 中的端口：

```python
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)  # 改为其他端口
```

---

## 更新代码

```bash
cd /path/to/AutoFigure-Edit
git pull origin main
source venv/bin/activate
pip install -r requirements.txt --upgrade
sudo systemctl restart autofigure  # 如果使用 systemd
```

---

## 目录结构

```
AutoFigure-Edit/
├── autofigure2.py          # 主处理逻辑
├── server.py               # FastAPI 服务器
├── requirements.txt        # Python 依赖
├── web/                    # 前端界面
│   ├── index.html
│   ├── canvas.html
│   ├── app.js
│   └── styles.css
├── outputs/                # 生成的输出（自动创建）
├── uploads/                # 上传的文件（自动创建）
└── sam3/                   # SAM3 仓库（需单独克隆）
```

---

## 安全建议

1. **不要将 API Key 提交到 Git**
2. **使用 HTTPS**（通过 Nginx + Let's Encrypt）
3. **限制访问 IP**（如果不需要公开访问）
4. **定期备份 `outputs/` 目录**
5. **设置防火墙规则**

```bash
# 仅允许特定 IP 访问
sudo ufw allow from 1.2.3.4 to any port 5001
```

---

## 监控日志

```bash
# systemd 日志
sudo journalctl -u autofigure -f

# 手动运行的日志
tail -f server.log
```
