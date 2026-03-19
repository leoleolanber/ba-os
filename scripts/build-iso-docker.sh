#!/bin/bash
# ============================================
# 碧蓝档案 OS - Docker 构建脚本（国内镜像版）
# 使用阿里云/中科大镜像源加速
# ============================================

set -e

# 颜色
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# 路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BA_OS_DIR="$SCRIPT_DIR/.."
WORK_DIR="$BA_OS_DIR/work"
OUTPUT_DIR="$BA_OS_DIR/output"
ARCHISO_DIR="$BA_OS_DIR/archiso"

# Docker 镜像（使用 Docker Hub 官方镜像）
DOCKER_IMAGE="archlinux:latest"

# 配置 Docker 镜像加速器
configure_docker_mirror() {
    log_info "配置 Docker 镜像加速器..."
    
    # 创建或更新 daemon.json
    sudo mkdir -p /etc/docker
    
    cat | sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://dockerproxy.com",
    "https://c.163.com"
  ],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
    
    # 重启 Docker
    log_info "重启 Docker 服务..."
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
    sleep 2
    log_success "Docker 镜像加速器已配置"
}

# 检查 Docker
check_docker() {
    log_info "检查 Docker..."
    
    if ! docker info &> /dev/null; then
        log_error "Docker 服务未运行"
        log_info "启动 Docker 服务..."
        sudo systemctl start docker
        sleep 2
    fi
    
    log_success "Docker 已就绪"
}

# 创建必要目录
setup_directories() {
    log_info "创建目录结构..."
    
    mkdir -p "$WORK_DIR" "$OUTPUT_DIR"
    chmod -R 755 "$WORK_DIR" "$OUTPUT_DIR"
    
    log_success "目录已创建"
}

# 拉取 Arch Linux 镜像
pull_arch_image() {
    log_info "拉取 Arch Linux Docker 镜像（使用国内镜像）..."
    log_info "镜像：$DOCKER_IMAGE"
    
    docker pull "$DOCKER_IMAGE"
    
    log_success "镜像已拉取"
}

# 在 Docker 容器中构建 ISO
build_in_docker() {
    log_info "在 Docker 容器中构建 ISO..."
    log_info "这可能需要 30-60 分钟，请耐心等待..."
    
    # 挂载工作目录到容器
    docker run --rm \
        -v "$ARCHISO_DIR":/archiso:rw \
        -v "$WORK_DIR":/work:rw \
        -v "$OUTPUT_DIR":/output:rw \
        --privileged \
        "$DOCKER_IMAGE" \
        bash -c "
        set -e
        
        echo '============================================'
        echo '  在 Arch Linux 容器中'
        echo '============================================'
        echo ''
        
        # 配置国内镜像源
        echo '[0/7] 配置 pacman 镜像源...'
        cat > /etc/pacman.d/mirrorlist << 'MIRRORLIST'
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
Server = https://mirror.sjtu.edu.cn/archlinux/\$repo/os/\$arch
Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch
MIRRORLIST
        echo '✓ 镜像源已配置'
        echo ''
        
        # 更新包数据库
        echo '[1/7] 更新软件包列表...'
        pacman -Sy --noconfirm
        echo ''
        
        # 安装 archiso 和依赖
        echo '[2/7] 安装 archiso 和依赖...'
        pacman -S --noconfirm archiso squashfs-tools isolinux syslinux grub dosfstools xorriso
        echo ''
        
        # 验证目录结构
        echo '[3/7] 验证目录结构...'
        ls -la /archiso/
        echo ''
        
        # 构建 ISO
        echo '[4/7] 开始构建 ISO...'
        cd /archiso
        mkarchiso -v -w /work -o /output .
        echo ''
        
        # 重命名 ISO
        echo '[5/7] 重命名 ISO...'
        cd /output
        for iso in archlinux-*.iso; do
            if [ -f \"\$iso\" ]; then
                VERSION=\"1.0.0\"
                DATE=\$(date +%Y%m%d)
                NEW_NAME=\"blue-archive-teacher-os-v\${VERSION}-\${DATE}.iso\"
                mv \"\$iso\" \"\$NEW_NAME\"
                echo \"✓ ISO 已创建：\$NEW_NAME\"
                
                # 创建校验和
                sha256sum \"\$NEW_NAME\" > \"\${NEW_NAME}.sha256\"
                md5sum \"\$NEW_NAME\" > \"\${NEW_NAME}.md5\"
            fi
        done
        echo ''
        
        # 创建 README
        echo '[6/7] 创建 README...'
        cat > /output/README.txt << 'README_EOF'
碧蓝档案老师专属操作系统
Blue Archive Teacher OS v1.0.0

构建日期: $(date +%Y-%m-%d)
构建方式：Docker (Arch Linux 容器)

========== 快速开始 ==========

1. 将 ISO 写入 U 盘
   推荐：balenaEtcher (https://www.balena.io/etcher/)

2. 从 U 盘启动
   在 BIOS/UEFI 中选择 U 盘启动

3. 试用或安装
   - 直接进入 Live 环境试用
   - 双击桌面"安装系统"图标

========== 默认账户 ==========

用户名：teacher
密码：bluearchive

root 密码：root

========== 快捷键 ==========

Super + T  - 切换平板模式
Super + A  - 启动 AI 助手
Super + 空格 - 切换输入法

========== 文档 ==========

完整文档：README.md (在 ISO 根目录)
快速开始：docs/QUICKSTART.md

========== 技术支持 ==========

基于：Arch Linux
桌面：KDE Plasma
内核：Linux 6.x
README_EOF
        echo ''
        
        # 显示结果
        echo '[7/7] 构建完成！'
        echo ''
        echo 'ISO 文件:'
        ls -lh /output/*.iso 2>/dev/null || echo '未找到 ISO 文件'
        echo ''
        echo '校验和:'
        cat /output/*.sha256 2>/dev/null || echo '未找到校验和'
        echo ''
        echo 'ISO 文件位置：/output/'
        echo '在主机上的路径：$OUTPUT_DIR'
        "
    
    log_success "Docker 构建完成！"
}

# 显示结果
show_results() {
    echo ""
    log_success "============================================"
    log_success "  碧蓝档案 OS 构建完成！"
    log_success "============================================"
    echo ""
    
    if ls "$OUTPUT_DIR"/*.iso 1> /dev/null 2>&1; then
        echo "ISO 文件:"
        ls -lh "$OUTPUT_DIR"/*.iso
        echo ""
        
        echo "校验和:"
        cat "$OUTPUT_DIR"/*.sha256 2>/dev/null
        echo ""
        
        echo "下一步:"
        echo "  1. 使用 balenaEtcher 将 ISO 写入 U 盘"
        echo "     下载：https://www.balena.io/etcher/"
        echo ""
        echo "  2. 或使用 dd 命令:"
        echo "     sudo dd if=$OUTPUT_DIR/blue-archive-teacher-os-*.iso of=/dev/sdX bs=4M status=progress"
        echo "     (替换 /dev/sdX 为你的 U 盘设备，注意不要选错！)"
        echo ""
        echo "  3. 从 U 盘启动体验或安装"
        echo ""
        echo "  4. 查看文档："
        echo "     cat $OUTPUT_DIR/README.txt"
        echo ""
    else
        log_error "未找到 ISO 文件，构建可能失败"
        log_info "查看上方日志获取详细信息"
    fi
}

# 主函数
main() {
    echo "============================================"
    echo "  碧蓝档案老师专属操作系统"
    echo "  Blue Archive Teacher OS - Docker Builder"
    echo "  版本：1.0.0 (国内镜像加速版)"
    echo "============================================"
    echo ""
    
    # 检查是否在正确的目录
    if [ ! -d "$ARCHISO_DIR" ]; then
        log_error "错误：找不到 archiso 目录"
        log_error "当前目录：$SCRIPT_DIR"
        exit 1
    fi
    
    configure_docker_mirror
    check_docker
    setup_directories
    pull_arch_image
    
    echo ""
    log_warning "注意：Docker 构建需要下载大量软件包（约 2-3GB）"
    log_warning "构建过程可能需要 30-60 分钟"
    echo ""
    read -p "是否继续？[y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "构建已取消"
        exit 0
    fi
    
    echo ""
    build_in_docker
    show_results
}

# 执行
main "$@"
