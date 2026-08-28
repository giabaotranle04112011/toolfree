# -*- coding: utf-8 -*-
"""
====================================================================
           👑 TLGB TOOL - ULTRA MODERN VIP PRO SUITE 2026 👑
                 (GIAO DIỆN HIỆN ĐẠI THEME DARK VERCEL / DISCORD)
               BẢN QUYỀN THUỘC VỀ: TRẦN LÊ GIA BẢO
====================================================================
- Thiết kế Modern Sidebar Navigation + Glassmorphism Cards
- Bảng màu Obsidian & Cyber Indigo / Sky Blue / Emerald chuẩn UX/UI
- Custom Input & Dropdown bo tròn tinh tế, không chói mắt
- Radar Gauge tròn đếm ngược công nghệ cao siêu mượt
- Console Log màu chuẩn Visual Studio Code
- Đa luồng 100% không đơ lag khi chạy dịch vụ
====================================================================
"""

import sys
import os
import time
import re
import json
import math
import random
import threading
import queue
import webbrowser
import datetime
import colorsys
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext, filedialog
from typing import Optional, Tuple, Dict, List, Any

# Thư viện âm thanh
try:
    import winsound
    HAS_SOUND = True
except ImportError:
    HAS_SOUND = False

# Import core modules
_CUR_DIR = os.path.dirname(os.path.abspath(__file__))
if _CUR_DIR not in sys.path:
    sys.path.insert(0, _CUR_DIR)

from tooltiktok import (
    KeyManager, ConfigManager, LogManager, NetworkManager,
    TikTokURLAnalyzer, TikTokURLInfo, LiveVideoTracker,
    NetworkDiagnostics, ZefoyAutoOcrClient, TikTokDirectApiEngine,
    CookiePoolManager, ProxyPoolManager,
    DEFAULT_USER_AGENT, GET_KEY_URL, LOGS_DIR, EXPORTS_DIR, HAS_CLIPBOARD
)

if HAS_CLIPBOARD:
    import pyperclip


# ==================== PALETTE MÀU CYBERPUNK 2026 ====================
UI = {
    "bg_root": "#050508",         # Nền Carbon siêu tối
    "bg_sidebar": "#090a14",      # Nền thanh Sidebar
    "bg_main": "#090a14",         # Nền khu vực nội dung chính
    "card": "#0e1120",            # Nền Card Cyber
    "card_hover": "#141930",      # Card khi hover
    "card_border": "#1c233c",     # Viền Card mờ
    "card_border_active": "#00f5d4", # Viền phát sáng Neon Cyan
    
    # Neon Accent Colors
    "primary": "#00f5d4",         # Neon Cyan (chính)
    "primary_hover": "#00d2b6",   # Cyan đậm
    "cyan": "#00f5d4",            # Neon Cyan
    "emerald": "#30d158",         # Matrix Green
    "rose": "#ff375f",            # Neon Pink / Red
    "amber": "#ffd60a",           # Cyber Gold
    "purple": "#bf5af2",          # Electric Purple
    
    # Text Hierarchy
    "text_primary": "#ffffff",    # Tiêu đề chính
    "text_secondary": "#cbd5e1",  # Nội dung phụ
    "text_muted": "#64748b",      # Chữ làm mờ
    "input_bg": "#06070c",        # Nền ô nhập liệu
    "input_border": "#1c233c",    # Viền ô nhập liệu
    "console_bg": "#030408"       # Nền Terminal
}


class ModernSound:
    """Âm thanh tương tác tinh tế."""
    enabled = True

    @classmethod
    def click(cls):
        if cls.enabled and HAS_SOUND:
            try:
                winsound.Beep(1600, 20)
            except Exception:
                pass

    @classmethod
    def success(cls):
        if cls.enabled and HAS_SOUND:
            try:
                winsound.Beep(1100, 30)
                winsound.Beep(1600, 45)
                winsound.Beep(2100, 60)
            except Exception:
                pass

    @classmethod
    def error(cls):
        if cls.enabled and HAS_SOUND:
            try:
                winsound.Beep(400, 120)
            except Exception:
                pass


# ==================== SPLASH SCREEN (VERIFICATION ANIMATION) ====================
class SplashScreen:
    """Màn hình loading cyberpunk với animation xác thực key VIP."""

    STEPS = [
        (0.15, "⬡  Khởi tạo hệ thống TLGB Tool Pro 2026...",       "#00f5d4"),
        (0.32, "⬡  Tải cấu trúc Engine Enterprise 4.0...",         "#00f5d4"),
        (0.50, "⬡  Đọc Hardware Fingerprint & Machine ID...",      "#bf5af2"),
        (0.68, "⬡  Kết nối máy chủ xác thực bản quyền VIP...",     "#bf5af2"),
        (0.82, "⬡  Kiểm tra License Key & Phân quyền Admin...",   "#ffd60a"),
        (0.94, "⬡  Khởi tạo giao diện Cyberpunk Dark Neon...",     "#00f5d4"),
        (1.00, "⬡  Xác thực thành công! Khởi chạy Tool...",       "#30d158"),
    ]

    def __init__(self, root: tk.Tk, on_done_callback):
        self.root = root
        self.on_done = on_done_callback
        self.progress = 0.0
        self.target_progress = 0.0
        self.step_idx = 0
        self.license_msg = ""
        self.license_ok = False
        self.scan_x = 0
        self.glow_phase = 0
        self.particles = [
            (random.randint(0, 840), random.randint(0, 540),
             random.uniform(-0.5, 0.5), random.uniform(-0.3, 0.3))
            for _ in range(40)
        ]

        self.win = tk.Toplevel(root)
        self.win.title("TLGB Tool VIP - Verification")
        self.win.geometry("840x540")
        self.win.resizable(False, False)
        self.win.configure(bg=UI["bg_root"])
        self.win.overrideredirect(True)

        self.win.update_idletasks()
        sw = self.win.winfo_screenwidth()
        sh = self.win.winfo_screenheight()
        x = (sw - 840) // 2
        y = (sh - 540) // 2
        self.win.geometry(f"840x540+{x}+{y}")

        self.canvas = tk.Canvas(self.win, bg=UI["bg_root"], width=840, height=540,
                                highlightthickness=0)
        self.canvas.pack(fill="both", expand=True)

        threading.Thread(target=self._check_license, daemon=True).start()
        self._animate()

    def _check_license(self):
        time.sleep(0.4)
        cached = KeyManager.load_cached_key()
        if cached:
            k = cached.get("license_key", "")
            is_valid, msg, _ = KeyManager.verify_key(k)
            if is_valid:
                self.license_ok = True
                self.license_msg = f"⭐ BẢN QUYỀN VIP: {msg}"
                return
        self.license_ok = False
        self.license_msg = "⚠️ Phiên bản chưa kích hoạt Key VIP (Vào Cài Đặt & Key)"

    def _animate(self):
        c = self.canvas
        c.delete("all")
        W, H = 840, 540

        # Background grid
        for x in range(0, W, 48):
            c.create_line(x, 0, x, H, fill="#080a14", width=1)
        for y in range(0, H, 48):
            c.create_line(0, y, W, y, fill="#080a14", width=1)

        # Particles
        self._update_particles(W, H)
        for px, py, _, _ in self.particles:
            c.create_oval(px-1.5, py-1.5, px+1.5, py+1.5, fill="#00f5d4", outline="")

        # Laser Scanline
        self.scan_x = (self.scan_x + 5) % W
        c.create_line(self.scan_x, 0, self.scan_x, H, fill=UI["primary"], width=1)

        # Outer Neon Border with pulsing glow
        self.glow_phase = (self.glow_phase + 4) % 360
        glow = abs(math.sin(math.radians(self.glow_phase)))
        border_c = self._lerp_color("#091a24", UI["primary"], glow * 0.7)
        c.create_rectangle(2, 2, W-2, H-2, outline=border_c, width=2)
        c.create_rectangle(6, 6, W-6, H-6, outline="#0e1628", width=1)

        # Logo & Banner
        c.create_text(W//2, 75, text="⚡ TLGB TOOL PRO VIP 2026 ⚡",
                      font=("Segoe UI", 24, "bold"), fill=UI["primary"])
        c.create_text(W//2, 112, text="TIKTOK AUTOMATION ENTERPRISE SUITE  ▸  CYBERPUNK EDITION",
                      font=("Segoe UI", 10, "bold"), fill=UI["purple"])
        c.create_text(W//2, 134, text="TÁC GIẢ & BẢN QUYỀN: TRẦN LÊ GIA BẢO",
                      font=("Segoe UI", 8, "bold"), fill=UI["text_muted"])

        # Cyber separator line
        c.create_line(70, 152, W-70, 152, fill=UI["primary"], width=1, dash=(5, 3))

        # License status announcement
        lic_color = UI["emerald"] if self.license_ok else UI["amber"]
        if self.license_msg:
            c.create_text(W//2, 178, text=self.license_msg,
                          font=("Segoe UI", 10, "bold"), fill=lic_color)

        # Checklist Steps
        base_y = 206
        for i, (threshold, text, color) in enumerate(self.STEPS):
            done = self.progress >= threshold
            icon = "◆" if done else "◇"
            fg = color if done else UI["text_muted"]
            c.create_text(W//2 - 200, base_y + i * 26, text=f"{icon}  {text}",
                          font=("Consolas", 9), fill=fg, anchor="w")

        # Loading Progress Bar
        bar_x, bar_y, bar_w, bar_h = 70, H - 90, W - 140, 10
        c.create_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h,
                           fill="#090d18", outline=UI["card_border"], width=1)
        fill_w = int(bar_w * self.progress)
        if fill_w > 0:
            c.create_rectangle(bar_x, bar_y, bar_x + fill_w, bar_y + bar_h,
                               fill=UI["primary"], outline="")
        pct = int(self.progress * 100)
        c.create_text(W//2, bar_y + 22, text=f"VERIFYING SYSTEM... {pct}%",
                      font=("Consolas", 9, "bold"), fill=UI["primary"])

        # Smooth Progress interpolation
        if self.target_progress > self.progress:
            self.progress = min(self.target_progress, self.progress + 0.01)

        if self.step_idx < len(self.STEPS):
            next_thresh = self.STEPS[self.step_idx][0]
            if self.progress >= next_thresh - 0.01:
                self.step_idx += 1
                self.target_progress = next_thresh

        if self.license_msg and self.progress < 0.98:
            self.target_progress = 1.0

        if self.progress >= 0.999:
            self.win.after(550, self._finish)
            return

        self.win.after(16, self._animate)

    def _finish(self):
        self.win.destroy()
        self.on_done(self.license_ok, self.license_msg)

    def _update_particles(self, W, H):
        updated = []
        for px, py, vx, vy in self.particles:
            px = (px + vx) % W
            py = (py + vy) % H
            updated.append((px, py, vx, vy))
        self.particles = updated

    @staticmethod
    def _lerp_color(c1: str, c2: str, t: float) -> str:
        r1, g1, b1 = int(c1[1:3],16), int(c1[3:5],16), int(c1[5:7],16)
        r2, g2, b2 = int(c2[1:3],16), int(c2[3:5],16), int(c2[5:7],16)
        r = int(r1 + (r2-r1)*t); g = int(g1 + (g2-g1)*t); b = int(b1 + (b2-b1)*t)
        return f"#{r:02x}{g:02x}{b:02x}"


# ==================== MAIN APPLICATION CLASS ====================
class TLGBModernGUI:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("TLGB TOOL VIP 2026 - TikTok All-In-One Suite | TRẦN LÊ GIA BẢO")
        self.root.geometry("1060x740")
        self.root.minsize(960, 640)
        self.root.configure(bg=UI["bg_root"])

        # Quản lý luồng
        self.log_queue = queue.Queue()
        self.is_running = False
        self.active_client: Optional[ZefoyAutoOcrClient] = None
        self.active_tracker: Optional[LiveVideoTracker] = None

        # Trạng thái Animation đếm ngược & Radar
        self.anim_step = 0
        self.countdown_total = 0
        self.countdown_current = 0
        self.radar_angle = 0
        self.current_tab = "services"

        # Cấu hình Style Dark Theme cho TTK Treeview
        style = ttk.Style()
        try:
            style.theme_use("clam")
        except Exception:
            pass
        style.configure(
            "Treeview",
            background=UI["input_bg"],
            foreground="#ffffff",
            fieldbackground=UI["input_bg"],
            rowheight=26,
            font=("Segoe UI", 9)
        )
        style.configure(
            "Treeview.Heading",
            background=UI["card"],
            foreground=UI["primary"],
            font=("Segoe UI", 9, "bold"),
            relief="flat"
        )
        style.map("Treeview", background=[("selected", UI["primary"])])

        # Dựng layout chính: Header Top + (Sidebar Trái + Main Phải) + Footer Console
        self.create_header_banner()
        self.create_body_layout()
        self.create_bottom_console()

        # Vòng lặp Animation & Log Queue
        self.root.after(40, self.animation_tick)
        self.root.after(100, self.process_log_queue)

    # ==================== 1. HEADER BANNER ====================
    def create_header_banner(self):
        header = tk.Frame(self.root, bg=UI["card"], height=64, bd=1, relief="solid", highlightbackground=UI["card_border"])
        header.pack(fill="x", padx=12, pady=(10, 6))

        # Khung trái: Tên Tool & Bản quyền
        left_f = tk.Frame(header, bg=UI["card"])
        left_f.pack(side="left", padx=16, pady=8)

        t_row = tk.Frame(left_f, bg=UI["card"])
        t_row.pack(anchor="w")

        tk.Label(t_row, text="⚡ TLGB TOOL", font=("Segoe UI", 15, "bold"), bg=UI["card"], fg=UI["primary"]).pack(side="left")
        
        badge = tk.Label(t_row, text=" PRO VIP 2026 ", font=("Segoe UI", 8, "bold"), bg=UI["primary"], fg="#ffffff", padx=4, pady=1)
        badge.pack(side="left", padx=8)

        sub_lbl = tk.Label(left_f, text="⭐️ Tác giả & Bản quyền: TRẦN LÊ GIA BẢO  •  Kiến trúc Enterprise 4.0",
                           font=("Segoe UI", 9), bg=UI["card"], fg=UI["text_muted"])
        sub_lbl.pack(anchor="w", pady=(2, 0))

        # Khung phải: Trạng thái hệ thống Pill
        right_f = tk.Frame(header, bg=UI["card"])
        right_f.pack(side="right", padx=16)

        self.status_pill = tk.Label(right_f, text="● SẴN SÀNG", font=("Segoe UI", 9, "bold"), bg="#064e3b", fg=UI["emerald"], padx=12, pady=5)
        self.status_pill.pack(side="right")

        self.lbl_latency = tk.Label(right_f, text="📶 Latency: 120ms", font=("Segoe UI", 9), bg=UI["card"], fg=UI["text_muted"])
        self.lbl_latency.pack(side="right", padx=12)

    # ==================== 2. BODY LAYOUT (SIDEBAR + MAIN CONTENT) ====================
    def create_body_layout(self):
        self.body_frame = tk.Frame(self.root, bg=UI["bg_root"])
        self.body_frame.pack(fill="both", expand=True, padx=12, pady=0)

        # Sidebar Navigation bên trái
        self.sidebar = tk.Frame(self.body_frame, bg=UI["bg_sidebar"], width=210, bd=1, relief="solid", highlightbackground=UI["card_border"])
        self.sidebar.pack(side="left", fill="y", padx=(0, 6), pady=0)
        self.sidebar.pack_propagate(False)

        # Main Workspace Container bên phải
        self.workspace = tk.Frame(self.body_frame, bg=UI["bg_main"], bd=1, relief="solid", highlightbackground=UI["card_border"])
        self.workspace.pack(side="left", fill="both", expand=True, pady=0)

        # Xây dựng các nút Menu Sidebar
        self.nav_buttons = {}
        nav_items = [
            ("services", "🤖  Dịch Vụ Zefoy"),
            ("analyzer", "🔗  Phân Tích Link"),
            ("tracker",  "📈  Live Tracker"),
            ("c25",      "🛠️  C25 Multi-Tool"),
            ("diag",     "🧪  Kiểm Tra Mạng"),
            ("settings", "⚙️  Cài Đặt & Key")
        ]

        tk.Label(self.sidebar, text="DANH MỤC TÍNH NĂNG", font=("Segoe UI", 8, "bold"), bg=UI["bg_sidebar"], fg=UI["text_muted"]).pack(anchor="w", padx=15, pady=(15, 8))

        for tab_id, tab_label in nav_items:
            btn = tk.Button(
                self.sidebar, text=tab_label, font=("Segoe UI", 9, "bold"),
                bg=UI["bg_sidebar"], fg=UI["text_secondary"],
                activebackground=UI["card_hover"], activeforeground="#ffffff",
                bd=0, anchor="w", padx=15, pady=10, cursor="hand2",
                command=lambda t=tab_id: self.switch_tab(t)
            )
            btn.pack(fill="x", padx=8, pady=2)
            self.nav_buttons[tab_id] = btn

        # Xây dựng các trang nội dung
        self.pages = {}
        self.pages["services"] = self.build_page_services()
        self.pages["analyzer"] = self.build_page_analyzer()
        self.pages["tracker"]  = self.build_page_tracker()
        self.pages["c25"]      = self.build_page_c25()
        self.pages["diag"]     = self.build_page_diag()
        self.pages["settings"] = self.build_page_settings()

        # Hiển thị trang mặc định
        self.switch_tab("services")

    def switch_tab(self, tab_id: str):
        ModernSound.click()
        self.current_tab = tab_id

        # Highlight nút Sidebar
        for t_id, btn in self.nav_buttons.items():
            if t_id == tab_id:
                btn.config(bg=UI["primary"], fg="#ffffff")
            else:
                btn.config(bg=UI["bg_sidebar"], fg=UI["text_secondary"])

        # Chuyển trang
        for p_id, frame in self.pages.items():
            if p_id == tab_id:
                frame.pack(fill="both", expand=True)
            else:
                frame.pack_forget()

    # ==================== PAGE 1: DỊCH VỤ ZEFOY ====================
    def build_page_services(self) -> tk.Frame:
        p = tk.Frame(self.workspace, bg=UI["bg_main"], padx=15, pady=12)

        # Hàng trên: 3 Thẻ thống kê nổi
        top_stats = tk.Frame(p, bg=UI["bg_main"])
        top_stats.pack(fill="x", pady=(0, 10))

        self.card_views = self._create_mini_card(top_stats, "👁️ TỔNG VIEW ĐÃ TĂNG", "+0 VIEWS", UI["cyan"])
        self.card_hearts = self._create_mini_card(top_stats, "❤️ TỔNG TIM ĐÃ TĂNG", "+0 HEARTS", UI["rose"])
        self.card_favs = self._create_mini_card(top_stats, "⭐️ TỔNG LƯU YÊU THÍCH", "+0 FAVS", UI["amber"])

        # Khu vực chia đôi: Cột trái (Form nhập liệu) & Cột phải (Radar đếm ngược)
        center_split = tk.Frame(p, bg=UI["bg_main"])
        center_split.pack(fill="both", expand=True)

        # Cột Trái Form
        form_card = tk.Frame(center_split, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=16, pady=14)
        form_card.pack(side="left", fill="both", expand=True, padx=(0, 6))

        # 1. Chế độ Engine
        tk.Label(form_card, text="CHẾ ĐỘ MÁY CHỦ BUFF (ENGINE)", font=("Segoe UI", 8, "bold"), bg=UI["card"], fg=UI["text_muted"]).pack(anchor="w")
        self.engine_var = tk.StringVar(value="⚡ Direct TikTok API High-Speed (Siêu tốc độ View từ tooltim & buff follow)")
        engine_options = [
            "⚡ Direct TikTok API High-Speed (Siêu tốc độ View từ tooltim & buff follow)",
            "🤖 Zefoy Cloud Auto-OCR Engine (Full 7 Dịch vụ)"
        ]
        self.opt_engine = tk.OptionMenu(form_card, self.engine_var, *engine_options)
        self.opt_engine.config(bg=UI["input_bg"], fg=UI["cyan"], font=("Segoe UI", 9, "bold"), bd=1, relief="solid", highlightthickness=0, anchor="w", pady=4)
        self.opt_engine["menu"].config(bg=UI["card"], fg="#ffffff", font=("Segoe UI", 9), bd=1)
        self.opt_engine.pack(fill="x", pady=(2, 8))

        # 2. Dịch vụ tương tác
        tk.Label(form_card, text="CHỌN DỊCH VỤ TƯƠNG TÁC", font=("Segoe UI", 8, "bold"), bg=UI["card"], fg=UI["text_muted"]).pack(anchor="w")
        self.svc_var = tk.StringVar(value="👁️ Buff View (Tăng lượt xem video / photo)")
        
        svc_options = [
            "👁️ Buff View (Tăng lượt xem video / photo)",
            "❤️ Buff Tim / Hearts (Tăng Tim thật cho video / ảnh)",
            "⭐️ Buff Favorites / Jas (Tăng lưu yêu thích - Limit 100)",
            "👤 Buff Follow (Tăng người theo dõi kênh)",
            "🔄 Buff Share (Tăng lượt chia sẻ)",
            "💬 Buff Comments Hearts (Thả tim bình luận video)",
            "🔴 Buff Live Stream (Tăng mắt xem Live TikTok)"
        ]
        
        self.opt_svc = tk.OptionMenu(form_card, self.svc_var, *svc_options)
        self.opt_svc.config(bg=UI["input_bg"], fg="#ffffff", font=("Segoe UI", 9, "bold"), bd=1, relief="solid", highlightthickness=0, anchor="w", pady=4)
        self.opt_svc["menu"].config(bg=UI["card"], fg="#ffffff", font=("Segoe UI", 9), bd=1)
        self.opt_svc.pack(fill="x", pady=(2, 8))

        # 3. Chế độ Tốc độ / An toàn
        tk.Label(form_card, text="CHẾ ĐỘ TỐC ĐỘ & BẢO VỆ TƯƠNG TÁC", font=("Segoe UI", 8, "bold"), bg=UI["card"], fg=UI["text_muted"]).pack(anchor="w")
        self.speed_mode_var = tk.StringVar(value="🛡️ Chế Độ An Toàn (Chống quét spam TikTok - Khuyên Dùng)")
        speed_options = [
            "🛡️ Chế Độ An Toàn (Chống quét spam TikTok - Khuyên Dùng)",
            "⚡ Chế Độ Siêu Tốc (Turbo Max Speed - 100 Luồng)"
        ]
        self.opt_speed = tk.OptionMenu(form_card, self.speed_mode_var, *speed_options)
        self.opt_speed.config(bg=UI["input_bg"], fg=UI["emerald"], font=("Segoe UI", 9, "bold"), bd=1, relief="solid", highlightthickness=0, anchor="w", pady=4)
        self.opt_speed["menu"].config(bg=UI["card"], fg="#ffffff", font=("Segoe UI", 9), bd=1)
        self.opt_speed.pack(fill="x", pady=(2, 8))

        # 4. Nhập URL
        tk.Label(form_card, text="LIÊN KẾT BÀI VIẾT HOẶC ID TIKTOK", font=("Segoe UI", 8, "bold"), bg=UI["card"], fg=UI["text_muted"]).pack(anchor="w")
        url_box = tk.Frame(form_card, bg=UI["card"])
        url_box.pack(fill="x", pady=(4, 10))

        self.entry_url = tk.Entry(url_box, bg=UI["input_bg"], fg="#ffffff", font=("Consolas", 10), insertbackground=UI["primary"], bd=1, relief="solid", highlightthickness=0)
        self.entry_url.pack(side="left", fill="x", expand=True, ipady=6)

        btn_paste = tk.Button(url_box, text="📋 Dán", bg=UI["card_hover"], fg=UI["cyan"], font=("Segoe UI", 8, "bold"), bd=0, padx=12, command=self.paste_to_entry, cursor="hand2")
        btn_paste.pack(side="left", padx=(6, 0))

        # 3. Mục tiêu
        tk.Label(form_card, text="SỐ LƯỢNG MỤC TIÊU (0 = Chạy liên tục)", font=("Segoe UI", 8, "bold"), bg=UI["card"], fg=UI["text_muted"]).pack(anchor="w")
        self.entry_target = tk.Entry(form_card, bg=UI["input_bg"], fg=UI["amber"], font=("Consolas", 10, "bold"), insertbackground=UI["amber"], width=12, bd=1, relief="solid", highlightthickness=0)
        self.entry_target.insert(0, "0")
        self.entry_target.pack(anchor="w", pady=(4, 14), ipady=5)

        # 4. Nút bấm Khởi động & Dừng
        btn_row = tk.Frame(form_card, bg=UI["card"])
        btn_row.pack(fill="x")

        self.btn_start = tk.Button(btn_row, text="▶  BẮT ĐẦU CHẠY", bg=UI["primary"], fg="#ffffff", font=("Segoe UI", 10, "bold"), bd=0, padx=18, pady=9, command=self.start_service_task, cursor="hand2")
        self.btn_start.pack(side="left", fill="x", expand=True, padx=(0, 4))

        self.btn_stop = tk.Button(btn_row, text="⏹  DỪNG LẠI", bg=UI["rose"], fg="#ffffff", font=("Segoe UI", 10, "bold"), bd=0, padx=18, pady=9, state="disabled", command=self.stop_service_task, cursor="hand2")
        self.btn_stop.pack(side="left", fill="x", expand=True, padx=(4, 4))

        self.btn_refresh_proxy = tk.Button(
            btn_row, text="🔄 Proxy", bg=UI["cyan"], fg="#000000",
            font=("Segoe UI", 9, "bold"), bd=0, padx=12, pady=9,
            command=self._on_refresh_proxy, cursor="hand2"
        )
        self.btn_refresh_proxy.pack(side="left", padx=(0, 0))

        # Cột Phải: Radar Gauge
        radar_card = tk.Frame(center_split, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], width=280)
        radar_card.pack(side="right", fill="both", padx=(6, 0))

        tk.Label(radar_card, text="ĐẾM NGƯỢC ZEFOY", font=("Segoe UI", 8, "bold"), bg=UI["card"], fg=UI["text_muted"]).pack(pady=(12, 0))
        self.canvas_radar = tk.Canvas(radar_card, bg=UI["card"], width=240, height=200, highlightthickness=0)
        self.canvas_radar.pack(fill="both", expand=True, pady=4)

        return p

    def _create_mini_card(self, parent, title: str, val: str, color: str):
        c = tk.Frame(parent, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=14, pady=8)
        c.pack(side="left", fill="x", expand=True, padx=4)

        tk.Label(c, text=title, font=("Segoe UI", 7, "bold"), bg=UI["card"], fg=UI["text_muted"]).pack(anchor="w")
        v = tk.Label(c, text=val, font=("Segoe UI", 11, "bold"), bg=UI["card"], fg=color)
        v.pack(anchor="w", pady=(2, 0))
        return v

    def paste_to_entry(self):
        ModernSound.click()
        try:
            if HAS_CLIPBOARD:
                text = pyperclip.paste().strip()
                self.entry_url.delete(0, tk.END)
                self.entry_url.insert(0, text)
        except Exception:
            pass

    def draw_radar_gauge(self):
        """Vẽ Radar HUD hình tròn với tia quét tương lai và đếm ngược."""
        w = self.canvas_radar.winfo_width()
        h = self.canvas_radar.winfo_height()
        if w < 10 or h < 10:
            return

        self.canvas_radar.delete("all")
        cx, cy = w // 2, h // 2
        radius = min(cx, cy) - 26

        # Vòng tròn mờ nền
        self.canvas_radar.create_oval(cx - radius, cy - radius, cx + radius, cy + radius, outline=UI["card_border"], width=3)
        self.canvas_radar.create_oval(cx - radius + 12, cy - radius + 12, cx + radius - 12, cy + radius - 12, outline=UI["card_border"], width=1, dash=(3, 3))

        # Tính phần trăm đếm ngược
        pct = 1.0
        if self.countdown_total > 0:
            pct = 1.0 - (self.countdown_current / float(self.countdown_total))
            pct = max(0.0, min(1.0, pct))

        extent = int(pct * 359)
        # Cung tròn tiến trình Indigo rực rỡ
        arc_color = UI["primary"] if self.countdown_current > 0 else UI["emerald"]
        self.canvas_radar.create_arc(cx - radius, cy - radius, cx + radius, cy + radius, start=90, extent=-extent, outline=arc_color, width=4, style="arc")

        # Quét tia radar
        self.radar_angle = (self.radar_angle + 6) % 360
        rad = math.radians(self.radar_angle)
        rx = cx + (radius - 8) * math.cos(rad)
        ry = cy + (radius - 8) * math.sin(rad)
        self.canvas_radar.create_line(cx, cy, rx, ry, fill=UI["cyan"], width=1)

        # Tâm điểm đếm ngược
        if self.countdown_current > 0:
            m, s = divmod(self.countdown_current, 60)
            time_txt = f"{m:02d}:{s:02d}"
            sub_txt = "ĐANG CHỜ"
            color_txt = UI["amber"]
        else:
            time_txt = "READY"
            sub_txt = "SẴN SÀNG"
            color_txt = UI["emerald"]

        self.canvas_radar.create_text(cx, cy - 6, text=time_txt, font=("Segoe UI", 16, "bold"), fill=color_txt)
        self.canvas_radar.create_text(cx, cy + 18, text=sub_txt, font=("Segoe UI", 8, "bold"), fill=UI["text_muted"])

    # ==================== PAGE 2: TIKTOK URL ANALYZER ====================
    def build_page_analyzer(self) -> tk.Frame:
        p = tk.Frame(self.workspace, bg=UI["bg_main"], padx=15, pady=12)

        card = tk.Frame(p, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=16, pady=14)
        card.pack(fill="both", expand=True)

        tk.Label(card, text="PHÂN TÍCH VÀ BÓC TÁCH LIÊN KẾT TIKTOK", font=("Segoe UI", 10, "bold"), bg=UI["card"], fg=UI["text_primary"]).pack(anchor="w")
        tk.Label(card, text="Tự động bóc tách ID, giải mã short-link và nhận diện định dạng Video / Ảnh Slide / Profile", font=("Segoe UI", 8), bg=UI["card"], fg=UI["text_muted"]).pack(anchor="w", pady=(2, 10))

        in_f = tk.Frame(card, bg=UI["card"])
        in_f.pack(fill="x", pady=(0, 12))

        self.an_entry = tk.Entry(in_f, bg=UI["input_bg"], fg="#ffffff", font=("Consolas", 10), bd=1, relief="solid", highlightthickness=0)
        self.an_entry.pack(side="left", fill="x", expand=True, ipady=6)

        btn_an = tk.Button(in_f, text="🔍 Phân Tích", bg=UI["primary"], fg="#ffffff", font=("Segoe UI", 9, "bold"), bd=0, padx=16, command=self.do_analyze_url, cursor="hand2")
        btn_an.pack(side="left", padx=(8, 0))

        self.an_res_box = tk.Text(card, bg=UI["input_bg"], fg=UI["emerald"], font=("Consolas", 10), height=11, bd=1, relief="solid", padx=12, pady=10)
        self.an_res_box.pack(fill="both", expand=True)

        return p

    def do_analyze_url(self):
        ModernSound.click()
        url = self.an_entry.get().strip()
        if not url:
            messagebox.showwarning("Thông báo", "Vui lòng nhập liên kết TikTok cần phân tích!")
            return

        self.an_res_box.delete("1.0", tk.END)
        self.an_res_box.insert(tk.END, "⏳ Đang kết nối máy chủ TikTok bóc tách metadata...\n")

        def task():
            info = TikTokURLAnalyzer.analyze(url)
            self.root.after(0, lambda: self._show_analysis_result(info))

        threading.Thread(target=task, daemon=True).start()

    def _show_analysis_result(self, info: TikTokURLInfo):
        self.an_res_box.delete("1.0", tk.END)
        if info.is_valid:
            ModernSound.success()
            txt = f"""✅ KẾT QUẢ PHÂN TÍCH LIÊN KẾT THÀNH CÔNG:
══════════════════════════════════════════════════════════════
• Định dạng nội dung  : {info.content_type}
• TikTok Target ID    : {info.target_id}
• Tác giả (Author)    : @{info.username or 'Không rõ'}
• Resolved Full URL   : {info.resolved_url}
• Ghi chú hệ thống    : {info.status_msg}
══════════════════════════════════════════════════════════════"""
            self.an_res_box.insert(tk.END, txt)
            self.entry_url.delete(0, tk.END)
            self.entry_url.insert(0, info.resolved_url)
        else:
            self.an_res_box.insert(tk.END, f"❌ LIÊN KẾT KHÔNG HỢP LỆ:\n{info.status_msg}\n")

    # ==================== PAGE 3: LIVE GROWTH TRACKER ====================
    def build_page_tracker(self) -> tk.Frame:
        p = tk.Frame(self.workspace, bg=UI["bg_main"], padx=15, pady=12)

        ctrl_card = tk.Frame(p, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=16, pady=12)
        ctrl_card.pack(fill="x", pady=(0, 10))

        tk.Label(ctrl_card, text="THEO DÕI TĂNG TRƯỞNG VIDEO THỜI GIAN THỰC", font=("Segoe UI", 9, "bold"), bg=UI["card"], fg=UI["text_primary"]).pack(anchor="w")

        row = tk.Frame(ctrl_card, bg=UI["card"])
        row.pack(fill="x", pady=(6, 0))

        self.track_entry = tk.Entry(row, bg=UI["input_bg"], fg="#ffffff", font=("Consolas", 10), bd=1, relief="solid", highlightthickness=0)
        self.track_entry.pack(side="left", fill="x", expand=True, padx=(0, 8), ipady=5)

        btn_start_t = tk.Button(row, text="▶ Bắt Đầu", bg=UI["emerald"], fg="#000000", font=("Segoe UI", 8, "bold"), bd=0, padx=14, pady=5, command=self.start_tracker_task, cursor="hand2")
        btn_start_t.pack(side="left", padx=2)

        btn_stop_t = tk.Button(row, text="⏹ Dừng & Xuất CSV", bg=UI["rose"], fg="#ffffff", font=("Segoe UI", 8, "bold"), bd=0, padx=14, pady=5, command=self.stop_tracker_task, cursor="hand2")
        btn_stop_t.pack(side="left", padx=2)

        # Bảng hiển thị
        tree_card = tk.Frame(p, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=10, pady=10)
        tree_card.pack(fill="both", expand=True)

        self.track_tree = ttk.Treeview(tree_card, columns=("time", "views", "likes", "shares", "growth"), show="headings")
        self.track_tree.heading("time", text="Thời Gian")
        self.track_tree.heading("views", text="Lượt Xem")
        self.track_tree.heading("likes", text="Lượt Tim")
        self.track_tree.heading("shares", text="Lượt Chia Sẻ")
        self.track_tree.heading("growth", text="Tốc Độ Tăng Trưởng")
        self.track_tree.pack(fill="both", expand=True)

        return p

    def start_tracker_task(self):
        ModernSound.click()
        url = self.track_entry.get().strip()
        if not url:
            messagebox.showwarning("Thông báo", "Vui lòng nhập link bài viết cần theo dõi!")
            return

        info = TikTokURLAnalyzer.analyze(url)
        if not info.is_valid or not info.target_id:
            messagebox.showerror("Lỗi", "Link không hợp lệ!")
            return

        for row in self.track_tree.get_children():
            self.track_tree.delete(row)

        self.active_tracker = LiveVideoTracker(target_id=info.target_id, resolved_url=info.resolved_url)
        
        def tracker_loop():
            while self.active_tracker and not self.active_tracker.stop_event.is_set():
                stats = self.active_tracker.fetch_current_stats()
                if stats:
                    self.active_tracker.add_snapshot(stats)
                    growth = self.active_tracker.calculate_growth_rate()
                    now_str = datetime.datetime.now().strftime("%H:%M:%S")
                    growth_str = f"+{growth['views_per_min']:.1f} views/min"
                    
                    self.root.after(0, lambda: self.track_tree.insert("", "end", values=(now_str, f"+{stats['views']}", f"+{stats['likes']}", f"+{stats['shares']}", growth_str)))
                time.sleep(ConfigManager.get("refresh_interval", 10))

        threading.Thread(target=tracker_loop, daemon=True).start()
        self.log("🚀 Bắt đầu đo tốc độ tăng trưởng video...")

    def stop_tracker_task(self):
        ModernSound.click()
        if self.active_tracker:
            self.active_tracker.stop_event.set()
            filepath = self.active_tracker.export_data(ConfigManager.get("export_format", "csv"))
            ModernSound.success()
            messagebox.showinfo("Hoàn tất", f"Đã xuất dữ liệu tăng trưởng ra tệp:\n{filepath}")
            self.log(f"💾 Đã xuất báo cáo theo dõi ra: {filepath}")
            self.active_tracker = None

    # ==================== PAGE 4: C25 MULTI-TOOL LAUNCHER ====================
    def build_page_c25(self) -> tk.Frame:
        p = tk.Frame(self.workspace, bg=UI["bg_main"], padx=15, pady=12)

        c25_path = os.path.expandvars(r"%USERPROFILE%\Downloads\c25tool.py")
        found = os.path.exists(c25_path) or os.path.exists("c25tool.py")

        card = tk.Frame(p, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=20, pady=16)
        card.pack(fill="both", expand=True)

        tk.Label(card, text="🛠️ TRUNG TÂM KẾT HỢP C25 MULTI-TOOL VIP", font=("Segoe UI", 11, "bold"), bg=UI["card"], fg=UI["amber"]).pack(anchor="w", pady=(0, 4))
        tk.Label(card, text="Tích hợp khởi chạy bộ công cụ C25 Tool đa dịch vụ trong môi trường CMD độc lập (Đã fix lỗi mã hóa UTF-8).", font=("Segoe UI", 8), bg=UI["card"], fg=UI["text_secondary"]).pack(anchor="w", pady=(0, 12))

        # Status box
        status_box = tk.Frame(card, bg=UI["input_bg"], bd=1, relief="solid", padx=12, pady=10)
        status_box.pack(fill="x", pady=(0, 14))

        status_color = UI["emerald"] if found else UI["rose"]
        status_text = "✅ ĐÃ PHÁT HIỆN TỆP C25TOOL.PY TRONG MÁY" if found else "⚠️ CHƯA TÌM THẤY TỆP C25TOOL.PY"
        tk.Label(status_box, text=status_text, font=("Segoe UI", 9, "bold"), bg=UI["input_bg"], fg=status_color).pack(anchor="w")
        tk.Label(status_box, text=f"Đường dẫn: {c25_path}", font=("Consolas", 8), bg=UI["input_bg"], fg=UI["text_muted"]).pack(anchor="w", pady=(2, 0))

        # Action Buttons
        btn_f = tk.Frame(card, bg=UI["card"])
        btn_f.pack(fill="x", pady=6)

        btn_run = tk.Button(
            btn_f, text="▶  KHỞI CHẠY C25 TOOL (CỬA SỔ RIÊNG)",
            bg=UI["emerald"], fg="#000000", font=("Segoe UI", 10, "bold"),
            bd=0, padx=18, pady=10, command=self.launch_c25_tool, cursor="hand2"
        )
        btn_run.pack(side="left", padx=(0, 8))

        btn_web = tk.Button(
            btn_f, text="🌐 Lấy Key C25 (c25tool.net)",
            bg=UI["card_hover"], fg=UI["cyan"], font=("Segoe UI", 9, "bold"),
            bd=0, padx=14, pady=10, command=lambda: webbrowser.open("https://c25tool.net"), cursor="hand2"
        )
        btn_web.pack(side="left", padx=(0, 8))

        btn_yt = tk.Button(
            btn_f, text="▶ YouTube C25",
            bg=UI["card_hover"], fg=UI["rose"], font=("Segoe UI", 9, "bold"),
            bd=0, padx=14, pady=10, command=lambda: webbrowser.open("https://www.youtube.com/@c25tool"), cursor="hand2"
        )
        btn_yt.pack(side="left")

        # Instruction Card
        info_card = tk.Frame(card, bg=UI["bg_main"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=14, pady=12)
        info_card.pack(fill="both", expand=True, pady=(16, 0))

        tk.Label(info_card, text="💡 HƯỚNG DẪN KẾT HỢP SỬ DỤNG:", font=("Segoe UI", 8, "bold"), bg=UI["bg_main"], fg=UI["cyan"]).pack(anchor="w")
        hints = [
            "1. Tool TikTok VIP của bạn (TLGB Tool) chịu trách nhiệm Buff View/Tim qua Direct API & Zefoy Auto-OCR.",
            "2. C25 Tool hỗ trợ thêm các tính năng đa luồng bổ sung từ cộng đồng C25.",
            "3. Khi bấm nút 'Khởi Chạy', hệ thống tự động thiết lập UTF-8 để không bị lỗi font tiếng Việt.",
            "4. Cả 2 tool có thể chạy song song cùng lúc mà không xung đột tài nguyên hay chiếm dụng mạng."
        ]
        for h in hints:
            tk.Label(info_card, text=f"• {h}", font=("Segoe UI", 8), bg=UI["bg_main"], fg=UI["text_secondary"], justify="left").pack(anchor="w", pady=2)

        return p

    def launch_c25_tool(self):
        ModernSound.click()
        c25_path = os.path.expandvars(r"%USERPROFILE%\Downloads\c25tool.py")
        if not os.path.exists(c25_path):
            if os.path.exists("c25tool.py"):
                c25_path = os.path.abspath("c25tool.py")
            else:
                messagebox.showerror("Không tìm thấy", f"Không tìm thấy tệp c25tool.py tại:\n{c25_path}\nVui lòng tải tệp về thư mục Downloads trước!")
                return

        cmd = f'start cmd /k "chcp 65001 >nul && set PYTHONIOENCODING=utf-8 && title C25 TOOL VIP INTEGRATION && py -3.12 \"{c25_path}\""'
        try:
            os.system(cmd)
            ModernSound.success()
            self.log(f"🚀 [C25 INTEGRATION] Đã khởi chạy C25 Tool trong cửa sổ CMD độc lập: {c25_path}")
        except Exception as e:
            messagebox.showerror("Lỗi khởi chạy", f"Không thể mở C25 Tool: {e}")
            self.log(f"❌ Lỗi mở C25 Tool: {e}")

    # ==================== PAGE 5: NETWORK DIAGNOSTICS ====================
    def build_page_diag(self) -> tk.Frame:
        p = tk.Frame(self.workspace, bg=UI["bg_main"], padx=15, pady=12)

        card = tk.Frame(p, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=16, pady=12)
        card.pack(fill="both", expand=True)

        top_f = tk.Frame(card, bg=UI["card"])
        top_f.pack(fill="x", pady=(0, 10))

        tk.Label(top_f, text="KIỂM TRA ĐỘ TRỄ MẠNG (PING BENCHMARK)", font=("Segoe UI", 9, "bold"), bg=UI["card"], fg=UI["text_primary"]).pack(side="left")
        btn_run_diag = tk.Button(top_f, text="🔍 Đo Tốc Độ", bg=UI["primary"], fg="#ffffff", font=("Segoe UI", 8, "bold"), bd=0, padx=14, pady=5, command=self.run_diag_task, cursor="hand2")
        btn_run_diag.pack(side="right")

        self.diag_tree = ttk.Treeview(card, columns=("target", "latency", "status"), show="headings")
        self.diag_tree.heading("target", text="Máy Chủ Kiểm Tra")
        self.diag_tree.heading("latency", text="Độ Trễ (Latency)")
        self.diag_tree.heading("status", text="Trạng Thái HTTP")
        self.diag_tree.pack(fill="both", expand=True)

        return p

    def run_diag_task(self):
        ModernSound.click()
        for r in self.diag_tree.get_children():
            self.diag_tree.delete(r)

        def task():
            res = NetworkDiagnostics.run_benchmark()
            for t in res.get("targets", []):
                lat = f"{t['latency_ms']} ms" if t['latency_ms'] >= 0 else "N/A"
                self.root.after(0, lambda target=t['name'], latency=lat, status=t['status']: self.diag_tree.insert("", "end", values=(target, latency, status)))
            ModernSound.success()

        threading.Thread(target=task, daemon=True).start()

    # ==================== PAGE 5: CÀI ĐẶT & KEY ====================
    def build_page_settings(self) -> tk.Frame:
        p = tk.Frame(self.workspace, bg=UI["bg_main"], padx=15, pady=12)

        # Card 1: Key
        k_card = tk.Frame(p, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=16, pady=12)
        k_card.pack(fill="x", pady=(0, 10))

        tk.Label(k_card, text="QUẢN LÝ BẢN QUYỀN VIP", font=("Segoe UI", 9, "bold"), bg=UI["card"], fg=UI["amber"]).grid(row=0, column=0, columnspan=4, sticky="w", pady=(0, 8))

        tk.Label(k_card, text="Mã Thiết Bị ID:", font=("Segoe UI", 8), bg=UI["card"], fg=UI["text_muted"]).grid(row=1, column=0, sticky="w", pady=4)
        tk.Label(k_card, text=KeyManager.get_machine_fingerprint(), font=("Consolas", 9, "bold"), bg=UI["card"], fg=UI["cyan"]).grid(row=1, column=1, sticky="w", pady=4)

        tk.Label(k_card, text="Nhập Key Kích Hoạt:", font=("Segoe UI", 8), bg=UI["card"], fg=UI["text_secondary"]).grid(row=2, column=0, sticky="w", pady=6)
        self.entry_key = tk.Entry(k_card, bg=UI["input_bg"], fg="#ffffff", font=("Consolas", 10), width=30, bd=1, relief="solid", highlightthickness=0)
        self.entry_key.grid(row=2, column=1, sticky="w", pady=6)

        btn_act = tk.Button(k_card, text="Kích Hoạt", bg=UI["emerald"], fg="#000000", font=("Segoe UI", 8, "bold"), bd=0, padx=12, pady=4, command=self.activate_key, cursor="hand2")
        btn_act.grid(row=2, column=2, padx=6, pady=6)

        btn_get = tk.Button(k_card, text="🌐 Lấy Key 24h", bg=UI["card_hover"], fg=UI["amber"], font=("Segoe UI", 8), bd=0, padx=12, pady=4, command=lambda: webbrowser.open(GET_KEY_URL), cursor="hand2")
        btn_get.grid(row=2, column=3, padx=6, pady=6)

        # Card 2: Config
        c_card = tk.Frame(p, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"], padx=16, pady=12)
        c_card.pack(fill="x")

        tk.Label(c_card, text="THAM SỐ HỆ THỐNG (CONFIG.JSON)", font=("Segoe UI", 9, "bold"), bg=UI["card"], fg=UI["primary"]).grid(row=0, column=0, columnspan=4, sticky="w", pady=(0, 8))

        tk.Label(c_card, text="Timeout (giây):", bg=UI["card"], fg=UI["text_secondary"]).grid(row=1, column=0, padx=5, pady=4)
        self.sp_timeout = tk.Spinbox(c_card, from_=10, to=60, width=5, bg=UI["input_bg"], fg="#ffffff")
        self.sp_timeout.delete(0, "end")
        self.sp_timeout.insert(0, str(ConfigManager.get("request_timeout", 25)))
        self.sp_timeout.grid(row=1, column=1, padx=5, pady=4)

        tk.Label(c_card, text="Max Retries:", bg=UI["card"], fg=UI["text_secondary"]).grid(row=1, column=2, padx=5, pady=4)
        self.sp_retries = tk.Spinbox(c_card, from_=1, to=10, width=5, bg=UI["input_bg"], fg="#ffffff")
        self.sp_retries.delete(0, "end")
        self.sp_retries.insert(0, str(ConfigManager.get("max_retries", 4)))
        self.sp_retries.grid(row=1, column=3, padx=5, pady=4)

        btn_save = tk.Button(c_card, text="💾 Lưu Cấu Hình", bg=UI["primary"], fg="#ffffff", font=("Segoe UI", 8, "bold"), bd=0, padx=14, pady=5, command=self.save_gui_config, cursor="hand2")
        btn_save.grid(row=1, column=4, padx=20, pady=4)

        return p

    def save_gui_config(self):
        ModernSound.click()
        try:
            ConfigManager.set("request_timeout", int(self.sp_timeout.get()))
            ConfigManager.set("max_retries", int(self.sp_retries.get()))
            ModernSound.success()
            messagebox.showinfo("Thành công", "Đã lưu cấu hình mới vào config.json!")
        except Exception as e:
            messagebox.showerror("Lỗi", f"Không thể lưu: {e}")

    def activate_key(self):
        ModernSound.click()
        k = self.entry_key.get().strip()
        if not k:
            messagebox.showwarning("Thông báo", "Vui lòng nhập Key!")
            return

        is_valid, msg, exp = KeyManager.verify_key(k)
        if is_valid:
            KeyManager.save_cached_key(k, exp)
            ModernSound.success()
            messagebox.showinfo("Thành công", f"Kích hoạt thành công!\n{msg}")
            self.log(f"✅ Đã kích hoạt bản quyền Key: {msg}")
        else:
            messagebox.showerror("Lỗi", f"Kích hoạt thất bại:\n{msg}")

    # ==================== 3. BOTTOM LIVE CONSOLE ====================
    def create_bottom_console(self):
        con_card = tk.Frame(self.root, bg=UI["card"], bd=1, relief="solid", highlightbackground=UI["card_border"])
        con_card.pack(fill="both", expand=True, padx=12, pady=(4, 6))

        top_f = tk.Frame(con_card, bg=UI["card"])
        top_f.pack(fill="x", padx=12, pady=4)

        tk.Label(top_f, text="NHẬT KÝ HOẠT ĐỘNG THỜI GIAN THỰC (LIVE CONSOLE)", font=("Segoe UI", 8, "bold"), bg=UI["card"], fg=UI["text_muted"]).pack(side="left")

        btn_clear = tk.Button(top_f, text="Xóa log", bg=UI["card_hover"], fg=UI["text_muted"], font=("Segoe UI", 7), bd=0, padx=8, pady=1, command=lambda: self.log_box.delete("1.0", tk.END), cursor="hand2")
        btn_clear.pack(side="right")

        self.log_box = scrolledtext.ScrolledText(con_card, bg=UI["console_bg"], fg=UI["cyan"], font=("Consolas", 9), height=5, bd=0, insertbackground=UI["cyan"])
        self.log_box.pack(fill="both", expand=True, padx=8, pady=(0, 6))

        # Tag màu trực quan Cyberpunk
        self.log_box.tag_config("ok",   foreground=UI["cyan"])
        self.log_box.tag_config("err",  foreground=UI["rose"])
        self.log_box.tag_config("warn", foreground=UI["amber"])
        self.log_box.tag_config("info", foreground=UI["purple"])
        self.log_box.tag_config("gray", foreground=UI["text_muted"])

    # ==================== 4. ANIMATION & TASK RUNNER ====================
    def animation_tick(self):
        self.anim_step += 1
        if self.current_tab == "services":
            self.draw_radar_gauge()
        self.root.after(35, self.animation_tick)

    def log(self, text: str):
        clean_text = re.sub(r'\x1b\[[0-9;]*[a-zA-Z]|\033\[[0-9;]*[a-zA-Z]|\[[0-9;]+m|\[0m', '', str(text))
        self.log_queue.put((f"[{datetime.datetime.now().strftime('%H:%M:%S')}] {clean_text}", clean_text))

    def process_log_queue(self):
        while not self.log_queue.empty():
            line, raw = self.log_queue.get_nowait()
            if any(x in raw for x in ["✅", "SUCCESS", "confirmed", "thành công", "OK", "+0", "+1", "+2", "+3", "+4", "+5", "+6", "+7", "+8", "+9"]):
                tag = "ok"
            elif any(x in raw for x in ["❌", "ERROR", "FAIL", "Lỗi", "403", "Forbidden", "thất bại"]):
                tag = "err"
            elif any(x in raw for x in ["⚠️", "WARNING", "Chờ", "ĐANG CHỜ", "Too many"]):
                tag = "warn"
            elif any(x in raw for x in ["💡", "🌐", "🍪", "🔄", "ℹ️", "Khởi động", "bắt đầu"]):
                tag = "info"
            else:
                tag = "ok"
            self.log_box.insert(tk.END, line + "\n", tag)
            self.log_box.see(tk.END)
        self.root.after(80, self.process_log_queue)

    def check_license_on_startup(self, license_ok: bool = False, license_msg: str = ""):
        if license_msg:
            self.log(f"{license_msg}")
        elif license_ok:
            self.log("✅ ĐÃ XÁC THỰC BẢN QUYỀN VIP")
        else:
            self.log("⚠️ Phiên bản chưa kích hoạt Key. Vào tab 'Cài đặt & Key' để kích hoạt VIP.")

    def start_service_task(self):
        ModernSound.click()
        url = self.entry_url.get().strip()
        if not url:
            messagebox.showwarning("Thông báo", "Vui lòng nhập liên kết TikTok!")
            return

        info = TikTokURLAnalyzer.analyze(url)
        if not info.is_valid or not info.target_id:
            messagebox.showerror("Lỗi", "Không nhận diện được ID TikTok từ liên kết này!")
            return

        selected_str = self.svc_var.get()
        if "Comment" in selected_str:
            svc_name = "comments"
        elif "Live" in selected_str:
            svc_name = "live"
        elif "Favorites" in selected_str or "Jas" in selected_str:
            svc_name = "favorites"
        elif "Tim" in selected_str or "Hearts" in selected_str:
            svc_name = "hearts"
        elif "Follow" in selected_str:
            svc_name = "followers"
        elif "Share" in selected_str:
            svc_name = "shares"
        else:
            svc_name = "views"

        t_val = self.entry_target.get().strip()
        target_count = int(t_val) if t_val.isdigit() else 0

        self.is_running = True
        self.btn_start.config(state="disabled")
        self.btn_stop.config(state="normal")
        self.status_pill.config(text="● ĐANG CHẠY", bg="#3b0718", fg=UI["rose"])

        selected_engine = self.engine_var.get()

        # TH1: Chạy Direct TikTok API Engine (3 sub-engine theo service)
        if "Direct" in selected_engine:
            script_dir = os.path.dirname(os.path.abspath(__file__))
            cookie_file = os.path.join(script_dir, "cookies.txt")
            proxy_file  = os.path.join(script_dir, "proxies.txt")
            cookie_pool = CookiePoolManager(cookie_file)
            proxy_pool  = ProxyPoolManager(proxy_file)

            needs_cookie = "heart" in svc_name or "follow" in svc_name
            if needs_cookie:
                if cookie_pool.is_ready():
                    self.log(f"🍪 [COOKIE POOL] Đã nạp {cookie_pool.count} tài khoản từ cookies.txt")
                else:
                    self.log(f"⚠️ [COOKIE POOL] KHÔNG tìm thấy cookies.txt! "
                             f"Engine Hearts/Follow cần sessionid thật → Đặt file tại: {cookie_file}")
            else:
                if proxy_pool.is_ready():
                    self.log(f"🌐 [PROXY POOL] Đã nạp {proxy_pool.count:,} proxy từ proxies.txt")
                else:
                    self.log(f"⚡ [DIRECT ENGINE] Chạy chế độ Direct IP (App API Endpoint)")

            def update_direct_stat(service_type: str, sent_count: int, speed: float):
                def _update():
                    if "heart" in service_type or "like" in service_type:
                        self.card_hearts.config(text=f"❤️ {sent_count:,} ({speed:.1f}/s)")
                    elif "follow" in service_type:
                        self.card_views.config(text=f"👤 {sent_count:,} ({speed:.1f}/s)")
                    elif "fav" in service_type:
                        self.card_favs.config(text=f"🔖 {sent_count:,} ({speed:.1f}/s)")
                    else:
                        self.card_views.config(text=f"👁️ {sent_count:,} ({speed:.1f}/s)")
                self.root.after(0, _update)

            is_safe = "An Toàn" in self.speed_mode_var.get()
            num_workers = 20 if is_safe else 100

            self.active_client = TikTokDirectApiEngine(
                target_id=info.target_id,
                service_name=svc_name,
                target_count=target_count,
                workers=num_workers,
                safe_mode=is_safe,
                cookie_pool=cookie_pool,
                proxy_pool=proxy_pool,
                log_callback=self.log,
                stat_callback=update_direct_stat,
            )

            def direct_runner():
                self.active_client.run()
                self.root.after(0, self._on_task_finished)

            threading.Thread(target=direct_runner, daemon=True).start()
            return

        # TH2: Chạy Zefoy Cloud Engine (Full 7 Dịch vụ)
        def update_gui_timer(current, total):
            self.countdown_current = current
            self.countdown_total = total
            if current == 0 and total > 0:
                ModernSound.success()

        self.active_client = ZefoyAutoOcrClient(
            target_url=info.resolved_url,
            service_name=svc_name,
            target_count=target_count,
            log_callback=self.log,
            timer_callback=update_gui_timer
        )

        def runner():
            self.log(f"🚀 KÍCH HOẠT DỊCH VỤ {svc_name.upper()} CHO ID: {info.target_id}")
            self.active_client.start_time = time.time()
            
            if not self.active_client.login_session():
                self.log("❌ Đăng nhập Zefoy Captcha thất bại!")
                self.root.after(0, self._on_task_finished)
                return

            if not self.active_client.check_service_status():
                self.log(f"⚠️ Dịch vụ {svc_name.upper()} đang bảo trì trên Zefoy!")
                self.root.after(0, self._on_task_finished)
                return

            while self.is_running and not self.active_client.stop_event.is_set():
                if target_count > 0 and self.active_client.total_confirmed >= target_count:
                    self.log(f"🎯 ĐÃ ĐẠT MỤC TIÊU {target_count:,} {svc_name.upper()} (CONFIRMED)!")
                    break
                self.active_client.run_cycle()

                confirmed = self.active_client.total_confirmed
                rounds = self.active_client.total_rounds
                def _update_zefoy_card(c=confirmed, r=rounds):
                    label = f"✅{c:,} ({r} vòng)"
                    if "heart" in svc_name:
                        self.card_hearts.config(text=label)
                    elif "fav" in svc_name:
                        self.card_favs.config(text=label)
                    else:
                        self.card_views.config(text=label)
                self.root.after(0, _update_zefoy_card)

            self.root.after(0, self._on_task_finished)

        threading.Thread(target=runner, daemon=True).start()

    def stop_service_task(self):
        ModernSound.click()
        self.is_running = False
        if self.active_client:
            self.active_client.stop_event.set()
        self.log("🛑 Đã gửi lệnh dừng dịch vụ.")

    def _on_refresh_proxy(self):
        """Auto-fetch proxy mới từ các nguồn public trong background."""
        ModernSound.click()
        self.btn_refresh_proxy.config(state="disabled", text="⏳ Đang tải...")
        self.log("🔄 [PROXY] Bắt đầu tải proxy từ 11 nguồn public...")

        script_dir = os.path.dirname(os.path.abspath(__file__))
        proxy_file = os.path.join(script_dir, "proxies.txt")

        def _fetch():
            pool = ProxyPoolManager(proxy_file)
            pool.auto_fetch(save_to_file=True, log_callback=self.log)
            self.root.after(0, lambda: self.btn_refresh_proxy.config(
                state="normal", text="🔄 Proxy"
            ))

        threading.Thread(target=_fetch, daemon=True).start()

    def _on_task_finished(self):
        self.is_running = False
        self.btn_start.config(state="normal")
        self.btn_stop.config(state="disabled")
        self.status_pill.config(text="● SẴN SÀNG", bg="#002b1f", fg=UI["emerald"])
        self.log("✨ Phiên làm việc đã kết thúc.")


def main():
    root = tk.Tk()
    root.withdraw()  # Ẩn cửa sổ chính lúc đầu

    def on_splash_done(license_ok, license_msg):
        root.deiconify()  # Hiện cửa sổ chính khi animation splash hoàn tất
        app = TLGBModernGUI(root)
        app.check_license_on_startup(license_ok, license_msg)

    SplashScreen(root, on_splash_done)
    root.mainloop()


if __name__ == "__main__":
    main()
