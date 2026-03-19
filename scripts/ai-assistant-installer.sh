#!/bin/bash
# ============================================
# 碧蓝档案 AI 助手 - 阿罗娜/普拉娜风格
# Blue Archive AI Assistant
# ============================================

set -e

# 配置
AI_ASSISTANT_NAME="Arona"  # 或 "Plana"
AI_MODEL="qwen2.5:7b"  # 可配置
AI_PORT="11434"  # Ollama 默认端口
CONFIG_DIR="$HOME/.config/ba-ai-assistant"
DATA_DIR="$HOME/.local/share/ba-ai-assistant"

# 颜色
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# 创建配置目录
mkdir -p "$CONFIG_DIR" "$DATA_DIR"

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    local missing=()
    
    for cmd in python3 pip3 ollama; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "缺少依赖：${missing[*]}"
        log_info "正在安装..."
        
        if command -v pacman &> /dev/null; then
            sudo pacman -S --needed python pip ollama
        elif command -v apt &> /dev/null; then
            sudo apt install -y python3 python3-pip
        fi
    fi
    
    log_success "依赖检查完成"
}

# 安装 Ollama
install_ollama() {
    log_info "安装 Ollama..."
    
    if ! command -v ollama &> /dev/null; then
        curl -fsSL https://ollama.com/install.sh | sh
        log_success "Ollama 安装完成"
    else
        log_success "Ollama 已安装"
    fi
}

# 下载 AI 模型
download_model() {
    local model=${1:-$AI_MODEL}
    
    log_info "下载 AI 模型：$model"
    ollama pull "$model"
    log_success "模型下载完成"
}

# 启动 Ollama 服务
start_ollama() {
    log_info "启动 Ollama 服务..."
    
    if ! systemctl is-active --quiet ollama; then
        sudo systemctl enable ollama
        sudo systemctl start ollama
    fi
    
    log_success "Ollama 服务已启动"
}

# 创建 AI 助手前端
create_frontend() {
    log_info "创建 AI 助手前端..."
    
    cat > "$CONFIG_DIR/assistant.py" << 'PYTHON_EOF'
#!/usr/bin/env python3
"""
碧蓝档案 AI 助手 - 阿罗娜/普拉娜风格
Blue Archive AI Assistant - Arona/Plana Style
"""

import sys
import json
import requests
import threading
from datetime import datetime
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtGui import *

class AronaAssistant(QMainWindow):
    def __init__(self):
        super().__init__()
        self.init_ui()
        self.ollama_url = "http://localhost:11434/api/generate"
        self.model = "qwen2.5:7b"
        
    def init_ui(self):
        """初始化界面 - 碧蓝档案风格"""
        self.setWindowTitle("阿罗娜 AI 助手")
        self.setGeometry(100, 100, 400, 600)
        
        # 设置碧蓝档案风格
        self.setStyleSheet("""
            QMainWindow {
                background-color: #1a1a2e;
            }
            QWidget {
                color: #ffffff;
                font-family: "Noto Sans CJK SC";
            }
            QTextEdit {
                background-color: #16213e;
                border: 2px solid #4a90e2;
                border-radius: 10px;
                padding: 10px;
                font-size: 14px;
            }
            QLineEdit {
                background-color: #16213e;
                border: 2px solid #4a90e2;
                border-radius: 20px;
                padding: 10px 20px;
                font-size: 14px;
            }
            QPushButton {
                background-color: #4a90e2;
                color: white;
                border: none;
                border-radius: 20px;
                padding: 10px 30px;
                font-size: 14px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #5a9fe2;
            }
            QPushButton:pressed {
                background-color: #3a80d2;
            }
            QLabel {
                color: #ffffff;
                font-size: 16px;
            }
        """)
        
        # 主布局
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        layout.setSpacing(15)
        layout.setContentsMargins(20, 20, 20, 20)
        
        # 标题
        self.title_label = QLabel("🔵 阿罗娜 AI 助手")
        self.title_label.setAlignment(Qt.AlignCenter)
        self.title_label.setStyleSheet("font-size: 20px; font-weight: bold; color: #4a90e2;")
        layout.addWidget(self.title_label)
        
        # 对话显示区域
        self.chat_display = QTextEdit()
        self.chat_display.setReadOnly(True)
        self.chat_display.setPlaceholderText("老师，有什么我可以帮您的吗？")
        layout.addWidget(self.chat_display)
        
        # 输入区域
        input_layout = QHBoxLayout()
        
        self.input_field = QLineEdit()
        self.input_field.setPlaceholderText("输入消息...")
        self.input_field.returnPressed.connect(self.send_message)
        input_layout.addWidget(self.input_field)
        
        self.send_button = QPushButton("发送")
        self.send_button.clicked.connect(self.send_message)
        input_layout.addWidget(self.send_button)
        
        layout.addLayout(input_layout)
        
        # 状态栏
        self.status_label = QLabel("在线")
        self.status_label.setStyleSheet("color: #4ade80;")
        layout.addWidget(self.status_label)
        
        # 欢迎消息
        self.add_message("阿罗娜", "老师好！我是您的 AI 助手阿罗娜。有什么可以帮您的吗？")
        
    def add_message(self, sender, message):
        """添加消息到对话"""
        timestamp = datetime.now().strftime("%H:%M")
        
        if sender == "阿罗娜":
            color = "#4a90e2"
        else:
            color = "#4ade80"
        
        self.chat_display.append(f"""
        <div style="color: {color}; font-weight: bold;">
            {sender} <span style="color: #888; font-size: 12px;">{timestamp}</span>
        </div>
        <div style="margin-left: 20px; margin-bottom: 10px;">
            {message}
        </div>
        """)
        
    def send_message(self):
        """发送消息"""
        user_input = self.input_field.text().strip()
        if not user_input:
            return
        
        # 显示用户消息
        self.add_message("老师", user_input)
        self.input_field.clear()
        
        # 禁用输入
        self.input_field.setEnabled(False)
        self.send_button.setEnabled(False)
        self.status_label.setText("思考中...")
        self.status_label.setStyleSheet("color: #fbbf24;")
        
        # 异步获取 AI 回复
        threading.Thread(target=self.get_ai_response, args=(user_input,)).start()
        
    def get_ai_response(self, user_input):
        """获取 AI 回复"""
        try:
            payload = {
                "model": self.model,
                "prompt": f"你是碧蓝档案中的阿罗娜，是夏莱的秘书。请用温柔、专业但亲切的语气回答老师的问题。保持回答简洁有用。用户问题：{user_input}",
                "stream": False
            }
            
            response = requests.post(self.ollama_url, json=payload, timeout=60)
            response.raise_for_status()
            
            ai_reply = response.json().get("response", "抱歉，老师，我遇到了一些问题...")
            
            # 在主线程更新 UI
            QMetaObject.invokeMethod(self, "update_ui_with_response", 
                                    Qt.QueuedConnection,
                                    Q_ARG(str, ai_reply))
            
        except Exception as e:
            QMetaObject.invokeMethod(self, "update_ui_with_error", 
                                    Qt.QueuedConnection,
                                    Q_ARG(str, str(e)))
    
    @pyqtSlot(str)
    def update_ui_with_response(self, response):
        """更新 UI 显示 AI 回复"""
        self.add_message("阿罗娜", response)
        self.input_field.setEnabled(True)
        self.send_button.setEnabled(True)
        self.status_label.setText("在线")
        self.status_label.setStyleSheet("color: #4ade80;")
        self.input_field.setFocus()
    
    @pyqtSlot(str)
    def update_ui_with_error(self, error):
        """更新 UI 显示错误"""
        self.add_message("系统", f"错误：{error}")
        self.input_field.setEnabled(True)
        self.send_button.setEnabled(True)
        self.status_label.setText("离线")
        self.status_label.setStyleSheet("color: #ef4444;")

def main():
    app = QApplication(sys.argv)
    
    # 设置应用信息
    app.setApplicationName("碧蓝档案 AI 助手")
    app.setOrganizationName("Blue Archive")
    
    window = AronaAssistant()
    window.show()
    
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
PYTHON_EOF

    chmod +x "$CONFIG_DIR/assistant.py"
    log_success "AI 助手前端已创建"
}

# 创建系统服务
create_systemd_service() {
    log_info "创建系统服务..."
    
    cat > "$HOME/.config/systemd/user/ba-ai-assistant.service" << 'SERVICE_EOF'
[Unit]
Description=Blue Archive AI Assistant
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /home/teacher/.config/ba-ai-assistant/assistant.py
Restart=on-failure
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
SERVICE_EOF

    systemctl --user daemon-reload
    log_success "系统服务已创建"
}

# 创建启动器
create_launcher() {
    log_info "创建桌面启动器..."
    
    cat > "$HOME/.local/share/applications/ba-ai-assistant.desktop" << 'LAUNCHER_EOF'
[Desktop Entry]
Name=阿罗娜 AI 助手
Name[zh_CN]=阿罗娜 AI 助手
Comment=碧蓝档案风格 AI 助手
Comment[zh_CN]=碧蓝档案风格 AI 助手
Exec=/usr/bin/python3 /home/teacher/.config/ba-ai-assistant/assistant.py
Icon=preferences-system-network
Terminal=false
Type=Application
Categories=Utility;
Keywords=ai;assistant;aronA;
StartupNotify=true
LAUNCHER_EOF

    log_success "桌面启动器已创建"
}

# 设置快捷键
setup_hotkey() {
    log_info "设置快捷键..."
    
    # 使用 Super + A 启动 AI 助手
    mkdir -p "$HOME/.config/kwinrc.d"
    
    cat > "$HOME/.config/kwinrc.d/ba-ai-assistant.desktop" << 'HOTKEY_EOF'
[Desktop Entry]
Name=启动 AI 助手
Name[zh_CN]=启动 AI 助手
Comment=使用 Super + A 启动阿罗娜 AI 助手
Type=Service
X-KDE-ServiceTypes=KShortcutAction
Actions=RunAIAssistant

[Desktop Action RunAIAssistant]
Name=启动 AI 助手
Exec=/usr/bin/python3 /home/teacher/.config/ba-ai-assistant/assistant.py
GlobalShortcut=Meta+A
HOTKEY_EOF

    log_success "快捷键已设置（Super + A）"
}

# 主安装流程
main() {
    echo "============================================"
    echo "  碧蓝档案 AI 助手安装程序"
    echo "  Blue Archive AI Assistant Installer"
    echo "============================================"
    echo ""
    
    check_dependencies
    install_ollama
    
    echo ""
    read -p "是否下载 AI 模型？（约 2-4GB，[y/N]）: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        download_model
    fi
    
    start_ollama
    create_frontend
    create_systemd_service
    create_launcher
    setup_hotkey
    
    echo ""
    log_success "============================================"
    log_success "  安装完成！"
    log_success "============================================"
    echo ""
    echo "使用方法:"
    echo "  1. 从应用菜单启动「阿罗娜 AI 助手」"
    echo "  2. 使用快捷键 Super + A"
    echo "  3. 命令行：python3 ~/.config/ba-ai-assistant/assistant.py"
    echo ""
    echo "快捷键:"
    echo "  Super + A - 启动/聚焦 AI 助手"
    echo ""
}

# 执行
main "$@"
