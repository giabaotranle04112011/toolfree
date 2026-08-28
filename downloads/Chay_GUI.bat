@echo off
chcp 65001 >nul
title TLGB TOOL GUI - TIKTOK ALL-IN-ONE VIP 2026

echo.
echo =====================================================================
echo         TLGB TOOL - TIKTOK ALL-IN-ONE VIP PRO 2026 (GUI)
echo               BẢN QUYỀN THUỘC VỀ: TRẦN LÊ GIA BẢO
echo =====================================================================
echo.

:: 1. Kiểm tra Python - tự động chọn phiên bản 3.x mới nhất có trên máy
where py >nul 2>nul
if %errorlevel% equ 0 (
    set PYTHON_CMD=py -3
) else (
    where python >nul 2>nul
    if %errorlevel% equ 0 (
        set PYTHON_CMD=python
    ) else (
        echo [ERROR] Không tìm thấy Python trên máy tính của bạn!
        echo Vui lòng cài đặt Python 3.10+ từ https://www.python.org/
        pause
        exit /b 1
    )
)

:: 2. Kiểm tra & cài đặt requirements nếu cần (đồng bộ với Chay_Tool.bat)
if exist "requirements.txt" (
    echo [INFO] Đang kiểm tra môi trường thư viện...
    %PYTHON_CMD% -m pip install -r requirements.txt --quiet >nul 2>nul
    echo [INFO] Thư viện đã sẵn sàng.
)

:: 3. Khởi động giao diện GUI
echo [INFO] Đang khởi động Giao diện Đồ họa TLGB TOOL GUI...
echo.
start "" %PYTHON_CMD% gui_tooltiktok.py
exit
