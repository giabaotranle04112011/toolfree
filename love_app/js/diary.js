/**
 * LOVE COUPLE APP - LOVE DIARY & MEMORIES TIMELINE
 */

class LoveDiaryEngine {
  constructor() {
    this.container = null;
  }

  init(containerId = 'diary-timeline-container') {
    this.container = document.getElementById(containerId);
    this.render();
  }

  render(filterMood = 'all', searchQuery = '') {
    if (!this.container) return;
    const data = window.loveStorage.get();
    let memories = data.memories || [];

    // Filter by mood
    if (filterMood !== 'all') {
      memories = memories.filter(m => m.mood && m.mood.includes(filterMood));
    }

    // Filter by search query
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      memories = memories.filter(m => 
        (m.title && m.title.toLowerCase().includes(q)) || 
        (m.content && m.content.toLowerCase().includes(q))
      );
    }

    // Sort newest first
    memories.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    if (memories.length === 0) {
      this.container.innerHTML = `
        <div style="text-align: center; padding: 32px 16px; color: var(--text-muted);">
          <div style="font-size: 36px; margin-bottom: 8px;">📖✨</div>
          <p style="font-size: 14px; font-weight: 600;">Chưa có kỷ niệm nào được lưu</p>
          <p style="font-size: 12px; margin-top: 4px;">Hãy bấm "Viết kỷ niệm mới" để lưu giữ khoảnh khắc ngọt ngào của 2 bạn nhé!</p>
        </div>
      `;
      return;
    }

    this.container.innerHTML = memories.map(m => `
      <div class="diary-card">
        <div class="diary-meta">
          <span style="font-weight: 700; color: var(--primary-light);">${this.formatDate(m.date)}</span>
          <span style="background: var(--bg-glass-strong); padding: 2px 8px; border-radius: 12px;">${m.mood || '❤️ Yêu thương'}</span>
        </div>
        <h4 style="font-size: 14px; font-weight: 700; color: #fff; margin-bottom: 6px;">${this.escapeHTML(m.title)}</h4>
        <p class="diary-text">${this.escapeHTML(m.content)}</p>
        ${m.image ? `<img src="${m.image}" class="diary-img-preview" alt="Kỷ niệm" onclick="window.open('${m.image}', '_blank')"/>` : ''}
        <div style="display: flex; justify-content: flex-end; margin-top: 8px;">
          <button onclick="window.loveDiary.deleteMemory('${m.id}')" style="background: none; border: none; color: var(--text-muted); font-size: 11px; cursor: pointer; display: flex; align-items: center; gap: 4px;">
            <i class="icon-trash"></i> Xóa
          </button>
        </div>
      </div>
    `).join('');
  }

  addMemory(title, date, mood, content, imageBase64) {
    const data = window.loveStorage.get();
    const newMemory = {
      id: 'mem-' + Date.now(),
      title: title || 'Kỷ niệm ngọt ngào',
      date: date || new Date().toISOString().split('T')[0],
      mood: mood || '🥰 Hạnh phúc',
      content: content || '',
      image: imageBase64 || ''
    };

    const memories = [newMemory, ...(data.memories || [])];
    window.loveStorage.update({ memories });
    this.render();

    // Broadcast sync to partner if online
    if (window.loveConnection && window.loveConnection.isConnected) {
      window.loveConnection.send('sync-data', {
        type: 'new-memory',
        memory: newMemory
      });
    }

    return true;
  }

  deleteMemory(id) {
    if (!confirm('Bạn có chắc muốn xóa kỷ niệm này không?')) return;
    const data = window.loveStorage.get();
    const memories = (data.memories || []).filter(m => m.id !== id);
    window.loveStorage.update({ memories });
    this.render();
    if (window.loveApp) window.loveApp.showToast('🗑️ Đã xóa kỷ niệm');
  }

  formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    const day = String(d.getDate()).padStart(2, '0');
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const year = d.getFullYear();
    return `${day}/${month}/${year}`;
  }

  escapeHTML(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
}

window.loveDiary = new LoveDiaryEngine();
