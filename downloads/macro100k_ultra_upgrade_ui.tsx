import React, { useState, useEffect } from "react";

export default function BunK11V8ControllerUI() {
  const [activeProfile, setActiveProfile] = useState<"BALANCED" | "PERFORMANCE" | "ULTRA">("ULTRA");
  const [telemetry, setTelemetry] = useState({
    fps: 120,
    oneLow: 118,
    ping: 18,
    temp: 38.5,
    cpu: 42,
    ram: "3.8 / 8 GB",
    sampling: "360 Hz",
  });
  const [logs, setLogs] = useState([
    { time: "13:28:01", tag: "CORE", type: "info", msg: "BUN K11 Controller v8.0 Online" },
    { time: "13:28:02", tag: "BACKUP", type: "success", msg: "Snapshot original settings saved" },
    { time: "13:28:03", tag: "AUTO_DETECT", type: "info", msg: "Free Fire package active" },
    { time: "13:28:04", tag: "PROFILE", type: "danger", msg: "Loaded ULTRA (120Hz + 2-Stage Drag)" },
    { time: "13:28:05", tag: "TOUCH", type: "success", msg: "Injected friction=0.0001 (360Hz)" },
    { time: "13:28:06", tag: "THERMAL", type: "info", msg: "Battery 38.5°C < 40°C (Optimal)" },
  ]);

  const [modules, setModules] = useState([
    { id: 1, tag: "01 • MASTER CORE", title: "BUN AI Master Core", status: "ONLINE", active: true },
    { id: 2, tag: "02 • AUTO DETECT", title: "Free Fire Detection", status: "MONITORING", active: true },
    { id: 3, tag: "03 • PROFILES", title: "Profile Switcher (3)", status: "ULTRA 120HZ", active: true },
    { id: 4, tag: "04 • PERFORMANCE", title: "120Hz & GPU Turbo", status: "MAX ENGINE", active: true },
    { id: 5, tag: "05 • THERMAL", title: "Thermal Guard Safe", status: "< 40°C OPTIMAL", active: true },
    { id: 6, tag: "06 • INPUT REGEDIT", title: "Ma Sát 0.0001 & 360Hz", status: "ZERO DELAY", active: true },
    { id: 7, tag: "07 • AIM LOCK", title: "Ghìm Đầu 2 Tầng (35ms)", status: "HEADSHOT 100%", active: true },
    { id: 8, tag: "08 • BACKUP", title: "Snapshot Pre-Game", status: "CAPTURED", active: true },
    { id: 9, tag: "09 • RESET", title: "Emergency Rollback", status: "STANDBY", active: true },
  ]);

  useEffect(() => {
    const interval = setInterval(() => {
      const baseFps = activeProfile === "ULTRA" ? 120 : activeProfile === "PERFORMANCE" ? 115 : 85;
      const jitterFps = baseFps - Math.floor(Math.random() * 3);
      setTelemetry((prev) => ({
        ...prev,
        fps: jitterFps,
        oneLow: jitterFps - 2,
        ping: 17 + Math.floor(Math.random() * 5),
        cpu: 38 + Math.floor(Math.random() * 8),
      }));
    }, 1000);
    return () => clearInterval(interval);
  }, [activeProfile]);

  const toggleModule = (id: number) => {
    setModules((prev) =>
      prev.map((m) => {
        if (m.id === id) {
          const nextActive = !m.active;
          const time = new Date().toTimeString().split(" ")[0];
          setLogs((l) => [
            ...l,
            {
              time,
              tag: "MODULE",
              type: nextActive ? "success" : "warn",
              msg: `Module 0${id} ${nextActive ? "ACTIVATED" : "PAUSED"}`,
            },
          ]);
          return { ...m, active: nextActive };
        }
        return m;
      })
    );
  };

  return (
    <div className="min-h-screen bg-[#030712] text-white p-6 font-sans antialiased relative isolate selection:bg-cyan-500/30">
      {/* Background Gradients */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_10%_20%,_rgba(255,0,85,0.12),_transparent_40%),radial-gradient(circle_at_90%_80%,_rgba(0,240,255,0.12),_transparent_45%)] pointer-events-none" />

      <div className="max-w-[1380px] mx-auto grid grid-cols-1 lg:grid-cols-[280px_1fr_340px] gap-5 items-start relative z-10">
        {/* Left Sidebar */}
        <aside className="bg-[#0a0f1d]/80 backdrop-blur-xl border border-cyan-500/20 rounded-2xl p-5 shadow-[0_20px_40px_rgba(0,0,0,0.6)]">
          <div className="flex items-center gap-3.5 pb-4 border-b border-white/10 mb-4">
            <img
              src="bunbunk11.png"
              alt="BUN K11 Logo"
              className="w-12 h-12 rounded-full object-cover border-2 border-cyan-400 shadow-[0_0_20px_rgba(0,240,255,0.5)]"
            />
            <div>
              <h2 className="font-bold text-white text-base tracking-wider">BUN K11 AI</h2>
              <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-bold bg-red-500/20 text-red-400 border border-red-500/30">
                <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse" /> RUNNING • v8.0
              </span>
            </div>
          </div>

          {/* AI Radar */}
          <div className="text-center my-3">
            <p className="text-[11px] text-gray-400 font-semibold tracking-wider">AI TACTICAL RADAR</p>
            <div className="relative w-32 h-32 mx-auto my-2 rounded-full border border-cyan-400/30 bg-cyan-500/5 flex items-center justify-center overflow-hidden">
              <div className="absolute inset-0 border border-dashed border-cyan-400/20 rounded-full scale-75" />
              <div className="absolute top-0 right-0 w-16 h-16 bg-[conic-gradient(from_0deg,_rgba(0,240,255,0.4),_transparent_90deg)] rounded-tl-full origin-bottom-left animate-spin" />
              <span className="text-[10px] font-bold text-cyan-400 z-10">FF ACTIVE</span>
            </div>
            <p className="text-xs font-semibold text-emerald-400">com.dts.freefiremax</p>
          </div>

          {/* Profile Switcher */}
          <div className="mt-4">
            <p className="text-[11px] text-gray-400 font-semibold mb-2">CHỌN PROFILE NHANH</p>
            <div className="grid grid-cols-3 gap-2">
              {(["ULTRA", "PERFORMANCE", "BALANCED"] as const).map((p) => (
                <button
                  key={p}
                  onClick={() => setActiveProfile(p)}
                  className={`p-2 rounded-xl border text-center transition-all ${
                    activeProfile === p
                      ? p === "ULTRA"
                        ? "bg-red-500/20 border-red-500 text-red-400 shadow-[0_0_15px_rgba(255,0,85,0.4)]"
                        : p === "PERFORMANCE"
                        ? "bg-cyan-500/20 border-cyan-400 text-cyan-400 shadow-[0_0_15px_rgba(0,240,255,0.4)]"
                        : "bg-amber-500/20 border-amber-400 text-amber-400 shadow-[0_0_15px_rgba(245,158,11,0.4)]"
                      : "bg-white/5 border-white/10 text-gray-400 hover:bg-white/10"
                  }`}
                >
                  <div className="text-[11px] font-black">{p === "PERFORMANCE" ? "PERF" : p === "BALANCED" ? "ECO" : p}</div>
                  <div className="text-[9px] opacity-70">{p === "ULTRA" ? "120 FPS" : p === "PERFORMANCE" ? "90-120" : "60 FPS"}</div>
                </button>
              ))}
            </div>
          </div>

          {/* Actions */}
          <div className="mt-5 space-y-2">
            <button className="w-full py-3 rounded-xl bg-gradient-to-r from-red-600 to-pink-600 text-white font-black text-sm tracking-wider shadow-[0_0_20px_rgba(255,0,85,0.4)] hover:brightness-110 active:scale-[0.98] transition-all">
              🔥 1-TAP OPTIMIZE
            </button>
            <button className="w-full py-2.5 rounded-xl bg-white/5 border border-white/10 text-gray-300 font-bold text-xs tracking-wider hover:bg-white/10 transition-all">
              🔴 EMERGENCY RESTORE
            </button>
          </div>
        </aside>

        {/* Center Main Content */}
        <main className="bg-[#0a0f1d]/80 backdrop-blur-xl border border-cyan-500/20 rounded-2xl p-6 shadow-[0_20px_40px_rgba(0,0,0,0.6)]">
          <div className="flex justify-between items-center mb-5">
            <div>
              <p className="text-[11px] text-cyan-400 font-bold tracking-widest">ESPORTS HARDWARE CONTROLLER</p>
              <h1 className="text-2xl font-black tracking-wide text-white">BẢNG ĐIỀU KHIỂN 9 MODULE TOÀN DIỆN</h1>
            </div>
            <span className="px-3 py-1 rounded-full text-xs font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">
              THERMAL: 38.5°C • OPTIMAL
            </span>
          </div>

          {/* Telemetry Grid */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-5">
            <div className="bg-white/[0.03] border border-white/5 rounded-xl p-3.5">
              <p className="text-[10px] text-gray-400 tracking-wider">FPS RUNTIME</p>
              <p className="text-2xl font-black text-cyan-400 mt-1">{telemetry.fps}</p>
              <p className="text-[10px] text-gray-500 mt-1">1% Low: {telemetry.oneLow} FPS</p>
            </div>
            <div className="bg-white/[0.03] border border-white/5 rounded-xl p-3.5">
              <p className="text-[10px] text-gray-400 tracking-wider">NETWORK PING</p>
              <p className="text-2xl font-black text-emerald-400 mt-1">{telemetry.ping} ms</p>
              <p className="text-[10px] text-gray-500 mt-1">Jitter: 0.8ms</p>
            </div>
            <div className="bg-white/[0.03] border border-white/5 rounded-xl p-3.5">
              <p className="text-[10px] text-gray-400 tracking-wider">CPU LOAD</p>
              <p className="text-2xl font-black text-amber-400 mt-1">{telemetry.cpu}%</p>
              <p className="text-[10px] text-gray-500 mt-1">RAM: {telemetry.ram}</p>
            </div>
            <div className="bg-white/[0.03] border border-white/5 rounded-xl p-3.5">
              <p className="text-[10px] text-gray-400 tracking-wider">SAMPLING</p>
              <p className="text-2xl font-black text-rose-400 mt-1">{telemetry.sampling}</p>
              <p className="text-[10px] text-gray-500 mt-1">Touch Delay: 0ms</p>
            </div>
          </div>

          {/* 9 Modules Matrix */}
          <h3 className="text-xs font-bold text-gray-400 tracking-wider mb-3">9 MODULES TRONG BẢN MACRO V8</h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
            {modules.map((m) => (
              <div
                key={m.id}
                className={`p-3.5 rounded-xl border transition-all flex flex-col justify-between ${
                  m.active
                    ? "bg-white/[0.04] border-cyan-500/30 shadow-[0_0_15px_rgba(0,240,255,0.08)]"
                    : "bg-white/[0.01] border-white/5 opacity-50"
                }`}
              >
                <div>
                  <span className="text-[10px] font-bold text-cyan-400">{m.tag}</span>
                  <p className="text-sm font-bold text-white mt-1">{m.title}</p>
                </div>
                <div className="flex justify-between items-center mt-3 pt-2 border-t border-white/5">
                  <span className="text-[10px] font-bold text-emerald-400">{m.status}</span>
                  <button
                    onClick={() => toggleModule(m.id)}
                    className={`w-10 h-5 rounded-full relative transition-colors ${
                      m.active ? "bg-cyan-500" : "bg-gray-700"
                    }`}
                  >
                    <span
                      className={`block w-3.5 h-3.5 rounded-full bg-white transition-transform ${
                        m.active ? "translate-x-5" : "translate-x-1"
                      }`}
                    />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </main>

        {/* Right Sidebar: Live Console */}
        <aside className="bg-[#0a0f1d]/80 backdrop-blur-xl border border-red-500/20 rounded-2xl p-5 shadow-[0_20px_40px_rgba(0,0,0,0.6)]">
          <div className="flex justify-between items-center mb-3">
            <h3 className="font-bold text-sm text-white tracking-wider">LIVE CONSOLE STREAM</h3>
            <span className="text-[10px] font-bold text-emerald-400 flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping" /> LOGGING
            </span>
          </div>

          <div className="bg-[#020409] border border-cyan-500/20 rounded-xl p-3 font-mono text-[11px] h-64 overflow-y-auto space-y-1.5">
            {logs.map((l, idx) => (
              <div key={idx} className="flex gap-2">
                <span className="text-gray-500">[{l.time}]</span>
                <span
                  className={`font-bold ${
                    l.type === "success"
                      ? "text-emerald-400"
                      : l.type === "danger"
                      ? "text-red-400"
                      : l.type === "warn"
                      ? "text-amber-400"
                      : "text-cyan-400"
                  }`}
                >
                  [{l.tag}]
                </span>
                <span className="text-gray-300">{l.msg}</span>
              </div>
            ))}
          </div>

          <div className="mt-4 bg-white/[0.02] border border-white/5 rounded-xl p-3 font-mono text-xs space-y-2">
            <div className="flex justify-between">
              <span className="text-gray-500">pointer_speed</span>
              <span className="text-cyan-400 font-bold">7 (Max)</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-500">view_scroll_friction</span>
              <span className="text-red-400 font-bold">0.0001</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-500">peak_refresh_rate</span>
              <span className="text-emerald-400 font-bold">120.0 Hz</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-500">head_lock_engine</span>
              <span className="text-pink-400 font-bold">2-Stage (35ms)</span>
            </div>
          </div>
        </aside>
      </div>
    </div>
  );
}
