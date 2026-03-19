#!/usr/bin/env bash
# Blue Archive Teacher OS - Archiso Profile Definition

# 系统标识
iso_name="blue-archive-teacher-os"
iso_label="BA_TEACHER_OS"
iso_publisher="Blue Archive Teacher OS Project"
iso_application="Blue Archive Teacher OS - Arch Linux Based"
iso_version="1.0.0"

# 启动配置
bootmodes=('bios' 'efi-x64')
arch="x86_64"

# 内核
kernel_pkg=('linux' 'linux-firmware')

# 基础软件包
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-b' '1M' '-Xdict-size' '1M')

# 用户配置
username="teacher"
userfullname="Sensei"

# 桌面环境
desktop_environment="plasma"

# 显示管理器
display_manager="sddm"

# 安装目录
install_dir="arch"

# 启动加载器
grub_platforms=('pc' 'efi')
