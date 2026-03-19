@echo off
chcp 65001 >nul
echo ============================================
echo   碧蓝档案 OS - Windows 11 构建脚本
echo ============================================
echo.

REM 检查 WSL 是否安装
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 WSL，请先安装 WSL2
    echo.
    echo 在 PowerShell(管理员) 执行：wsl --install -d Ubuntu
    echo.
    pause
    exit /b 1
)

echo [✓] WSL 已安装
echo.

REM 检查 Docker 是否运行
wsl docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] Docker 可能未运行，请先启动 Docker Desktop
    echo.
    echo 按任意键继续尝试...
    pause
)

echo [开始] 克隆仓库...
wsl bash -c "cd ~ && git clone https://github.com/leoleolanber/ba-os.git 2>/dev/null || echo '仓库已存在'"

echo [开始] 进入目录...
wsl bash -c "cd ~/ba-os/scripts && ls -la"

echo.
echo ============================================
echo   开始构建 ISO
echo   首次构建可能需要 40-90 分钟
echo ============================================
echo.
echo 提示：
echo - 构建过程中不要关闭此窗口
echo - ISO 文件会保存在 ba-os/output/ 目录
echo - 可以在文件资源管理器访问：\\wsl$\Ubuntu\home\你的用户名\ba-os\output\
echo.
pause

echo [开始] 执行构建...
wsl bash -c "cd ~/ba-os/scripts && sudo bash build-iso-docker.sh"

echo.
echo ============================================
echo   构建完成！
echo ============================================
echo.
echo ISO 文件位置:
echo - WSL 路径：~/ba-os/output/
echo - Windows 路径：\\wsl$\Ubuntu\home\你的用户名\ba-os\output\
echo.
echo 按任意键退出...
pause
