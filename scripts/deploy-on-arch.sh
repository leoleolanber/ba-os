#!/bin/bash
# ============================================
# 碧蓝档案 OS - Arch Linux 一键部署脚本
# ============================================

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

echo "============================================"
echo "  碧蓝档案 OS - Arch Linux 一键部署"
echo "============================================"
echo ""

# 检查是否 Arch Linux
if [ ! -f /etc/arch-release ]; then
    log_error "此脚本仅适用于 Arch Linux"
    exit 1
fi
log_success "Arch Linux 检测通过"

# 安装依赖
log_info "安装构建依赖..."
sudo pacman -Syu --needed --noconfirm archiso mkarchiso squashfs-tools isolinux syslinux grub dosfstools xorriso
log_success "依赖安装完成"

# 克隆仓库
log_info "克隆项目仓库..."
if [ -d "ba-os" ]; then
    log_warning "ba-os 目录已存在，跳过克隆"
else
    git clone https://github.com/leoleolanber/ba-os.git
fi
log_success "仓库准备完成"

# 进入目录
cd ba-os/scripts

# 开始构建
echo ""
log_info "开始构建 ISO..."
log_warning "首次构建可能需要 40-90 分钟"
echo ""

sudo bash build-iso.sh --no-confirm

# 检查结果
echo ""
if ls ../output/*.iso 1>/dev/null 2>&1; then
    log_success "============================================"
    log_success "  ISO 构建成功！"
    log_success "============================================"
    echo ""
    log_info "ISO 文件位置：$(pwd)/../output/"
    echo ""
    ls -lh ../output/*.iso
    echo ""
    log_info "下一步:"
    echo "  1. 验证校验和：cd ../output && sha256sum -c *.sha256"
    echo "  2. 写入 U 盘：sudo dd if=*.iso of=/dev/sdX bs=4M status=progress"
    echo "  3. 或虚拟机测试"
else
    log_error "ISO 构建失败，请查看日志：../build-full.log"
    exit 1
fi
