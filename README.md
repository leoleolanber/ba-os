# 碧蓝档案老师专属操作系统

<div align="center">

![Blue Archive](https://img.shields.io/badge/Blue-Archive-4A90E2?style=for-the-badge)
![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?style=for-the-badge&logo=arch-linux)
![KDE Plasma](https://img.shields.io/badge/KDE-Plasma-1D99F3?style=for-the-badge&logo=kde)
![Version](https://img.shields.io/badge/Version-1.0.0-4A90E2?style=for-the-badge)

**基于纯 Arch Linux 基层的碧蓝档案主题操作系统**

[特性](#特性) • [下载](#下载) • [安装](#安装) • [使用](#使用) • [FAQ](#faq)

</div>

---

## 📖 简介

**碧蓝档案老师专属操作系统**是一个基于纯 Arch Linux 基层的完整操作系统，专为《碧蓝档案》粉丝和老师（Sensei）们打造。

系统集成了：
- 🎨 **碧蓝档案主题美化** - 壁纸、图标、光标、登录界面
- 🤖 **阿罗娜/普拉娜 AI 助手** - 本地 AI，语音交互
- 📱 **一键平板模式** - 桌面/平板无缝切换
- 📦 **完整软件预装** - 开箱即用，无需额外配置

---

## ✨ 特性

### 🎨 主题美化
- 碧蓝档案风格壁纸（多分辨率）
- 定制图标包（蓝色主题）
- 阿罗娜/普拉娜光标主题
- SDDM 登录界面主题
- 系统声音包

### 🤖 AI 助手
- 阿罗娜/普拉娜人格
- 本地运行（Ollama + 大模型）
- 语音交互支持
- 系统集成（文件搜索、应用启动）
- 快捷键：`Super + A`

### 📱 平板模式
- 一键切换（`Super + T`）
- 自动检测（键盘连接/断开）
- 触控手势优化
- 虚拟键盘自动弹出
- 大图标 Dock 栏

### 📦 预装软件

| 类别 | 软件 |
|------|------|
| **浏览器** | Firefox |
| **办公** | LibreOffice |
| **媒体** | VLC, MPV, Spotify |
| **开发** | VS Code, Git, Python, Node.js |
| **游戏** | Steam, Lutris, Heroic |
| **通讯** | Telegram, Discord, QQ, 微信 |
| **工具** | Docker, VM, 数据库 |

---

## 📥 下载

### ISO 文件

| 版本 | 大小 | 下载 |
|------|------|------|
| v1.0.0 (最新) | ~3.5 GB | [输出目录](./output/) |

### 校验和

```bash
# SHA256
sha256sum -c blue-archive-teacher-os-v1.0.0-*.iso.sha256

# MD5
md5sum -c blue-archive-teacher-os-v1.0.0-*.iso.md5
```

---

## 💿 安装

### 方法 1：使用 U 盘（推荐）

1. **下载 ISO 文件**
   ```bash
   cd /path/to/ba-os/output
   ```

2. **写入 U 盘**
   
   使用 **balenaEtcher**（推荐）:
   - 下载：https://www.balena.io/etcher/
   - 选择 ISO → 选择 U 盘 → 写入
   
   或使用 **Ventoy**:
   - 安装 Ventoy 到 U 盘
   - 复制 ISO 到 U 盘
   
   或使用命令行:
   ```bash
   sudo dd if=blue-archive-teacher-os-v1.0.0-*.iso of=/dev/sdX bs=4M status=progress
   ```

3. **从 U 盘启动**
   - 重启电脑
   - 进入 BIOS/UEFI（通常按 F2/F12/Del）
   - 选择 U 盘启动

4. **试用或安装**
   - 直接进入 Live 环境试用
   - 双击桌面"安装系统"图标

### 方法 2：自行构建

```bash
cd /path/to/ba-os/scripts
sudo ./build-iso.sh
```

构建完成后，ISO 文件位于 `output/` 目录。

---

## 🚀 使用

### 默认账户

| 账户 | 用户名 | 密码 |
|------|--------|------|
| 普通用户 | teacher | bluearchive |
| Root | root | root |

**⚠️ 首次登录后建议修改密码！**

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + Shift + Alt + Tab` | 切换平板模式 |
| `Super + A` 或 `Ctrl + Shift + Alt + A` | 启动 AI 助手 |
| `Super + 空格` 或 `Ctrl + 空格` | 切换输入法 |
| `Alt + Tab` | 切换应用 |
| `Super` 或 `Menu` | 打开应用菜单 |

### 平板模式

```bash
# 切换到平板模式
ba-tablet-mode on

# 切换到桌面模式
ba-tablet-mode off

# 切换模式
ba-tablet-mode toggle

# 查看状态
ba-tablet-mode status
```

或在系统托盘点击平板模式图标。

### AI 助手

1. **启动方式**:
   - 应用菜单 → 阿罗娜 AI 助手
   - 快捷键：`Super + A` 或 `Ctrl + Shift + Alt + A`
   - 命令行：`python3 ~/.config/ba-ai-assistant/assistant.py`

2. **首次使用**:
   ```bash
   # 安装 AI 助手
   ~/root/ai-assistant-installer.sh
   
   # 按提示配置 AI 服务：
   # - 阿里云通义千问（推荐，API 调用）
   # - DeepSeek（API 调用）
   # - 本地 Ollama（可选，需下载 2-4GB 模型）
   ```

3. **API 配置**（推荐）:
   - 通义千问：https://dashscope.console.aliyun.com/apiKey
   - DeepSeek：https://platform.deepseek.com/api_keys
   - 配置文件：`~/.config/ba-ai-assistant/api.conf`

---

## 🛠️ 自定义

### 修改主题

主题文件位于：
```
/usr/share/plasma/desktoptheme/
/usr/share/icons/
/usr/share/sddm/themes/
```

### 修改 AI 助手

配置文件：
```
~/.config/ba-ai-assistant/
```

### 修改平板模式

配置文件：
```
~/.config/ba-tablet-mode/
```

---

## 📋 系统要求

| 要求 | 最低 | 推荐 |
|------|------|------|
| **CPU** | x86_64 双核 | x86_64 四核 |
| **内存** | 4 GB | 8 GB |
| **存储** | 20 GB | 50 GB |
| **显卡** | OpenGL 3.3 | 独立显卡 |

### 平板模式额外要求
- 触控屏（可选）
- 可拆卸键盘（可选）

---

## ❓ FAQ

### Q: 这是官方系统吗？
A: 不是，这是粉丝制作的第三方系统，与《碧蓝档案》官方无关。

### Q: 可以双系统吗？
A: 可以，安装时选择"手动分区"，保留现有系统。

### Q: AI 助手需要联网吗？
A: 首次下载模型需要联网，之后可以离线使用。

### Q: 平板模式支持所有设备吗？
A: 支持所有 x86_64 设备，触控功能需要硬件支持。

### Q: 如何更新系统？
A: 使用 Arch Linux 标准更新方式：
```bash
sudo pacman -Syu
```

### Q: 可以安装其他软件吗？
A: 可以，使用 pacman 或 AUR：
```bash
sudo pacman -S 包名
yay -S aur 包名
```

---

## 📄 许可证

本项目基于 Arch Linux，遵循 Arch Linux 许可证。

碧蓝档案相关素材版权归 Nexon 和 Yostar 所有。

---

## 🙏 致谢

- **Arch Linux** - 优秀的 Linux 发行版
- **KDE Plasma** - 强大的桌面环境
- **Ollama** - 本地 AI 运行
- **Nexon/Yostar** - 《碧蓝档案》

---

## 📞 支持

- 文档：`/usr/share/doc/ba-os/`
- 配置：`~/.config/`
- 问题反馈：GitHub Issues

---

<div align="center">

**Made with 💙 for Sensei**

[返回顶部](#碧蓝档案老师专属操作系统)

</div>
