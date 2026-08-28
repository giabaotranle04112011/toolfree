@echo off
chcp 65001 >nul
title TLGB TOOL - DESKTOP GUI TITAN v6.5.0

echo.
echo =====================================================================
echo       ✦ TLGB TOOL - MULTI-GATEWAY OTP & ADMIN SENTINEL SYSTEM ✦
echo             BẢN QUYỀN ĐỘC QUYỀN THUỘC VỀ: TRẦN LÊ GIA BẢO
echo =====================================================================
echo.

where py >nul 2>nul
if %errorlevel% equ 0 (
    set PYTHON_CMD=py -3.12
) else (
    set PYTHON_CMD=python
)

if exist "%USERPROFILE%\Downloads\spam.py" (
    echo [INFO] Đang khởi chạy Giao diện Desktop GUI từ Downloads\spam.py...
    %PYTHON_CMD% "%USERPROFILE%\Downloads\spam.py" --gui
) else (
    echo [INFO] Đang khởi chạy Giao diện Desktop GUI từ thư mục hiện tại...
    %PYTHON_CMD% "spam.py" --gui
)

pause
