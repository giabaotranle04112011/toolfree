/**
 * LOVE COUPLE APP - MINI-GAMES & COUPLE FUN ZONE
 * Date Wheel, Love Fortune Jar, Touch Heart Sync & Love Quiz.
 */

class LoveGamesEngine {
  constructor() {
    this.wheelCanvas = null;
    this.wheelCtx = null;
    this.isSpinning = false;
    this.wheelAngle = 0;
    this.currentWheelMode = 'food';

    this.wheelPresets = {
      food: [
        '🍲 Lẩu Haidilao',
        '🧋 Trà sữa & Bánh',
        '🥘 Bún đậu mắm tôm',
        '🥩 Nướng BBQ',
        '🍳 Cơm nhà tự nấu',
        '🍕 Pizza & Gà rán',
        '🍜 Phở bò nóng hổi',
        '🐚 Đi ăn ốc đêm'
      ],
      date: [
        '🎬 Đi xem phim rạp',
        '☕ Cà phê ngắm hoàng hôn',
        '⛺ Cắm trại dã ngoại',
        '🚶 Dạo phố đi bộ',
        '🛋️ Ở nhà xem Netflix',
        '🛍️ Đi shopping mua đồ',
        '🎮 Đi gắp gấu bông'
      ],
      dare: [
        '🍽️ Người bị quay rửa bát',
        '💋 Thơm má 10 cái',
        '💳 Người bị quay trả tiền',
        '💆 Massage 5 phút',
        '🥰 Nói 5 câu khen ngợi',
        '🎶 Hát 1 bài tặng đối phương',
        '🫂 Ôm chặt 1 phút'
      ]
    };

    this.loveJarFortunes = [
      '💋 Hãy trao cho đối phương một nụ hôn nồng thắm ngay bây giờ!',
      '🫂 Ôm đối phương thật chặt từ phía sau trong ít nhất 30 giây.',
      '🥰 Kể cho người ấy nghe 3 điều bạn thấy đáng yêu nhất ở họ.',
      '📸 Chụp chung một bức ảnh selfie thật hài hước cùng nhau!',
      '💆 Massage vai hoặc đầu cho đối phương thật thư giãn nhé.',
      '☕ Mua hoặc tự tay pha cho đối phương một cốc đồ uống yêu thích.',
      '🎶 Cùng nhau nghe lại bài hát kỷ niệm đầu tiên của 2 đứa.',
      '💌 Nhắn cho người ấy một tin nhắn dài bày tỏ tình cảm thật ngọt ngào.',
      '✨ Tối nay hãy gác lại công việc và dành trọn buổi tối cùng nhau.',
      '🌹 Tặng người ấy một món quà nhỏ bất ngờ không cần nhân dịp gì cả!',
      '👂 Lắng nghe mọi tâm sự của đối phương và không ngắt lời.',
      '🍳 Nấu một món ăn mà người ấy thích nhất vào ngày mai.'
    ];

    this.quizQuestions = [
      {
        q: 'Nơi nào là địa điểm hẹn hò lý tưởng nhất của 2 bạn?',
        options: ['Quán cà phê yên tĩnh lãng mạn', 'Rạp chiếu phim ghế đôi', 'Bãi biển lộng gió ngắm hoàng hôn', 'Ở nhà cùng nhau nấu ăn']
      },
      {
        q: 'Khi người yêu giận, bạn sẽ làm gì trước tiên?',
        options: ['Ôm thật chặt và dỗ dành ngay', 'Mua món ăn/trà sữa người ấy thích', 'Lắng nghe xem mình sai ở đâu', 'Hôn nhẹ vào trán để hạ hỏa']
      },
      {
        q: 'Điều gì ở đối phương làm tim bạn rung động nhất?',
        options: ['Nụ cười toả nắng', 'Đôi mắt long lanh dịu dàng', 'Sự quan tâm chu đáo từng chút một', 'Giọng nói ngọt ngào ấm áp']
      },
      {
        q: 'Kế hoạch du lịch trong mơ của cả hai là gì?',
        options: ['Đi Đà Lạt ngắm mây và hoa', 'Đi biển Phú Quốc/Nha Trang', 'Đi ngắm tuyết rơi ở nước ngoài', 'Đi phượt xuyên Việt']
      }
    ];
    this.quizCurrentIndex = 0;
    this.quizScore = 0;
  }

  initWheel(canvasId = 'wheel-canvas') {
    this.wheelCanvas = document.getElementById(canvasId);
    if (!this.wheelCanvas) return;
    this.wheelCtx = this.wheelCanvas.getContext('2d');
    this.drawWheel();
  }

  setWheelMode(mode) {
    this.currentWheelMode = mode;
    this.drawWheel();
  }

  drawWheel() {
    if (!this.wheelCanvas || !this.wheelCtx) return;
    const ctx = this.wheelCtx;
    const items = this.wheelPresets[this.currentWheelMode] || this.wheelPresets.food;
    const numItems = items.length;
    const arc = (2 * Math.PI) / numItems;
    const radius = this.wheelCanvas.width / 2;

    ctx.clearRect(0, 0, this.wheelCanvas.width, this.wheelCanvas.height);
    ctx.save();
    ctx.translate(radius, radius);
    ctx.rotate(this.wheelAngle);

    const colors = ['#ff4b72', '#ff7597', '#8a2be2', '#a55eea', '#ff6b6b', '#ffa07a', '#20bf6b', '#f7b731'];

    for (let i = 0; i < numItems; i++) {
      const angle = i * arc;
      ctx.beginPath();
      ctx.fillStyle = colors[i % colors.length];
      ctx.moveTo(0, 0);
      ctx.arc(0, 0, radius - 6, angle, angle + arc);
      ctx.lineTo(0, 0);
      ctx.fill();
      ctx.stroke();

      // Text
      ctx.save();
      ctx.fillStyle = '#ffffff';
      ctx.font = 'bold 12px "Quicksand", sans-serif';
      ctx.translate(Math.cos(angle + arc / 2) * (radius * 0.65), Math.sin(angle + arc / 2) * (radius * 0.65));
      ctx.rotate(angle + arc / 2 + Math.PI / 2);
      const text = items[i];
      ctx.fillText(text, -ctx.measureText(text).width / 2, 0);
      ctx.restore();
    }

    // Center circle
    ctx.beginPath();
    ctx.arc(0, 0, 26, 0, 2 * Math.PI);
    ctx.fillStyle = '#ffffff';
    ctx.fill();
    ctx.strokeStyle = '#ff4b72';
    ctx.lineWidth = 4;
    ctx.stroke();

    ctx.fillStyle = '#ff4b72';
    ctx.font = '16px sans-serif';
    ctx.fillText('💖', -10, 6);

    ctx.restore();
  }

  spinWheel() {
    if (this.isSpinning) return;
    this.isSpinning = true;

    const resultEl = document.getElementById('wheel-result-text');
    if (resultEl) resultEl.textContent = 'Đang quay định mệnh... ✨';

    const items = this.wheelPresets[this.currentWheelMode] || this.wheelPresets.food;
    const numItems = items.length;
    const arc = (2 * Math.PI) / numItems;

    // Pick random target item
    const selectedIndex = Math.floor(Math.random() * numItems);
    const extraSpins = 5 + Math.floor(Math.random() * 4); // 5-8 full spins
    
    // Canvas pointer is at top (-PI/2)
    const targetAngleOffset = (2 * Math.PI) - (selectedIndex * arc + arc / 2) - (Math.PI / 2);
    const targetAngle = (this.wheelAngle % (2 * Math.PI)) + (extraSpins * 2 * Math.PI) + targetAngleOffset;

    const startAngle = this.wheelAngle;
    const duration = 4000;
    const startTime = performance.now();

    if (window.loveAudio) window.loveAudio.playPokeChime();

    const animateSpin = (currentTime) => {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      
      // Cubic ease-out
      const easeOut = 1 - Math.pow(1 - progress, 3);
      this.wheelAngle = startAngle + (targetAngle - startAngle) * easeOut;
      this.drawWheel();

      if (progress < 1) {
        requestAnimationFrame(animateSpin);
      } else {
        this.isSpinning = false;
        const result = items[selectedIndex];
        if (resultEl) resultEl.innerHTML = `🎉 Kết quả: <b style="color: var(--accent); font-size: 18px;">${result}</b>`;
        
        if (window.loveAudio) window.loveAudio.playSuccess();
        if (window.confetti) {
          window.confetti({ particleCount: 80, spread: 70, origin: { y: 0.6 } });
        }
      }
    };

    requestAnimationFrame(animateSpin);
  }

  /* Love Fortune Jar */
  drawLoveJar() {
    const cardEl = document.getElementById('jar-result-card');
    const randomIndex = Math.floor(Math.random() * this.loveJarFortunes.length);
    const fortune = this.loveJarFortunes[randomIndex];

    if (window.loveAudio) window.loveAudio.playHeartPop();
    if (window.confetti) {
      window.confetti({ particleCount: 50, spread: 60, origin: { y: 0.7 } });
    }

    if (cardEl) {
      cardEl.innerHTML = `
        <div style="animation: fadeInTab 0.4s ease; padding: 14px; background: rgba(255,255,255,0.1); border-radius: 16px; border: 1px solid var(--border-active); text-align: center;">
          <div style="font-size: 28px; margin-bottom: 6px;">💌</div>
          <div style="font-size: 14px; font-weight: 700; color: #fff; line-height: 1.5;">${fortune}</div>
        </div>
      `;
    }
  }

  /* Love Quiz */
  startQuiz() {
    this.quizCurrentIndex = 0;
    this.quizScore = 0;
    this.renderQuizQuestion();
  }

  renderQuizQuestion() {
    const container = document.getElementById('quiz-container');
    if (!container) return;

    if (this.quizCurrentIndex >= this.quizQuestions.length) {
      // Finished
      const percent = Math.round((this.quizScore / this.quizQuestions.length) * 100);
      container.innerHTML = `
        <div style="text-align: center; padding: 20px;">
          <div style="font-size: 40px; margin-bottom: 8px;">💯💖</div>
          <h3 style="color: #fff; font-size: 18px;">Độ hòa hợp: ${percent}%</h3>
          <p style="color: var(--text-sub); font-size: 13px; margin: 8px 0 16px;">Hai bạn sinh ra là để dành cho nhau! Hãy luôn giữ trọn tình cảm ngọt ngào này nhé!</p>
          <button class="app-btn" onclick="window.loveGames.startQuiz()">Làm lại trắc nghiệm</button>
        </div>
      `;
      if (window.confetti) window.confetti({ particleCount: 100, spread: 80, origin: { y: 0.6 } });
      return;
    }

    const item = this.quizQuestions[this.quizCurrentIndex];
    container.innerHTML = `
      <div style="display: flex; flex-direction: column; gap: 12px;">
        <div style="font-size: 12px; color: var(--text-muted);">Câu ${this.quizCurrentIndex + 1}/${this.quizQuestions.length}</div>
        <h4 style="font-size: 15px; color: #fff; line-height: 1.4;">${item.q}</h4>
        <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 6px;">
          ${item.options.map((opt, i) => `
            <button class="app-btn secondary" style="text-align: left; justify-content: flex-start; padding: 10px 14px; font-size: 13px;" onclick="window.loveGames.answerQuiz(${i})">
              ${opt}
            </button>
          `).join('')}
        </div>
      </div>
    `;
  }

  answerQuiz(optionIndex) {
    this.quizScore++;
    this.quizCurrentIndex++;
    if (window.loveAudio) window.loveAudio.playHeartPop();
    this.renderQuizQuestion();
  }
}

window.loveGames = new LoveGamesEngine();
