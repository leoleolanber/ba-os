#!/bin/bash
# 碧蓝档案 OS - 构建脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BA_OS_DIR="$SCRIPT_DIR/.."
WORK_DIR="$BA_OS_DIR/work"
OUTPUT_DIR="$BA_OS_DIR/output"
ARCHISO_DIR="$BA_OS_DIR/archiso"

echo "============================================"
echo "  碧蓝档案 OS - 构建 ISO"
echo "============================================"
echo ""

mkdir -p "$WORK_DIR" "$OUTPUT_DIR"

echo "开始构建 ISO..."
echo "这可能需要 40-90 分钟（首次构建）..."
echo ""

sudo docker run --rm \
    -v "$ARCHISO_DIR":/archiso:rw \
    -v "$WORK_DIR":/work:rw \
    -v "$OUTPUT_DIR":/output:rw \
    --privileged \
    archlinux:latest \
    bash << 'DOCKER_SCRIPT'
    set -e
    
    echo '[1/7] 配置 pacman 镜像源...'
    cat > /etc/pacman.d/mirrorlist << 'MIRRORLIST'
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch
Server = https://mirrors.cloud.aliyuncs.com/archlinux/$repo/os/$arch
MIRRORLIST
    
    echo '[2/7] 更新软件包列表...'
    pacman -Sy --noconfirm || true
    
    echo '[3/7] 安装 archiso...'
    pacman -S --noconfirm archiso base-devel || pacman -S --noconfirm base base-devel
    
    echo '[4/7] 安装 ISO 构建工具...'
    pacman -S --noconfirm squashfs-tools syslinux grub dosfstools xorriso || true
    
    echo '[5/7] 验证目录结构...'
    cd /archiso
    ls -la
    
    echo '[6/7] 构建 ISO...'
    if [ -f profiledef.sh ]; then
        mkarchiso -v -w /work -o /output .
    else
        echo '错误：找不到 profiledef.sh'
        exit 1
    fi
    
    echo '[7/7] 重命名 ISO...'
    cd /output
    for iso in *.iso; do
        if [ -f "$iso" ]; then
            NEW_NAME="blue-archive-teacher-os-v1.0.0-$(date +%Y%m%d).iso"
            mv "$iso" "$NEW_NAME" 2>/dev/null || cp "$iso" "$NEW_NAME"
            sha256sum "$NEW_NAME" > "${NEW_NAME}.sha256"
            md5sum "$NEW_NAME" > "${NEW_NAME}.md5"
            echo ''
            echo '✓ ISO 创建成功！'
            echo "  文件名：$NEW_NAME"
            SIZE=$(du -h "$NEW_NAME" | cut -f1)
            echo "  大小：$SIZE"
        fi
    done
DOCKER_SCRIPT

echo ""
echo "============================================"
echo "  构建完成！"
echo "============================================"
echo ""
echo "ISO 位置：$OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR"/*.iso 2>/dev/null || echo "未找到 ISO 文件"
