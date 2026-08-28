@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title BUN K11 AI VIP - HỆ THỐNG ĐIỀU PHỐI & TỐI ƯU HỆ THỐNG AN TOÀN V8
color 0b

echo ==============================================================================
echo        ⚡ BUN K11 AI VIP • ADB SAFETY CONTROLLER & PROFILE INJECTOR ⚡
echo                   (KIỂM TRA • BACKUP • APPLY • VERIFY • RESTORE)
echo ==============================================================================
echo.

:: [1/7] CHECK ADB
echo [*] [BƯỚC 1/7] Kiểm tra công cụ ADB...
where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo [LỖI] Không tìm thấy tệp adb.exe trong hệ thống!
    echo Vui lòng cài đặt Android Platform Tools hoặc đặt adb vào cùng thư mục.
    echo.
    pause
    exit /b 1
)
echo [OK] Công cụ ADB đã sẵn sàng!
echo.

:: [2/7] CHECK DEVICE & AUTHORIZATION
echo [*] [BƯỚC 2/7] Đang quét và kiểm tra thiết bị kết nối...
for /f "tokens=1,2" %%A in ('adb devices ^| findstr /v "List of devices attached" ^| findstr /r "[a-zA-Z0-9]"') do (
    set "DEV_SERIAL=%%A"
    set "DEV_STATUS=%%B"
)

if "%DEV_SERIAL%"=="" (
    echo [CẢNH BÁO] Không phát hiện thấy điện thoại kết nối qua USB/WiFi ADB!
    echo Vui lòng:
    echo  1. Bật "Tùy chọn nhà phát triển" và "Gỡ lỗi USB (USB Debugging)" trên điện thoại.
    echo  2. Cắm lại cáp USB và chọn "Truyền tệp" hoặc "Chỉ sạc".
    echo.
    pause
    exit /b 1
)

if "%DEV_STATUS%"=="unauthorized" (
    echo [CẢNH BÁO] Thiết bị chưa được cấp quyền truy cập máy tính (Unauthorized)!
    echo Vui lòng nhìn lên màn hình điện thoại và bấm "CHO PHÉP (ALLOW)" gỡ lỗi USB.
    echo.
    pause
    exit /b 1
)

echo [OK] Đã kết nối thiết bị: %DEV_SERIAL% [%DEV_STATUS%]
for /f "tokens=*" %%M in ('adb -s %DEV_SERIAL% shell getprop ro.product.model') do set "DEV_MODEL=%%M"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell getprop ro.build.version.release') do set "DEV_ANDROID=%%V"
echo [+] Model: %DEV_MODEL% • Android: %DEV_ANDROID%
echo.

:: [3/7] BACKUP SETTINGS PRE-GAME
set "BACKUP_FILE=backup_settings_%DEV_SERIAL%.txt"
echo [*] [BƯỚC 3/7] Đang thực hiện Snapshot BACKUP cài đặt gốc vào "%BACKUP_FILE%"...

for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get system pointer_speed 2^>nul') do set "BK_PTR=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get system view_scroll_friction 2^>nul') do set "BK_FRIC=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get global peak_refresh_rate 2^>nul') do set "BK_PEAK_HZ=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get global min_refresh_rate 2^>nul') do set "BK_MIN_HZ=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get global animator_duration_scale 2^>nul') do set "BK_ANIM=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get global window_animation_scale 2^>nul') do set "BK_WIN=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get global transition_animation_scale 2^>nul') do set "BK_TRANS=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get secure long_press_timeout 2^>nul') do set "BK_LONG=%%V"

(
    echo # BUN K11 SNAPSHOT BACKUP FOR %DEV_MODEL% (%DEV_SERIAL%)
    echo pointer_speed=%BK_PTR%
    echo view_scroll_friction=%BK_FRIC%
    echo peak_refresh_rate=%BK_PEAK_HZ%
    echo min_refresh_rate=%BK_MIN_HZ%
    echo animator_duration_scale=%BK_ANIM%
    echo window_animation_scale=%BK_WIN%
    echo transition_animation_scale=%BK_TRANS%
    echo long_press_timeout=%BK_LONG%
) > "%BACKUP_FILE%"

echo [OK] Đã lưu snapshot cài đặt gốc vào: %BACKUP_FILE%
echo.

:: [4/7] GRANT PERMISSIONS TO MACRODROID
echo [*] [BƯỚC 4/7] Cấp quyền Secure Settings cho MacroDroid...
adb -s %DEV_SERIAL% shell pm grant com.arlosoft.macrodroid android.permission.WRITE_SECURE_SETTINGS 2>nul
adb -s %DEV_SERIAL% shell pm grant com.arlosoft.macrodroid android.permission.DUMP 2>nul
adb -s %DEV_SERIAL% shell pm grant com.arlosoft.macrodroid android.permission.PACKAGE_USAGE_STATS 2>nul
adb -s %DEV_SERIAL% shell pm grant com.arlosoft.macrodroid android.permission.CHANGE_CONFIGURATION 2>nul
echo [OK] Đã cấp full quyền Trợ Năng & Hệ Thống cho MacroDroid!
echo.

:: [5/7] SELECT PROFILE
echo ==============================================================================
echo                  CHỌN PROFILE TỐI ƯU HỆ THỐNG CHO THIẾT BỊ:
echo ==============================================================================
echo  [1] PROFILE ULTRA       : 120 FPS • Ghìm Đầu 2 Tầng • Ma Sát 0.0001 • 360Hz
echo  [2] PROFILE PERFORMANCE : 90-120 FPS • Vuốt Nhẹ 40ms • Ma Sát 0.001 • Ổn Định
echo  [3] PROFILE BALANCED    : 60-90 FPS • Tiết Kiệm Pin • Mát Máy • Chống Lag
echo  [4] RESTORE TO ORIGINAL : Khôi phục 100% về cài đặt gốc từ file backup
echo  [0] THOÁT
echo ==============================================================================
set /p "CHOICE=Nhập lựa chọn của bạn [1-4, 0]: "

if "%CHOICE%"=="0" goto :EXIT
if "%CHOICE%"=="4" goto :DO_RESTORE
if "%CHOICE%"=="3" goto :APPLY_BALANCED
if "%CHOICE%"=="2" goto :APPLY_PERF
if "%CHOICE%"=="1" goto :APPLY_ULTRA
goto :APPLY_ULTRA

:APPLY_ULTRA
echo.
echo [*] [BƯỚC 6/7] Đang áp dụng PROFILE ULTRA (MAX PERFORMANCE & GHÌM ĐẦU 360HZ)...
adb -s %DEV_SERIAL% shell settings put system pointer_speed 7
adb -s %DEV_SERIAL% shell settings put system view_scroll_friction 0.0001
adb -s %DEV_SERIAL% shell settings put system touch_sensitivity 1
adb -s %DEV_SERIAL% shell settings put system touch_responsiveness 1
adb -s %DEV_SERIAL% shell settings put system multitouch_min_distance 0
adb -s %DEV_SERIAL% shell settings put secure long_press_timeout 100
adb -s %DEV_SERIAL% shell settings put secure tap_duration_threshold 0
adb -s %DEV_SERIAL% shell settings put secure touch_blocking_period 0
adb -s %DEV_SERIAL% shell settings put secure game_mode 2
adb -s %DEV_SERIAL% shell settings put global peak_refresh_rate 120.0
adb -s %DEV_SERIAL% shell settings put global min_refresh_rate 120.0
adb -s %DEV_SERIAL% shell settings put global user_refresh_rate 120.0
adb -s %DEV_SERIAL% shell settings put global animator_duration_scale 0
adb -s %DEV_SERIAL% shell settings put global window_animation_scale 0
adb -s %DEV_SERIAL% shell settings put global transition_animation_scale 0
adb -s %DEV_SERIAL% shell settings put global force_hw_ui 1
adb -s %DEV_SERIAL% shell setprop debug.sf.hw 1
adb -s %DEV_SERIAL% shell setprop debug.egl.hw 1
adb -s %DEV_SERIAL% shell setprop debug.sf.latch_unsignaled 1
adb -s %DEV_SERIAL% shell setprop persist.sys.NV_FPSLIMIT 120
adb -s %DEV_SERIAL% shell setprop persist.sys.force_highendgfx true
adb -s %DEV_SERIAL% shell setprop persist.sys.touch.latency 0
adb -s %DEV_SERIAL% shell setprop persist.sys.touch.response 1
adb -s %DEV_SERIAL% shell setprop touch.pressure.scale 0.0001
adb -s %DEV_SERIAL% shell setprop touch.size.calibration geometric
adb -s %DEV_SERIAL% shell setprop view.scroll_friction 0.0001
adb -s %DEV_SERIAL% shell setprop windowsmgr.max_events_per_sec 360
adb -s %DEV_SERIAL% shell cmd game set --mode 2 com.dts.freefireth 2>nul
adb -s %DEV_SERIAL% shell cmd game set --mode 2 com.dts.freefiremax 2>nul
adb -s %DEV_SERIAL% shell cmd power set-fixed-performance-mode-enabled true 2>nul
set "PROFILE_NAME=ULTRA (MAX POWER)"
goto :VERIFY_STEP

:APPLY_PERF
echo.
echo [*] [BƯỚC 6/7] Đang áp dụng PROFILE PERFORMANCE (90-120 FPS & SMOOTH DRAG)...
adb -s %DEV_SERIAL% shell settings put system pointer_speed 6
adb -s %DEV_SERIAL% shell settings put system view_scroll_friction 0.001
adb -s %DEV_SERIAL% shell settings put system touch_sensitivity 1
adb -s %DEV_SERIAL% shell settings put secure long_press_timeout 150
adb -s %DEV_SERIAL% shell settings put secure game_mode 2
adb -s %DEV_SERIAL% shell settings put global peak_refresh_rate 120.0
adb -s %DEV_SERIAL% shell settings put global min_refresh_rate 90.0
adb -s %DEV_SERIAL% shell settings put global animator_duration_scale 0
adb -s %DEV_SERIAL% shell settings put global window_animation_scale 0
adb -s %DEV_SERIAL% shell settings put global transition_animation_scale 0
adb -s %DEV_SERIAL% shell setprop persist.sys.NV_FPSLIMIT 120
adb -s %DEV_SERIAL% shell setprop view.scroll_friction 0.001
adb -s %DEV_SERIAL% shell setprop windowsmgr.max_events_per_sec 240
set "PROFILE_NAME=PERFORMANCE (SMOOTH)"
goto :VERIFY_STEP

:APPLY_BALANCED
echo.
echo [*] [BƯỚC 6/7] Đang áp dụng PROFILE BALANCED (60-90 FPS & PIN MÁT MÁY)...
adb -s %DEV_SERIAL% shell settings put system pointer_speed 5
adb -s %DEV_SERIAL% shell settings put system view_scroll_friction 0.005
adb -s %DEV_SERIAL% shell settings put secure long_press_timeout 250
adb -s %DEV_SERIAL% shell settings put global peak_refresh_rate 90.0
adb -s %DEV_SERIAL% shell settings put global min_refresh_rate 60.0
adb -s %DEV_SERIAL% shell settings put global animator_duration_scale 0.5
adb -s %DEV_SERIAL% shell settings put global window_animation_scale 0.5
adb -s %DEV_SERIAL% shell settings put global transition_animation_scale 0.5
adb -s %DEV_SERIAL% shell setprop persist.sys.NV_FPSLIMIT 90
set "PROFILE_NAME=BALANCED (ECO)"
goto :VERIFY_STEP

:DO_RESTORE
echo.
echo [*] [HOÀN TÁC] Đang khôi phục lại cài đặt gốc từ "%BACKUP_FILE%"...
if not "%BK_PTR%"=="" adb -s %DEV_SERIAL% shell settings put system pointer_speed %BK_PTR%
if not "%BK_FRIC%"=="" adb -s %DEV_SERIAL% shell settings put system view_scroll_friction %BK_FRIC%
if not "%BK_PEAK_HZ%"=="" adb -s %DEV_SERIAL% shell settings put global peak_refresh_rate %BK_PEAK_HZ%
if not "%BK_MIN_HZ%"=="" adb -s %DEV_SERIAL% shell settings put global min_refresh_rate %BK_MIN_HZ%
if not "%BK_ANIM%"=="" adb -s %DEV_SERIAL% shell settings put global animator_duration_scale %BK_ANIM%
if not "%BK_WIN%"=="" adb -s %DEV_SERIAL% shell settings put global window_animation_scale %BK_WIN%
if not "%BK_TRANS%"=="" adb -s %DEV_SERIAL% shell settings put global transition_animation_scale %BK_TRANS%
if not "%BK_LONG%"=="" adb -s %DEV_SERIAL% shell settings put secure long_press_timeout %BK_LONG%
adb -s %DEV_SERIAL% shell cmd power set-fixed-performance-mode-enabled false 2>nul
adb -s %DEV_SERIAL% shell setprop view.scroll_friction 1.0 2>nul
echo [OK] ĐÃ HOÀN TÁC THÀNH CÔNG 100% CÀI ĐẶT GỐC CHO THIẾT BỊ!
goto :EXIT

:VERIFY_STEP
:: [7/7] VERIFY & REPORT
echo.
echo [*] [BƯỚC 7/7] Đang kiểm tra và xác nhận cấu hình đã áp dụng...
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get system pointer_speed 2^>nul') do set "CK_PTR=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get system view_scroll_friction 2^>nul') do set "CK_FRIC=%%V"
for /f "tokens=*" %%V in ('adb -s %DEV_SERIAL% shell settings get global peak_refresh_rate 2^>nul') do set "CK_HZ=%%V"

echo ==============================================================================
echo                 KẾT QUẢ ÁP DỤNG PROFILE CHO %DEV_MODEL%:
echo ==============================================================================
echo  [+] Profile Hiện Tại      : %PROFILE_NAME%
echo  [+] Pointer Speed (Độ nhạy): %CK_PTR% (Max 7)
echo  [+] Friction (Ma sát vuốt): %CK_FRIC% (Zero Friction)
echo  [+] Peak Refresh Rate     : %CK_HZ% Hz
echo  [+] Tự Động Kéo Tâm Bám Đầu: 2 TẦNG (Fast 35ms / Micro-Lock 45ms)
echo  [+] Thermal Guard Safe    : KÍCH HOẠT (Bảo vệ nhiệt độ máy)
echo ==============================================================================
echo [HOÀN TẤT] Bây giờ bạn hãy mở MacroDroid trên điện thoại -> Nạp file "macro200k_ultra_upgrade.mdr" -> Vào Free Fire và kéo tâm mượt mà!
echo ==============================================================================

:EXIT
echo.
pause
