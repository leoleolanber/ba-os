# 快速开始指南

## 🚀 5 分钟快速体验

### 方式 1：虚拟机体验（推荐新手）

#### 使用 VirtualBox

1. **下载并安装 VirtualBox**
   ```bash
   sudo pacman -S virtualbox virtualbox-host-modules-arch
   ```

2. **创建虚拟机**
   - 打开 VirtualBox
   - 点击"新建"
   - 名称：Blue Archive OS
   - 类型：Linux
   - 版本：Arch Linux (64-bit)
   - 内存：4096 MB 或更多
   - 硬盘：50 GB

3. **加载 ISO**
   - 选择虚拟机 → 设置 → 存储
   - 选择光盘图标 → 选择磁盘文件
   - 选择 `output/blue-archive-teacher-os-v1.0.0-*.iso`

4. **启动虚拟机**
   - 点击"启动"
   - 等待系统加载
   - 进入 Live 环境

### 方式 2：U 盘启动（真实硬件）

1. **准备 U 盘**
   - 至少 8GB 容量
   - 备份 U 盘数据（会被清空）

2. **写入 ISO**
   
   **使用 balenaEtcher（最简单）**:
   - 下载：https://www.balena.io/etcher/
   - 三步操作：选择 ISO → 选择 U 盘 → 写入
   
   **使用命令行**:
   ```bash
   # 确认 U 盘设备名（非常重要！）
   lsblk
   
   # 写入 ISO（替换 /dev/sdX 为你的 U 盘）
   sudo dd if=output/blue-archive-teacher-os-v1.0.0-*.iso of=/dev/sdX bs=4M status=progress
   ```

3. **从 U 盘启动**
   - 插入 U 盘
   - 重启电脑
   - 按启动菜单键（通常 F12/F11/Esc）
   - 选择 U 盘启动

---

## 📋 首次使用

### 1. 登录系统

```
用户名：teacher
密码：bluearchive
```

### 2. 修改密码（重要！）

```bash
# 修改用户密码
passwd

# 修改 root 密码（可选）
sudo passwd root
```

### 3. 更新系统

```bash
sudo pacman -Syu
```

### 4. 安装 AI 助手（可选）

```bash
cd ~/root
sudo bash ai-assistant-installer.sh
```

首次使用会下载 AI 模型（约 2-4GB）。

---

## 🎮 核心功能

### 平板模式切换

**三种方式**:

1. **快捷键**: `Super + T`（Windows 键 + T）

2. **命令行**:
   ```bash
   ba-tablet-mode toggle    # 切换
   ba-tablet-mode on        # 平板模式
   ba-tablet-mode off       # 桌面模式
   ba-tablet-mode status    # 查看状态
   ```

3. **系统托盘**: 点击托盘中的平板图标

### AI 助手

**启动方式**:

1. **快捷键**: `Super + A`

2. **应用菜单**: 搜索"阿罗娜"

3. **命令行**:
   ```bash
   python3 ~/.config/ba-ai-assistant/assistant.py
   ```

### 中文输入法

默认已安装 Fcitx5 中文输入法。

**切换输入法**: `Super + 空格` 或 `Ctrl + 空格`

**配置输入法**: 系统设置 → 输入设备 → 虚拟键盘

---

## 🛠️ 常用操作

### 安装软件

```bash
# 使用 pacman
sudo pacman -S 包名

# 搜索软件包
pacman -Ss 关键词

# 启用 AUR（需要 yay）
yay -S 包名
```

### 系统设置

- **外观**: 系统设置 → 外观
- **主题**: 系统设置 → 全局主题
- **快捷键**: 系统设置 → 快捷键
- **网络**: 系统托盘 → 网络图标

### 备份与恢复

```bash
# 创建系统快照
sudo timeshift --create

# 查看快照
sudo timeshift --list

# 恢复快照
sudo timeshift --restore
```

---

## ❓ 常见问题

### Q: 无法联网？
A: 点击系统托盘的网络图标，选择 WiFi 或有线网络。

### Q: 没有声音？
A: 
```bash
# 检查音频服务
systemctl --user status pulseaudio

# 重启音频服务
systemctl --user restart pulseaudio
```

### Q: 显卡驱动问题？
A: 
```bash
# NVIDIA
sudo pacman -S nvidia nvidia-utils

# AMD
sudo pacman -S mesa vulkan-radeon

# Intel
sudo pacman -S mesa vulkan-intel
```

### Q: 如何安装到硬盘？
A: 双击桌面上的"安装系统"图标，跟随向导完成。

---

## 📚 更多资源

- **完整文档**: `/usr/share/doc/ba-os/`
- **Arch Wiki**: https://wiki.archlinux.org/
- **KDE 文档**: https://docs.kde.org/

---

**祝您使用愉快！有问题随时询问阿罗娜 AI 助手~** 💙
