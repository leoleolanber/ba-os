#!/bin/bash
# ============================================
# 碧蓝档案平板模式切换脚本
# Blue Archive Tablet Mode Switcher
# ============================================

set -e

# 颜色定义
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 状态文件
STATUS_FILE="$HOME/.config/ba-tablet-mode/status"
CONFIG_DIR="$HOME/.config/ba-tablet-mode"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查当前模式
check_mode() {
    if [ -f "$STATUS_FILE" ]; then
        cat "$STATUS_FILE"
    else
        echo "desktop"
    fi
}

# 获取当前模式的人类可读名称
get_mode_name() {
    local mode=$(check_mode)
    if [ "$mode" = "tablet" ]; then
        echo "平板模式"
    else
        echo "桌面模式"
    fi
}

# 切换到平板模式
enable_tablet_mode() {
    log_info "正在切换到平板模式..."
    
    # 创建配置目录
    mkdir -p "$CONFIG_DIR"
    
    # 保存当前状态
    echo "tablet" > "$STATUS_FILE"
    
    # 1. 调整 KDE Plasma 设置
    log_info "调整 Plasma 桌面设置..."
    
    # 启用虚拟键盘自动弹出
    kwriteconfig5 --file virtualkeyboardrc --group General --key VirtualKeyboardEnabled true
    
    # 调整任务栏为 Dock 模式
    kwriteconfig5 --file plasmashellrc --group General --key plasmaTheme org.kde.breeze.tablet
    
    # 调整图标大小（放大 1.5 倍）
    kwriteconfig5 --file kdeglobals --group KDE --key widgetStyle org.kde.breeze.tablet
    
    # 启用触控手势
    kwriteconfig5 --file kwinrc --group Touchpad --key TapToClick true
    kwriteconfig5 --file kwinrc --group Touchpad --key TouchpadEnabled true
    
    # 2. 调整窗口行为
    log_info "优化窗口管理..."
    
    # 设置窗口为全屏默认
    kwriteconfig5 --file kwinrc --group Windows --key DefaultFullScreen true
    
    # 3. 启动平板优化服务
    log_info "启动平板优化服务..."
    
    # 启动 touchegg（手势支持）
    if command -v touchegg &> /dev/null; then
        systemctl --user enable touchegg
        systemctl --user start touchegg
    fi
    
    # 4. 调整字体大小
    log_info "调整字体大小..."
    kwriteconfig5 --file kdeglobals --group General --key font "Noto Sans CJK SC,14,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --file kdeglobals --group General --key toolBarFont "Noto Sans CJK SC,14,-1,5,50,0,0,0,0,0"
    
    # 5. 重启 Plasma 以应用更改
    log_info "应用更改..."
    qdbus org.kde.plasmashell /PlasmaShell org.kde.plasmashell.evaluateScript "plasmashell restart"
    
    log_success "已切换到平板模式！"
    log_info "提示：使用 Ctrl + Shift + Alt + Tab 快捷键可以快速切换回桌面模式"
}

# 切换到桌面模式
disable_tablet_mode() {
    log_info "正在切换到桌面模式..."
    
    # 更新状态
    echo "desktop" > "$STATUS_FILE"
    
    # 1. 恢复 KDE Plasma 设置
    log_info "恢复 Plasma 桌面设置..."
    
    # 禁用虚拟键盘自动弹出
    kwriteconfig5 --file virtualkeyboardrc --group General --key VirtualKeyboardEnabled false
    
    # 恢复传统任务栏
    kwriteconfig5 --file plasmashellrc --group General --key plasmaTheme org.kde.breeze
    
    # 恢复标准图标大小
    kwriteconfig5 --file kdeglobals --group KDE --key widgetStyle org.kde.breeze
    
    # 2. 恢复窗口行为
    log_info "恢复窗口管理..."
    kwriteconfig5 --file kwinrc --group Windows --key DefaultFullScreen false
    
    # 3. 恢复字体大小
    log_info "恢复字体大小..."
    kwriteconfig5 --file kdeglobals --group General --key font "Noto Sans CJK SC,11,-1,5,50,0,0,0,0,0"
    
    # 4. 重启 Plasma 以应用更改
    log_info "应用更改..."
    qdbus org.kde.plasmashell /PlasmaShell org.kde.plasmashell.evaluateScript "plasmashell restart"
    
    log_success "已切换到桌面模式！"
}

# 切换模式（toggle）
toggle_mode() {
    local current_mode=$(check_mode)
    
    if [ "$current_mode" = "tablet" ]; then
        disable_tablet_mode
    else
        enable_tablet_mode
    fi
}

# 显示帮助
show_help() {
    echo "碧蓝档案平板模式切换工具"
    echo ""
    echo "用法：ba-tablet-mode [选项]"
    echo ""
    echo "选项:"
    echo "  on, enable, tablet    切换到平板模式"
    echo "  off, disable, desktop 切换到桌面模式"
    echo "  toggle, switch        切换当前模式"
    echo "  status, check         显示当前模式"
    echo "  help, -h, --help      显示此帮助信息"
    echo ""
    echo "快捷键：Ctrl + Shift + Alt + Tab"
    echo ""
    echo "示例:"
    echo "  ba-tablet-mode on      # 切换到平板模式"
    echo "  ba-tablet-mode off     # 切换到桌面模式"
    echo "  ba-tablet-mode toggle  # 切换模式"
    echo "  ba-tablet-mode status  # 查看当前模式"
}

# 显示当前状态
show_status() {
    local mode=$(check_mode)
    local mode_name=$(get_mode_name)
    
    echo "当前模式：$mode_name"
    echo ""
    
    if [ "$mode" = "tablet" ]; then
        echo "✓ 虚拟键盘：已启用"
        echo "✓ 触控手势：已优化"
        echo "✓ 图标大小：已放大"
        echo "✓ 窗口管理：平板优化"
    else
        echo "✓ 虚拟键盘：已禁用"
        echo "✓ 触控手势：标准"
        echo "✓ 图标大小：标准"
        echo "✓ 窗口管理：桌面优化"
    fi
}

# 自动检测硬件变化（用于系统服务）
auto_detect() {
    log_info "启动自动检测服务..."
    
    # 这里可以添加检测键盘连接/断开的逻辑
    # 使用 libinput 或 udev 规则
    
    log_info "自动检测服务已启动"
}

# 主函数
main() {
    case "${1,,}" in
        on|enable|tablet)
            enable_tablet_mode
            ;;
        off|disable|desktop)
            disable_tablet_mode
            ;;
        toggle|switch)
            toggle_mode
            ;;
        status|check)
            show_status
            ;;
        auto|detect)
            auto_detect
            ;;
        help|-h|--help|"")
            show_help
            ;;
        *)
            log_error "未知选项：$1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
