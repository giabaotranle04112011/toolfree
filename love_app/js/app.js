/**
 * LOVE COUPLE APP - MAIN APPLICATION CONTROLLER
 */

class LoveApp {
  constructor() {
    this.currentTab = 'home';
    this.particleAnimationId = null;
    this.particles = [];
    this.pinEntered = '';
  }

  init() {
    console.log('Initializing Love App...');

    // 1. Apply Saved Theme & Background
    this.applyTheme();
    this.initParticleCanvas();

    // 2. Initialize Love Counter Real-time loop
    window.loveCounter.start((data) => this.renderCounterUI(data));

    // 3. Setup Navigation Tabs
    this.setupNav();

    // 4. Setup Connection & WebRTC Listeners
    this.setupConnectionHandlers();

    // 5. Initial Renders
    this.renderProfileUI();
    this.renderMilestonesUI();
    this.renderBucketList();
    this.renderLoveReasons();

    // 6. Setup Audio Toggle Button
    const audioBtn = document.getElementById('btn-bgm-toggle');
    if (audioBtn) {
      audioBtn.addEventListener('click', () => {
        const isPlaying = window.loveAudio.toggleBgm();
        audioBtn.classList.toggle('active', isPlaying);
        this.showToast(isPlaying ? '🎵 Đã bật nhạc nền lãng mạn' : '🔇 Đã tắt nhạc');
      });
    }

    // 7. Auto check if roomCode exists to start Peer
    window.loveConnection.init();

    // 8. Listen for Storage Changes
    window.addEventListener('loveDataChanged', () => {
      this.renderProfileUI();
      this.renderMilestonesUI();
      this.applyTheme();
      if (window.loveMap && window.loveMap.map) {
        window.loveMap.updateMarkers();
      }
    });

    console.log('Love App ready!');
  }

  /* ----------------------------------------------------
     THEME & PARTICLE ENGINE
     ---------------------------------------------------- */
  applyTheme() {
    const data = window.loveStorage.get();
    document.body.setAttribute('data-theme', data.theme || 'pink');

    const overlay = document.getElementById('custom-bg-overlay');
    if (overlay) {
      if (data.customBg) {
        overlay.style.backgroundImage = `url(${data.customBg})`;
        overlay.classList.add('active');
      } else {
        overlay.classList.remove('active');
      }
    }
  }

  setTheme(themeName) {
    window.loveStorage.update({ theme: themeName });
    this.applyTheme();
    this.showToast(`🎨 Đã đổi giao diện: ${themeName}`);
  }

  setParticleEffect(effectName) {
    window.loveStorage.update({ particleEffect: effectName });
    this.initParticleCanvas();
    this.showToast(`✨ Đã đổi hiệu ứng: ${effectName}`);
  }

  initParticleCanvas() {
    const canvas = document.getElementById('particle-canvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };
    window.addEventListener('resize', resize);
    resize();

    const data = window.loveStorage.get();
    const effect = data.particleEffect || 'hearts';

    if (effect === 'none') {
      if (this.particleAnimationId) cancelAnimationFrame(this.particleAnimationId);
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      return;
    }

    this.particles = [];
    const count = window.innerWidth < 768 ? 20 : 35;
    for (let i = 0; i < count; i++) {
      this.particles.push(this.createParticle(canvas.width, canvas.height, effect));
    }

    if (this.particleAnimationId) cancelAnimationFrame(this.particleAnimationId);

    const loop = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      this.particles.forEach(p => {
        p.y += p.speedY;
        p.x += p.speedX;
        p.rot += p.rotSpeed;

        if (p.y > canvas.height + 20 || p.x < -20 || p.x > canvas.width + 20) {
          p.y = -20;
          p.x = Math.random() * canvas.width;
        }

        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate(p.rot);
        ctx.globalAlpha = p.opacity;

        if (effect === 'hearts') {
          ctx.font = `${p.size}px sans-serif`;
          ctx.fillText('💖', 0, 0);
        } else if (effect === 'petals') {
          ctx.fillStyle = '#ff7597';
          ctx.beginPath();
          ctx.ellipse(0, 0, p.size, p.size / 2, Math.PI / 4, 0, 2 * Math.PI);
          ctx.fill();
        } else if (effect === 'stars') {
          ctx.font = `${p.size}px sans-serif`;
          ctx.fillText('✨', 0, 0);
        } else if (effect === 'snow') {
          ctx.fillStyle = '#ffffff';
          ctx.beginPath();
          ctx.arc(0, 0, p.size / 3, 0, 2 * Math.PI);
          ctx.fill();
        }
        ctx.restore();
      });

      this.particleAnimationId = requestAnimationFrame(loop);
    };

    loop();
  }

  createParticle(w, h, effect) {
    return {
      x: Math.random() * w,
      y: Math.random() * h,
      size: 10 + Math.random() * 14,
      speedY: 0.8 + Math.random() * 1.5,
      speedX: (Math.random() - 0.5) * 0.8,
      rot: Math.random() * Math.PI * 2,
      rotSpeed: (Math.random() - 0.5) * 0.04,
      opacity: 0.3 + Math.random() * 0.5
    };
  }

  /* ----------------------------------------------------
     NAVIGATION ROUTER
     ---------------------------------------------------- */
  setupNav() {
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
      item.addEventListener('click', (e) => {
        e.preventDefault();
        const tab = item.getAttribute('data-tab');
        this.switchTab(tab);
      });
    });
  }

  switchTab(tabName) {
    this.currentTab = tabName;

    // Update bottom nav active state
    document.querySelectorAll('.nav-item').forEach(btn => {
      btn.classList.toggle('active', btn.getAttribute('data-tab') === tabName);
    });

    // Update tab panes
    document.querySelectorAll('.tab-pane').forEach(pane => {
      pane.classList.remove('active');
    });
    const targetPane = document.getElementById(`tab-${tabName}`);
    if (targetPane) {
      targetPane.classList.add('active');
    }

    // Tab-specific lazy initializations
    if (tabName === 'map') {
      setTimeout(() => {
        window.loveMap.init();
        if (window.loveMap.map) window.loveMap.map.invalidateSize();
      }, 100);
    } else if (tabName === 'pair') {
      this.renderPairUI();
    } else if (tabName === 'diary') {
      window.loveDiary.init();
    } else if (tabName === 'games') {
      window.loveGames.initWheel();
    } else if (tabName === 'card') {
      window.loveCard.init();
    }
  }

  /* ----------------------------------------------------
     RENDER HOMEPAGE COUNTER & PROFILES
     ---------------------------------------------------- */
  renderProfileUI() {
    const data = window.loveStorage.get();

    // User elements
    const uName = document.getElementById('user-name');
    const uTag = document.getElementById('user-tag');
    const uAvatar = document.getElementById('user-avatar');
    if (uName) uName.textContent = data.user.name || 'Anh Yêu';
    if (uTag) uTag.textContent = data.user.zodiac || window.loveCounter.getZodiac(data.user.birthday) || 'Bae';
    if (uAvatar) uAvatar.src = data.user.avatar;

    // Partner elements
    const pName = document.getElementById('partner-name');
    const pTag = document.getElementById('partner-tag');
    const pAvatar = document.getElementById('partner-avatar');
    if (pName) pName.textContent = data.partner.name || 'Em Yêu';
    if (pTag) pTag.textContent = data.partner.zodiac || window.loveCounter.getZodiac(data.partner.birthday) || 'Honey';
    if (pAvatar) pAvatar.src = data.partner.avatar;

    // Bio & Love since
    const bioEl = document.getElementById('home-relationship-bio');
    if (bioEl) bioEl.textContent = `"${data.bio}"`;

    const sinceEl = document.getElementById('love-since-date');
    if (sinceEl) sinceEl.textContent = `Bắt đầu: ${window.loveCounter.formatDateVN(data.startDate)}`;

    // Total hearts
    const heartCountEl = document.getElementById('total-hearts-count');
    if (heartCountEl) heartCountEl.textContent = (data.totalHeartsSent || 0).toLocaleString();
  }

  renderCounterUI(data) {
    const bigDaysEl = document.getElementById('counter-days-num');
    if (bigDaysEl) bigDaysEl.textContent = data.totalDays;

    const yEl = document.getElementById('counter-years-val');
    const mEl = document.getElementById('counter-months-val');
    const dEl = document.getElementById('counter-days-val');
    const sEl = document.getElementById('counter-secs-val');

    if (yEl) yEl.textContent = data.years;
    if (mEl) mEl.textContent = data.months;
    if (dEl) dEl.textContent = data.days;
    if (sEl) sEl.textContent = `${data.hours}:${data.minutes}:${data.seconds}`;
  }

  /* ----------------------------------------------------
     HEART TAP INTERACTION
     ---------------------------------------------------- */
  tapHeart(event) {
    const data = window.loveStorage.get();
    const count = (data.totalHeartsSent || 0) + 1;
    window.loveStorage.update({ totalHeartsSent: count });

    const heartCountEl = document.getElementById('total-hearts-count');
    if (heartCountEl) heartCountEl.textContent = count.toLocaleString();

    if (window.loveAudio) window.loveAudio.playHeartPop();

    // Floating heart animation
    const x = event ? (event.clientX || event.pageX) : window.innerWidth / 2;
    const y = event ? (event.clientY || event.pageY) : window.innerHeight / 2;
    this.createFloatingHeart(x, y);

    // Send to partner if online
    if (window.loveConnection && window.loveConnection.isConnected) {
      window.loveConnection.sendHeartBurst(1);
    }
  }

  createFloatingHeart(x, y, emoji = '💖') {
    const el = document.createElement('div');
    el.className = 'floating-love-heart';
    el.textContent = emoji;
    el.style.left = `${x - 16}px`;
    el.style.top = `${y - 16}px`;
    el.style.fontSize = `${24 + Math.random() * 16}px`;
    el.style.setProperty('--tx', `${(Math.random() - 0.5) * 80}px`);
    el.style.setProperty('--rot', `${(Math.random() - 0.5) * 45}deg`);

    document.body.appendChild(el);
    setTimeout(() => el.remove(), 1600);
  }

  /* ----------------------------------------------------
     MILESTONES
     ---------------------------------------------------- */
  renderMilestonesUI() {
    const container = document.getElementById('milestone-list-container');
    if (!container) return;

    const milestones = window.loveCounter.getMilestones();
    container.innerHTML = milestones.map(m => `
      <div class="milestone-item ${m.isReached ? 'reached' : 'upcoming'}">
        <div class="ms-info">
          <div class="ms-title"><span>${m.icon}</span> ${m.title}</div>
          <div class="ms-date">${m.dateStr}</div>
        </div>
        <div>
          ${m.isReached 
            ? '<span class="ms-badge" style="color: #10b981;">✓ Đã đạt được</span>' 
            : `<span class="ms-badge active-countdown">Còn ${m.daysLeft} ngày</span>`
          }
        </div>
      </div>
    `).join('');
  }

  /* ----------------------------------------------------
     SECRET LETTERS & PIN LOCK
     ---------------------------------------------------- */
  renderSecretLetters() {
    const container = document.getElementById('secret-letters-list');
    if (!container) return;
    const data = window.loveStorage.get();
    const letters = data.secretLetters || [];

    if (letters.length === 0) {
      container.innerHTML = `
        <div style="text-align: center; padding: 24px; color: var(--text-muted);">
          Chưa có bức thư tình nào. Bấm "+ Viết thư tình" để gửi gắm lời yêu thương!
        </div>
      `;
      return;
    }

    container.innerHTML = letters.map(l => `
      <div class="glass-card" style="margin-bottom: 12px; border-left: 4px solid var(--primary-light);">
        <div style="display: flex; justify-content: space-between; font-size: 11px; color: var(--text-muted); margin-bottom: 6px;">
          <span>💌 ${l.date}</span>
          <button onclick="window.loveApp.deleteLetter('${l.id}')" style="background: none; border: none; color: var(--text-muted); cursor: pointer;">Xóa</button>
        </div>
        <h4 style="color: #fff; font-size: 14px; margin-bottom: 6px;">${l.title}</h4>
        <p style="font-size: 13px; color: var(--text-sub); line-height: 1.6; white-space: pre-wrap;">${l.content}</p>
      </div>
    `).join('');
  }

  unlockLetters() {
    const data = window.loveStorage.get();
    const pin = document.getElementById('pin-input-field').value;
    
    // If no pin was set, or pin matches
    if (!data.securityPin || pin === data.securityPin) {
      document.getElementById('letters-lock-screen').style.display = 'none';
      document.getElementById('letters-unlocked-screen').style.display = 'block';
      this.renderSecretLetters();
      if (window.loveAudio) window.loveAudio.playSuccess();
    } else {
      this.showToast('❌ Mã PIN không đúng! Vui lòng thử lại.');
      if (window.navigator.vibrate) window.navigator.vibrate(200);
    }
  }

  addSecretLetter(title, content) {
    const data = window.loveStorage.get();
    const newLetter = {
      id: 'l-' + Date.now(),
      title: title || 'Thư gửi người anh yêu',
      date: new Date().toISOString().split('T')[0],
      content: content || ''
    };
    const secretLetters = [newLetter, ...(data.secretLetters || [])];
    window.loveStorage.update({ secretLetters });
    this.renderSecretLetters();
    this.showToast('💌 Đã lưu thư tình bí mật!');
  }

  deleteLetter(id) {
    if (!confirm('Bạn có muốn xóa bức thư này không?')) return;
    const data = window.loveStorage.get();
    const secretLetters = (data.secretLetters || []).filter(l => l.id !== id);
    window.loveStorage.update({ secretLetters });
    this.renderSecretLetters();
  }

  /* ----------------------------------------------------
     BUCKET LIST
     ---------------------------------------------------- */
  renderBucketList() {
    const container = document.getElementById('bucket-list-container');
    if (!container) return;
    const data = window.loveStorage.get();
    const list = data.bucketList || [];

    const completedCount = list.filter(b => b.completed).length;
    const percent = list.length > 0 ? Math.round((completedCount / list.length) * 100) : 0;

    const progressEl = document.getElementById('bucket-progress-text');
    if (progressEl) progressEl.textContent = `Đã hoàn thành: ${completedCount}/${list.length} (${percent}%)`;

    container.innerHTML = list.map(b => `
      <div class="bucket-item ${b.completed ? 'completed' : ''}" onclick="window.loveApp.toggleBucketItem('${b.id}')">
        <div class="bucket-checkbox">${b.completed ? '✓' : ''}</div>
        <div class="bucket-text">${b.text}</div>
      </div>
    `).join('');
  }

  toggleBucketItem(id) {
    const data = window.loveStorage.get();
    const bucketList = (data.bucketList || []).map(b => {
      if (b.id === id) {
        return { ...b, completed: !b.completed };
      }
      return b;
    });
    window.loveStorage.update({ bucketList });
    this.renderBucketList();
    if (window.loveAudio) window.loveAudio.playHeartPop();
  }

  addBucketItem(text) {
    if (!text.trim()) return;
    const data = window.loveStorage.get();
    const newItem = {
      id: 'b-' + Date.now(),
      text: text.trim(),
      completed: false
    };
    const bucketList = [...(data.bucketList || []), newItem];
    window.loveStorage.update({ bucketList });
    this.renderBucketList();
    this.showToast('✨ Đã thêm mục tiêu mới vào Bucket List!');
  }

  /* ----------------------------------------------------
     100 REASONS WHY I LOVE YOU
     ---------------------------------------------------- */
  renderLoveReasons() {
    const container = document.getElementById('love-reasons-container');
    if (!container) return;
    const data = window.loveStorage.get();
    const reasons = data.loveReasons || [];

    container.innerHTML = reasons.map((r, i) => `
      <div style="display: flex; gap: 8px; align-items: flex-start; padding: 10px 12px; background: var(--bg-glass); border-radius: 12px; border: 1px solid var(--border-glass); margin-bottom: 8px;">
        <span style="color: var(--primary-light); font-weight: 800; font-size: 12px;">#${i + 1}</span>
        <span style="font-size: 13px; color: var(--text-main); line-height: 1.4;">${r}</span>
      </div>
    `).join('');
  }

  addLoveReason(text) {
    if (!text.trim()) return;
    const data = window.loveStorage.get();
    const loveReasons = [...(data.loveReasons || []), text.trim()];
    window.loveStorage.update({ loveReasons });
    this.renderLoveReasons();
    this.showToast('💖 Đã thêm lý do yêu thương!');
  }

  /* ----------------------------------------------------
     ONLINE PAIRING & REALTIME ACTIONS
     ---------------------------------------------------- */
  renderPairUI() {
    const data = window.loveStorage.get();
    const codeEl = document.getElementById('my-room-code-display');
    if (codeEl) {
      codeEl.textContent = window.loveConnection.myPeerId || data.roomCode || 'LOVE-8888';
    }
  }

  copyRoomCode() {
    const code = window.loveConnection.myPeerId;
    navigator.clipboard.writeText(code).then(() => {
      this.showToast('📋 Đã sao chép mã kết nối: ' + code);
    });
  }

  connectPartnerFromInput() {
    const input = document.getElementById('partner-code-input');
    if (!input || !input.value.trim()) {
      this.showToast('⚠️ Vui lòng nhập mã cặp đôi của đối phương!');
      return;
    }
    const success = window.loveConnection.connectToPartner(input.value.trim());
    if (success) {
      this.showToast('🔄 Đang gửi yêu cầu kết nối...');
    }
  }

  setupConnectionHandlers() {
    // 1. Status change handler
    window.loveConnection.callbacks.onStatusChange = (connected, statusText) => {
      const badge = document.getElementById('header-status-badge');
      const badgeText = document.getElementById('header-status-text');
      const pairBanner = document.getElementById('pairing-status-banner');

      if (badge && badgeText) {
        badge.className = `status-badge ${connected ? 'connected' : 'online'}`;
        badgeText.textContent = connected ? 'Đã kết nối ❤️' : 'Trực tuyến';
      }
      if (pairBanner) {
        pairBanner.innerHTML = connected 
          ? `<span style="color: #10b981; font-weight: 700;">🟢 Đang kết nối trực tuyến với đối phương!</span>`
          : `<span style="color: var(--text-muted);">${statusText}</span>`;
      }
      this.showToast(statusText);
    };

    // 2. Battery status update
    window.loveConnection.callbacks.onPartnerBattery = (level, isCharging) => {
      const el = document.getElementById('partner-battery-display');
      if (el) {
        el.style.display = 'inline-flex';
        el.innerHTML = `🔋 ${level}% ${isCharging ? '⚡' : ''}`;
      }
    };

    // 3. Heart burst from partner
    window.loveConnection.callbacks.onHeartBurst = () => {
      if (window.loveAudio) window.loveAudio.playHeartPop();
      if (window.navigator.vibrate) window.navigator.vibrate([80, 50, 80]);

      for (let i = 0; i < 15; i++) {
        setTimeout(() => {
          this.createFloatingHeart(
            Math.random() * window.innerWidth,
            window.innerHeight * 0.7,
            ['💖', '💕', '💘', '💗', '❤️'][Math.floor(Math.random() * 5)]
          );
        }, i * 70);
      }
      this.showToast('💖 Đối phương vừa gửi một chùm tim yêu thương!');
    };

    // 4. Virtual Kiss
    window.loveConnection.callbacks.onVirtualKiss = (payload) => {
      if (window.loveAudio) window.loveAudio.playKiss();
      if (window.navigator.vibrate) window.navigator.vibrate([200, 100, 300]);

      this.showFullScreenActionModal('💋 Nụ hôn nồng cháy!', `Người yêu vừa gửi đến bạn một nụ hôn ngọt ngào!`, '💋');
    };

    // 5. Virtual Hug
    window.loveConnection.callbacks.onVirtualHug = (payload) => {
      if (window.loveAudio) window.loveAudio.playSuccess();
      if (window.navigator.vibrate) window.navigator.vibrate([150, 100, 150]);

      this.showFullScreenActionModal('🫂 Cái ôm ấm áp!', `Người yêu vừa ôm bạn một cái thật chặt từ xa!`, '🫂');
    };

    // 6. Poke
    window.loveConnection.callbacks.onPoke = (payload) => {
      if (window.loveAudio) window.loveAudio.playPokeChime();
      if (window.navigator.vibrate) window.navigator.vibrate([100, 100, 100]);
      this.showToast('💓 Cốc cốc! Người ấy đang gõ cửa trái tim bạn!');
    };

    // 7. Quick Message
    window.loveConnection.callbacks.onQuickMessage = (payload) => {
      if (window.loveAudio) window.loveAudio.playPokeChime();
      this.showFullScreenActionModal('💌 Lời nhắn yêu thương', `"${payload.text}"`, '🥰');
    };

    // 8. Data sync
    window.loveConnection.callbacks.onDataSynced = (payload) => {
      if (payload.type === 'new-memory' && payload.memory) {
        const data = window.loveStorage.get();
        const memories = [payload.memory, ...(data.memories || [])];
        window.loveStorage.update({ memories });
        if (window.loveDiary) window.loveDiary.render();
        this.showToast('✨ Đã đồng bộ 1 kỷ niệm mới từ người yêu!');
      }
    };
  }

  showFullScreenActionModal(title, message, emoji) {
    const modal = document.createElement('div');
    modal.className = 'modal-backdrop active';
    modal.innerHTML = `
      <div class="modal-content" style="text-align: center; padding: 32px 20px; animation: fadeInTab 0.3s ease;">
        <div style="font-size: 64px; animation: heartPulse 1.2s infinite; margin-bottom: 12px;">${emoji}</div>
        <h3 style="font-size: 20px; color: #fff; margin-bottom: 8px;">${title}</h3>
        <p style="font-size: 14px; color: var(--text-sub); margin-bottom: 20px;">${message}</p>
        <button class="app-btn" onclick="this.closest('.modal-backdrop').remove()">Đón nhận ❤️</button>
      </div>
    `;
    document.body.appendChild(modal);
    if (window.confetti) window.confetti({ particleCount: 70, spread: 70, origin: { y: 0.5 } });
  }

  /* ----------------------------------------------------
     TOAST NOTIFICATIONS
     ---------------------------------------------------- */
  showToast(message) {
    let toast = document.getElementById('app-love-toast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'app-love-toast';
      toast.className = 'love-toast';
      document.body.appendChild(toast);
    }
    toast.innerHTML = message;
    toast.classList.add('show');

    clearTimeout(this.toastTimer);
    this.toastTimer = setTimeout(() => {
      toast.classList.remove('show');
    }, 2800);
  }
}

window.loveApp = new LoveApp();

// Boot up once DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  window.loveApp.init();
});
