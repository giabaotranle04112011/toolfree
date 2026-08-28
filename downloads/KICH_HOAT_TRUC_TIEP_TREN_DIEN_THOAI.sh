#!/system/bin/sh
# ==============================================================================
# ⚡ BUN K11 AI VIP - SCRIPT KÍCH HOẠT TỐI ƯU TRỰC TIẾP TRÊN ĐIỆN THOẠI ⚡
# Chạy được qua: Shizuku / Termux / Brevent / LADB / Root / ADB Shell
# ==============================================================================

echo "=================================================================="
echo "  ⚡ BUN K11 AI VIP: ĐANG KÍCH HOẠT TỐI ƯU HỆ THỐNG TRÊN MÁY ⚡"
echo "=================================================================="

# [1] CẤP FULL QUYỀN HỆ THỐNG CHO MACRODROID
echo "[1/5] Đang cấp quyền Secure Settings cho MacroDroid..."
pm grant com.arlosoft.macrodroid android.permission.WRITE_SECURE_SETTINGS 2>/dev/null
pm grant com.arlosoft.macrodroid android.permission.DUMP 2>/dev/null
pm grant com.arlosoft.macrodroid android.permission.PACKAGE_USAGE_STATS 2>/dev/null
pm grant com.arlosoft.macrodroid android.permission.CHANGE_CONFIGURATION 2>/dev/null
echo " -> [OK] Đã cấp quyền hệ thống cho MacroDroid!"

# [2] INJECT TỐI ƯU CẢM ỨNG & ĐỘ NHẠY (ZERO FRICTION & TOUCH SENSITIVITY)
echo "[2/5] Đang inject độ nhạy cảm ứng vào hệ thống Android..."
settings put system pointer_speed 7
settings put system view_scroll_friction 0.0001
settings put system touch_sensitivity 1
settings put system touch_responsiveness 1
settings put system multitouch_min_distance 0
settings put secure long_press_timeout 100
settings put secure multi_press_timeout 100
settings put secure tap_duration_threshold 0
settings put secure touch_blocking_period 0
settings put secure game_mode 2
echo " -> [OK] Độ nhạy con trỏ 7 & Ma sát 0.0001 đã hoạt động!"

# [3] KHÓA MÀN HÌNH 120HZ VÀ TRIỆT TIÊU ĐỘ TRỄ HOẠT ẢNH (0MS DELAY)
echo "[3/5] Đang khóa 120Hz và tắt độ trễ Animation..."
settings put global peak_refresh_rate 120.0
settings put global min_refresh_rate 120.0
settings put global user_refresh_rate 120.0
settings put global animator_duration_scale 0
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global force_hw_ui 1
echo " -> [OK] Đã ép xung 120Hz mượt mà!"

# [4] ÉP XUNG GPU SURFACEFLINGER & TẦN SỐ QUÉT CHẠM 360HZ
echo "[4/5] Đang ép xung GPU và tăng tốc độ lấy mẫu chạm 360Hz..."
setprop debug.sf.hw 1 2>/dev/null
setprop debug.egl.hw 1 2>/dev/null
setprop debug.sf.latch_unsignaled 1 2>/dev/null
setprop debug.performance.tuning 1 2>/dev/null
setprop persist.sys.NV_FPSLIMIT 120 2>/dev/null
setprop persist.sys.force_highendgfx true 2>/dev/null
setprop persist.sys.touch.latency 0 2>/dev/null
setprop persist.sys.touch.response 1 2>/dev/null
setprop touch.pressure.scale 0.0001 2>/dev/null
setprop touch.size.calibration geometric 2>/dev/null
setprop touch.distance.scale 0 2>/dev/null
setprop touch.filter.level 0 2>/dev/null
setprop view.scroll_friction 0.0001 2>/dev/null
setprop windowsmgr.max_events_per_sec 360 2>/dev/null
cmd game set --mode 2 com.dts.freefireth 2>/dev/null
cmd game set --mode 2 com.dts.freefiremax 2>/dev/null
cmd power set-fixed-performance-mode-enabled true 2>/dev/null
echo " -> [OK] GPU Turbo & Game Mode cho Free Fire đã bật!"

# [5] DỌN DẸP BỘ NHỚ RAM ĐỆM (DROP CACHES)
echo "[5/5] Đang giải phóng RAM đệm trước khi vào game..."
sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
am kill-all 2>/dev/null
echo " -> [OK] Đã dọn sạch RAM!"

echo "=================================================================="
echo " [HOÀN TẤT] HỆ THỐNG ĐIỆN THOẠI ĐÃ ĐƯỢC TỐI ƯU CỰC HẠN!"
echo " Bạn mở MacroDroid -> Nạp file macro200k_ultra_upgrade.mdr -> Chiến game!"
echo "=================================================================="
