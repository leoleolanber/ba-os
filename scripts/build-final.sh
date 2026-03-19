#!/bin/bash
# 碧蓝档案 OS - 完整构建脚本

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
echo "这可能需要 40-90 分钟..."
echo ""

sudo docker run --rm \
    -v "$ARCHISO_DIR":/archiso:rw \
    -v "$WORK_DIR":/work:rw \
    -v "$OUTPUT_DIR":/output:rw \
    --privileged \
    archlinux:latest \
    bash << 'DOCKER_SCRIPT'
set -e

echo ''
echo '=========================================='
echo '  在 Arch Linux 容器中'
echo '=========================================='
echo ''

echo '[1/8] 配置 pacman 镜像源...'
cat > /etc/pacman.d/mirrorlist << 'MIRRORLIST'
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch
Server = https://mirrors.cloud.aliyuncs.com/archlinux/$repo/os/$arch
MIRRORLIST
echo '✓ 镜像源已配置'
echo ''

echo '[2/8] 更新软件包列表...'
pacman -Sy --noconfirm
echo ''

echo '[3/8] 安装基础开发工具...'
pacman -S --noconfirm base base-devel file
echo ''

echo '[4/8] 安装 archiso...'
pacman -S --noconfirm archiso
echo ''

echo '[5/8] 安装 ISO 构建工具...'
pacman -S --noconfirm squashfs-tools syslinux grub dosfstools xorriso libisoburn
echo ''

echo '[6/8] 验证 archiso 目录...'
cd /archiso
ls -la
echo ''
echo 'profiledef.sh 内容:'
head -30 profiledef.sh
echo ''

echo '[7/8] 开始构建 ISO...'
mkarchiso -v -w /work -o /output .
echo ''

echo '[8/8] 重命名 ISO...'
cd /output
for iso in *.iso; do
    if [ -f "$iso" ]; then
        NEW_NAME="blue-archive-teacher-os-v1.0.0-$(date +%Y%m%d).iso"
        mv "$iso" "$NEW_NAME"
        sha256sum "$NEW_NAME" > "${NEW_NAME}.sha256"
        md5sum "$NEW_NAME" > "${NEW_NAME}.md5"
        echo ''
        echo '✓ ISO 创建成功！'
        echo "  文件名：$NEW_NAME"
        SIZE=$(du -h "$NEW_NAME" | cut -f1)
        echo "  大小：$SIZE"
        ls -lh "$NEW_NAME"
    fi
done

echo ''
echo '=========================================='
echo '  构建完成！'
echo '=========================================='
DOCKER_SCRIPT

echo ""
echo "============================================"
echo "  构建完成！"
echo "============================================"
echo ""
echo "ISO 位置：$OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR"/*.iso 2>/dev/null || echo "未找到 ISO 文件"
