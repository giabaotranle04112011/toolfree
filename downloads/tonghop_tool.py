# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════╗
║   ⚡ TLGB ALL-IN-ONE MULTI-TOOL MASTER HUB 2026 ⚡          ║
║         BẢN QUYỀN THUỘC VỀ: TRẦN LÊ GIA BẢO              ║
║    Kết Hợp TLGB TikTok Pro VIP + C25 Multi-Tool Suite        ║
╚══════════════════════════════════════════════════════════════╝
"""

import os, sys, time, subprocess, webbrowser
from pathlib import Path

_ROOT = Path(__file__).resolve().parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass
    os.system('')

from tooltiktok import KeyManager, ProxyPoolManager, GET_KEY_URL

C_NEON   = "\033[38;2;0;245;212m"
C_PURPLE = "\033[38;2;191;90;242m"
C_PINK   = "\033[38;2;255;55;95m"
C_GOLD   = "\033[38;2;255;214;10m"
C_GREEN  = "\033[38;2;48;209;88m"
C_GRAY   = "\033[38;2;100;116;139m"
C_WHITE  = "\033[1;37m"
C_RESET  = "\033[0m"

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')

def show_banner():
    clear()
    print(f"{C_NEON}╔══════════════════════════════════════════════════════════════╗{C_RESET}")
    print(f"{C_NEON}║    ⚡ TLGB ALL-IN-ONE MULTI-TOOL MASTER HUB 2026 ⚡         ║{C_RESET}")
    print(f"{C_NEON}╠══════════════════════════════════════════════════════════════╣{C_RESET}")
    print(f"{C_NEON}║  {C_WHITE}Bản quyền : {C_GOLD}TRẦN LÊ GIA BẢO                                  {C_NEON}║{C_RESET}")
    print(f"{C_NEON}║  {C_WHITE}Hệ Thống  : {C_PURPLE}TLGB TikTok VIP + C25 Tool Multi-Service         {C_NEON}║{C_RESET}")
    print(f"{C_NEON}║  {C_WHITE}Phiên bản : {C_GREEN}Enterprise 4.0 All-In-One                       {C_NEON}║{C_RESET}")
    print(f"{C_NEON}╚══════════════════════════════════════════════════════════════╝{C_RESET}\n")

def launch_gui():
    gui_path = os.path.join(_ROOT, "gui_tooltiktok.py")
    if not os.path.exists(gui_path):
        gui_path = os.path.expandvars(r"%USERPROFILE%\Downloads\gui_tooltiktok.py")
    print(f"{C_NEON}🚀 Đang mở Giao Diện Đồ Họa Cyberpunk...{C_RESET}")
    subprocess.Popen([sys.executable, gui_path])
    time.sleep(1)

def launch_cli():
    cli_path = os.path.join(_ROOT, "run.py")
    if not os.path.exists(cli_path):
        cli_path = os.path.expandvars(r"%USERPROFILE%\Downloads\run.py")
    print(f"{C_NEON}🚀 Khởi chạy TLGB CLI Console Edition...{C_RESET}")
    cmd = f'start cmd /k "chcp 65001 >nul && set PYTHONIOENCODING=utf-8 && title TLGB TIKTOK CLI && py -3.12 \"{cli_path}\""'
    os.system(cmd)
    time.sleep(1)

def launch_c25():
    c25_path = os.path.expandvars(r"%USERPROFILE%\Downloads\c25tool.py")
    if not os.path.exists(c25_path):
        c25_path = os.path.join(_ROOT, "c25tool.py")
    if not os.path.exists(c25_path):
        print(f"{C_PINK}❌ Không tìm thấy c25tool.py tại Downloads hoặc thư mục hiện tại!{C_RESET}")
        input("\nNhấn Enter để quay lại...")
        return
    print(f"{C_GREEN}🚀 Khởi chạy C25 Tool trong cửa sổ CMD độc lập (Đã fix UTF-8)...{C_RESET}")
    cmd = f'start cmd /k "chcp 65001 >nul && set PYTHONIOENCODING=utf-8 && title C25 TOOL VIP INTEGRATION && py -3.12 \"{c25_path}\""'
    os.system(cmd)
    time.sleep(1)

def menu_proxy():
    show_banner()
    p_file = os.path.join(_ROOT, "proxies.txt")
    pool = ProxyPoolManager(p_file)
    print(f"{C_WHITE}Số lượng Proxy hiện có: {C_GREEN}{pool.count:,} IPs{C_RESET}\n")
    c = input(f"{C_GOLD}Bạn có muốn tải mới từ 11 nguồn Public? (y/n): {C_RESET}").strip().lower()
    if c == 'y':
        print(f"{C_NEON}🔄 Đang tải proxy...{C_RESET}")
        added = pool.auto_fetch(save_to_file=True, log_callback=lambda m: print(f"{C_GRAY}  {m}{C_RESET}"))
        print(f"{C_GREEN}✅ Hoàn tất! Đã thêm {added:,} proxy mới.{C_RESET}")
    input(f"\n{C_GRAY}Nhấn Enter để quay lại menu...{C_RESET}")

def menu_key():
    show_banner()
    cached = KeyManager.load_cached_key()
    if cached:
        k = cached.get("license_key", "")
        v, m, exp = KeyManager.verify_key(k)
        print(f"{C_GREEN}Trạng thái hiện tại: {m}{C_RESET}")
    else:
        print(f"{C_GOLD}Chưa kích hoạt License Key VIP.{C_RESET}")
    print(f"{C_GRAY}HWID Máy: {KeyManager.get_machine_fingerprint()}{C_RESET}\n")
    print(f"{C_NEON}[1]{C_WHITE} Nhập License Key mới{C_RESET}")
    print(f"{C_NEON}[2]{C_WHITE} Lấy Key Free 24h trên Web{C_RESET}")
    print(f"{C_NEON}[0]{C_WHITE} Quay lại{C_RESET}\n")
    ch = input(f"{C_GOLD}Chọn (0-2): {C_RESET}").strip()
    if ch == '1':
        k = input(f"{C_WHITE}Nhập Key: {C_RESET}").strip()
        if k:
            v, m, exp = KeyManager.verify_key(k)
            if v:
                KeyManager.save_cached_key(k, exp)
                print(f"{C_GREEN}✅ Kích hoạt thành công: {m}{C_RESET}")
            else:
                print(f"{C_PINK}❌ Key không hợp lệ: {m}{C_RESET}")
        input("\nNhấn Enter để tiếp tục...")
    elif ch == '2':
        webbrowser.open(GET_KEY_URL)

def main():
    while True:
        show_banner()
        print(f"{C_NEON}╔══════════════════════════════════════════════════════════════╗{C_RESET}")
        print(f"{C_NEON}║                     TRUNG TÂM KHỞI CHẠY                      ║{C_RESET}")
        print(f"{C_NEON}╠══════════════════════════════════════════════════════════════╣{C_RESET}")
        print(f"{C_NEON}║  {C_GOLD}[1]{C_WHITE} 🖥️  TLGB TikTok VIP Pro 2026 (Giao Diện GUI Cyberpunk)   {C_NEON}║{C_RESET}")
        print(f"{C_NEON}║  {C_GOLD}[2]{C_WHITE} 🤖  TLGB TikTok VIP 2026 (CLI Console Edition - run.py) {C_NEON}║{C_RESET}")
        print(f"{C_NEON}║  {C_GOLD}[3]{C_WHITE} 🛠️  C25 Multi-Tool Suite (Vũ Văn Chiến - Fix UTF-8)     {C_NEON}║{C_RESET}")
        print(f"{C_NEON}║  {C_GOLD}[4]{C_WHITE} 🌐  Quản Lý & Tải 62,000+ Proxy Pool Tự Động            {C_NEON}║{C_RESET}")
        print(f"{C_NEON}║  {C_GOLD}[5]{C_WHITE} 🔑  Quản Lý Bản Quyền VIP - TRẦN LÊ GIA BẢO             {C_NEON}║{C_RESET}")
        print(f"{C_NEON}║  {C_GOLD}[0]{C_PINK} 🚪  Thoát                                               {C_NEON}║{C_RESET}")
        print(f"{C_NEON}╚══════════════════════════════════════════════════════════════╝{C_RESET}\n")

        choice = input(f"{C_GOLD}Lựa chọn của bạn (0-5): {C_RESET}").strip()
        if choice == '1':
            launch_gui()
        elif choice == '2':
            launch_cli()
        elif choice == '3':
            launch_c25()
        elif choice == '4':
            menu_proxy()
        elif choice == '5':
            menu_key()
        elif choice == '0':
            print(f"{C_GREEN}Tạm biệt! Chúc bạn một ngày tốt lành.{C_RESET}")
            break

if __name__ == '__main__':
    main()
