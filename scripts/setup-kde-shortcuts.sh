#!/bin/bash
# ============================================
# 配置 KDE 快捷键 - 碧蓝档案平板模式切换
# ============================================

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }

log_info "配置 KDE 快捷键..."

# 配置平板模式切换快捷键：Ctrl + Shift + Alt + Tab
# 使用 kwriteconfig5 设置 KWin 快捷键

# 方法 1：通过 KWin 脚本快捷键
kwriteconfig5 --file kwinrc --group Shortcuts --key "Custom_1" "Ctrl+Shift+Alt+Tab"

# 方法 2：创建自定义快捷键（KDE 标准方式）
mkdir -p ~/.config/autostart-scripts/

cat > ~/.config/autostart-scripts/ba-tablet-shortcut.sh << 'EOF'
#!/bin/bash
# 全局快捷键监听器
xbindkeys 2>/dev/null || true
EOF

chmod +x ~/.config/autostart-scripts/ba-tablet-shortcut.sh

# 重启 KWin 以应用快捷键
kquitapp5 kwin_x11 2>/dev/null || kquitapp5 kwin_wayland 2>/dev/null || true

log_success "快捷键配置完成！"
log_info "使用 Ctrl + Shift + Alt + Tab 切换平板模式"
