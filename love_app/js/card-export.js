/**
 * LOVE COUPLE APP - SHAREABLE HD CARD GENERATOR
 * Renders high-res romantic story/post cards using HTML5 Canvas and exports PNG image.
 */

class LoveCardExporter {
  constructor() {
    this.canvas = null;
    this.ctx = null;
  }

  init(canvasId = 'share-card-canvas') {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) return;
    this.ctx = this.canvas.getContext('2d');
    this.render();
  }

  async render() {
    if (!this.canvas || !this.ctx) return;
    const ctx = this.ctx;
    const data = window.loveStorage.get();
    const counter = window.loveCounter.update();

    // Canvas Dimensions (HD Story Format 9:16 - 1080x1920 scaled down internally for crispness)
    const width = 800;
    const height = 1200;
    this.canvas.width = width;
    this.canvas.height = height;

    // 1. Background Gradient
    const bgGrad = ctx.createLinearGradient(0, 0, width, height);
    if (data.theme === 'starry') {
      bgGrad.addColorStop(0, '#090a1a');
      bgGrad.addColorStop(0.5, '#1e144a');
      bgGrad.addColorStop(1, '#0c0a24');
    } else if (data.theme === 'peach') {
      bgGrad.addColorStop(0, '#2b1414');
      bgGrad.addColorStop(0.5, '#4a2228');
      bgGrad.addColorStop(1, '#200d11');
    } else {
      bgGrad.addColorStop(0, '#1c0818');
      bgGrad.addColorStop(0.5, '#3d122f');
      bgGrad.addColorStop(1, '#18071a');
    }
    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, width, height);

    // Decorative glowing circles
    const radGrad1 = ctx.createRadialGradient(width * 0.2, height * 0.25, 10, width * 0.2, height * 0.25, 300);
    radGrad1.addColorStop(0, 'rgba(255, 75, 114, 0.35)');
    radGrad1.addColorStop(1, 'transparent');
    ctx.fillStyle = radGrad1;
    ctx.fillRect(0, 0, width, height);

    const radGrad2 = ctx.createRadialGradient(width * 0.8, height * 0.7, 10, width * 0.8, height * 0.7, 350);
    radGrad2.addColorStop(0, 'rgba(138, 43, 226, 0.25)');
    radGrad2.addColorStop(1, 'transparent');
    ctx.fillStyle = radGrad2;
    ctx.fillRect(0, 0, width, height);

    // 2. Card Frame Border
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
    ctx.lineWidth = 4;
    this.roundRect(ctx, 40, 40, width - 80, height - 80, 32);
    ctx.stroke();

    // 3. Header Title
    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 24px "Quicksand", sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText('✨ OUR LOVE STORY ✨', width / 2, 110);

    // 4. Draw Avatars
    const userImg = await this.loadImage(data.user.avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300');
    const partnerImg = await this.loadImage(data.partner.avatar || 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300');

    const avatarSize = 150;
    const avatarY = 240;
    const leftX = width / 2 - 130;
    const rightX = width / 2 + 130;

    // Draw Left Avatar (User)
    this.drawCircularAvatar(ctx, userImg, leftX, avatarY, avatarSize / 2, '#ff4b72');
    // Draw Right Avatar (Partner)
    this.drawCircularAvatar(ctx, partnerImg, rightX, avatarY, avatarSize / 2, '#00f2fe');

    // Heart Icon between avatars
    ctx.font = '48px sans-serif';
    ctx.fillText('💖', width / 2, avatarY + 16);

    // Names below avatars
    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 26px "Quicksand", sans-serif';
    ctx.fillText(data.user.name || 'Anh Yêu', leftX, avatarY + 115);
    ctx.fillText(data.partner.name || 'Em Yêu', rightX, avatarY + 115);

    ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
    ctx.font = '18px "Quicksand", sans-serif';
    ctx.fillText(data.user.zodiac || '', leftX, avatarY + 145);
    ctx.fillText(data.partner.zodiac || '', rightX, avatarY + 145);

    // 5. Main Big Days Counter
    ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
    ctx.font = 'bold 22px "Quicksand", sans-serif';
    ctx.fillText('ĐÃ BÊN NHAU ĐƯỢC', width / 2, 570);

    // Big Number Glow
    ctx.save();
    ctx.shadowColor = '#ff4b72';
    ctx.shadowBlur = 30;
    ctx.fillStyle = '#ffffff';
    ctx.font = '800 96px "Quicksand", sans-serif';
    ctx.fillText(`${counter.totalDays}`, width / 2, 675);
    ctx.restore();

    ctx.fillStyle = '#ff7597';
    ctx.font = 'bold 28px "Quicksand", sans-serif';
    ctx.fillText('NGÀY YÊU THƯƠNG', width / 2, 725);

    // 6. Time Breakdown Box
    const boxY = 780;
    const boxWidth = 580;
    const boxHeight = 90;
    const boxX = (width - boxWidth) / 2;

    ctx.fillStyle = 'rgba(255, 255, 255, 0.08)';
    this.roundRect(ctx, boxX, boxY, boxWidth, boxHeight, 18);
    ctx.fill();
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
    ctx.lineWidth = 1;
    ctx.stroke();

    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 22px "Courier New", monospace';
    ctx.fillText(`${counter.years} Năm • ${counter.months} Tháng • ${counter.days} Ngày`, width / 2, boxY + 54);

    // 7. Love Quote / Bio
    ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
    ctx.font = 'italic 20px "Quicksand", sans-serif';
    const quote = data.bio || 'Mỗi ngày bên em là một ngày ngập tràn hạnh phúc và yêu thương! ❤️';
    this.wrapText(ctx, `"${quote}"`, width / 2, 930, 600, 32);

    // 8. Footer Info
    ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.font = '16px "Quicksand", sans-serif';
    ctx.fillText(`Ngày bắt đầu: ${counter.formattedStartDate}`, width / 2, 1080);
    ctx.fillText('❤️ LOVE COUPLE APP • FOREVER TOGETHER ❤️', width / 2, 1120);
  }

  drawCircularAvatar(ctx, img, x, y, r, strokeColor) {
    ctx.save();
    ctx.beginPath();
    ctx.arc(x, y, r, 0, 2 * Math.PI);
    ctx.closePath();
    ctx.clip();
    try {
      ctx.drawImage(img, x - r, y - r, r * 2, r * 2);
    } catch (e) {
      ctx.fillStyle = '#333';
      ctx.fill();
    }
    ctx.restore();

    // Border
    ctx.beginPath();
    ctx.arc(x, y, r, 0, 2 * Math.PI);
    ctx.strokeStyle = strokeColor;
    ctx.lineWidth = 6;
    ctx.stroke();
  }

  roundRect(ctx, x, y, w, h, r) {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h - r);
    ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
    ctx.lineTo(x + r, y + h);
    ctx.quadraticCurveTo(x, y + h, x, y + h - r);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  wrapText(ctx, text, x, y, maxWidth, lineHeight) {
    const words = text.split(' ');
    let line = '';
    let curY = y;

    for (let n = 0; n < words.length; n++) {
      const testLine = line + words[n] + ' ';
      const metrics = ctx.measureText(testLine);
      if (metrics.width > maxWidth && n > 0) {
        ctx.fillText(line, x, curY);
        line = words[n] + ' ';
        curY += lineHeight;
      } else {
        line = testLine;
      }
    }
    ctx.fillText(line, x, curY);
  }

  loadImage(src) {
    return new Promise((resolve) => {
      const img = new Image();
      img.crossOrigin = 'Anonymous';
      img.onload = () => resolve(img);
      img.onerror = () => {
        // Fallback transparent image
        const blank = new Image();
        blank.src = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
        resolve(blank);
      };
      img.src = src;
    });
  }

  downloadCard() {
    if (!this.canvas) return;
    const link = document.createElement('a');
    link.download = `LoveCard_${new Date().toISOString().split('T')[0]}.png`;
    link.href = this.canvas.toDataURL('image/png');
    link.click();
    if (window.loveApp) window.loveApp.showToast('📸 Đã tải ảnh kỷ niệm HD về máy!');
  }
}

window.loveCard = new LoveCardExporter();
