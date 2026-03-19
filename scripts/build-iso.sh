#!/bin/bash
# ============================================
# 碧蓝档案老师专属操作系统 - ISO 构建脚本
# Blue Archive Teacher OS - ISO Builder
# ============================================

set -e

# 颜色定义
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# 路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/../work"
ISO_DIR="$SCRIPT_DIR/../output"
ARCHISO_DIR="$SCRIPT_DIR/../archiso"

# 版本
VERSION="1.0.0"
DATE=$(date +%Y%m%d)
ISO_NAME="blue-archive-teacher-os-v${VERSION}-${DATE}.iso"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    local missing=()
    local deps=(archiso mkarchiso squashfs-tools isolinux syslinux grub dosfstools xorriso)
    
    for pkg in "${deps[@]}"; do
        if ! pacman -Q "$pkg" &> /dev/null; then
            missing+=("$pkg")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "缺少依赖：${missing[*]}"
        log_info "正在安装..."
        sudo pacman -S --needed --noconfirm "${missing[@]}"
        log_success "依赖安装完成"
    else
        log_success "所有依赖已满足"
    fi
}

# 清理旧文件
cleanup() {
    log_info "清理旧文件..."
    
    rm -rf "$WORK_DIR"
    rm -rf "$ISO_DIR"/*.iso
    
    mkdir -p "$WORK_DIR" "$ISO_DIR"
    
    log_success "清理完成"
}

# 准备 airootfs
prepare_airootfs() {
    log_info "准备 airootfs..."
    
    # 创建必要的目录结构
    mkdir -p "$ARCHISO_DIR/airootfs/root"
    mkdir -p "$ARCHISO_DIR/airootfs/etc/skel/.config"
    
    # 复制脚本到 airootfs
    cp -r "$SCRIPT_DIR"/* "$ARCHISO_DIR/airootfs/root/"
    
    # 创建自动安装脚本
    cat > "$ARCHISO_DIR/airootfs/root/install.sh" << 'INSTALL_SCRIPT'
#!/bin/bash
# 碧蓝档案 OS 一键安装脚本
echo "欢迎使用碧蓝档案老师专属操作系统安装程序"
echo "请按提示完成安装..."

# 这里可以调用 archinstall 或自定义安装流程
exec archinstall
INSTALL_SCRIPT

    chmod +x "$ARCHISO_DIR/airootfs/root/"*.sh
    
    log_success "airootfs 准备完成"
}

# 创建自定义配置
create_custom_configs() {
    log_info "创建自定义配置..."
    
    # KDE Plasma 碧蓝档案主题配置
    mkdir -p "$ARCHISO_DIR/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc"
    
    # 默认壁纸配置
    cat > "$ARCHISO_DIR/airootfs/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc" << 'PLASMA_CONFIG'
[Containments][1]
wallpaperplugin=org.kde.image
wallpaperpluginmode=SingleImage

[Containments][1][Wallpaper][org.kde.image][General]
FillMode=5
Image=/usr/share/wallpapers/blue-archive-main.jpg
PLASMA_CONFIG

    # 平板模式默认配置（如果检测到平板硬件）
    mkdir -p "$ARCHISO_DIR/airootfs/etc/skel/.config/ba-tablet-mode"
    echo "desktop" > "$ARCHISO_DIR/airootfs/etc/skel/.config/ba-tablet-mode/status"
    
    log_success "自定义配置创建完成"
}

# 构建 ISO
build_iso() {
    log_info "开始构建 ISO..."
    log_info "ISO 名称：$ISO_NAME"
    
    cd "$ARCHISO_DIR"
    
    # 使用 mkarchiso 构建
    sudo mkarchiso -v -w "$WORK_DIR" -o "$ISO_DIR" .
    
    # 重命名 ISO
    if [ -f "$ISO_DIR/archlinux-$(date +%Y.%m.%d)-x86_64.iso" ]; then
        mv "$ISO_DIR/archlinux-$(date +%Y.%m.%d)-x86_64.iso" "$ISO_DIR/$ISO_NAME"
    fi
    
    log_success "ISO 构建完成！"
    log_info "ISO 位置：$ISO_DIR/$ISO_NAME"
    
    # 显示 ISO 信息
    if [ -f "$ISO_DIR/$ISO_NAME" ]; then
        local size=$(du -h "$ISO_DIR/$ISO_NAME" | cut -f1)
        log_info "ISO 大小：$size"
    fi
}

# 创建校验和
create_checksums() {
    log_info "创建校验和..."
    
    cd "$ISO_DIR"
    
    sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
    md5sum "$ISO_NAME" > "${ISO_NAME}.md5"
    
    log_success "校验和创建完成"
}

# 创建 README
create_readme() {
    log_info "创建 README..."
    
    cat > "$ISO_DIR/README.txt" << README_EOF
碧蓝档案老师专属操作系统
Blue Archive Teacher OS v${VERSION}

构建日期：$(date +%Y-%m-%d)
ISO 文件：$ISO_NAME

========== 系统特性 ==========

✓ 基于纯 Arch Linux 基层
✓ KDE Plasma 桌面环境
✓ 碧蓝档案主题美化
✓ 阿罗娜/普拉娜 AI 助手
✓ 一键切换平板模式
✓ 完整软件预装

========== 快速开始 ==========

1. 将 ISO 写入 U 盘
   推荐使用：balenaEtcher 或 Ventoy

2. 从 U 盘启动
   在 BIOS/UEFI 中选择 U 盘启动

3. 试用或安装
   - 直接启动进入 Live 环境试用
   - 运行桌面上的"安装系统"图标

========== 默认账户 ==========

用户名：teacher
密码：bluearchive

root 密码：root

（首次登录后建议修改密码）

========== 快捷键 ==========

Super + T  - 切换平板模式
Super + A  - 启动 AI 助手
Super + 空格 - 切换输入法

========== 技术支持 ==========

文档：/usr/share/doc/ba-os/
配置：~/.config/ba-tablet-mode/
AI 助手：~/.config/ba-ai-assistant/

========== 系统要求 ==========

- CPU: x86_64 双核以上
- 内存：4GB 最低，8GB 推荐
- 存储：20GB 最低，50GB 推荐
- 显卡：支持 OpenGL 3.3

========== 版本信息 ==========

版本：${VERSION}
构建日期：$(date +%Y-%m-%d)
基础：Arch Linux
桌面：KDE Plasma
内核：Linux 6.x

README_EOF

    log_success "README 创建完成"
}

# 显示完成信息
show_completion() {
    echo ""
    log_success "============================================"
    log_success "  碧蓝档案 OS 构建完成！"
    log_success "============================================"
    echo ""
    echo "输出文件:"
    ls -lh "$ISO_DIR"/*.iso 2>/dev/null || echo "未找到 ISO 文件"
    echo ""
    echo "校验和:"
    cat "$ISO_DIR"/*.sha256 2>/dev/null || echo "未找到校验和文件"
    echo ""
    echo "下一步:"
    echo "  1. 使用 balenaEtcher 或 Ventoy 将 ISO 写入 U 盘"
    echo "  2. 从 U 盘启动体验或安装"
    echo "  3. 参考 README.txt 获取使用说明"
    echo ""
}

# 主函数
main() {
    echo "============================================"
    echo "  碧蓝档案老师专属操作系统"
    echo "  Blue Archive Teacher OS Builder"
    echo "  版本：$VERSION"
    echo "============================================"
    echo ""
    
    # 检查是否在正确的目录
    if [ ! -d "$ARCHISO_DIR" ]; then
        log_error "错误：找不到 archiso 目录"
        log_error "请在正确的目录下运行此脚本"
        exit 1
    fi
    
    # 检查是否需要 root
    if [ $EUID -ne 0 ]; then
        log_warning "部分操作需要 root 权限"
        log_info "将在需要时请求 sudo"
    fi
    
    # 支持非交互式运行
    if [[ "$1" == "-y" || "$1" == "--no-confirm" || "$AUTO_BUILD" == "1" ]]; then
        log_info "非交互式模式：自动确认构建"
        CONFIRM_BUILD="y"
    else
        echo ""
        read -p "是否开始构建 ISO？[y/N] " -n 1 -r
        echo
        CONFIRM_BUILD="$REPLY"
    fi
    
    if [[ ! $CONFIRM_BUILD =~ ^[Yy]$ ]]; then
        log_info "构建已取消"
        exit 0
    fi
    
    echo ""
    check_dependencies
    cleanup
    prepare_airootfs
    create_custom_configs
    
    echo ""
    if [[ "$AUTO_BUILD" == "1" ]]; then
        CONFIRM_ISO="y"
    else
        read -p "开始构建 ISO？这可能需要 30-60 分钟 [y/N] " -n 1 -r
        echo
        CONFIRM_ISO="$REPLY"
    fi
    
    if [[ $CONFIRM_ISO =~ ^[Yy]$ ]]; then
        build_iso
        create_checksums
        create_readme
        show_completion
    else
        log_info "ISO 构建已跳过"
        log_info "您可以稍后手动运行：sudo mkarchiso -v -w $WORK_DIR -o $ISO_DIR $ARCHISO_DIR"
    fi
}

# 执行
main "$@"
