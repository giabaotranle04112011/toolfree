/**
 * LOVE COUPLE APP - LOVE COUNTER & MILESTONES ENGINE
 */

class LoveCounterEngine {
  constructor() {
    this.timer = null;
  }

  start(onTick) {
    this.update(onTick);
    this.timer = setInterval(() => {
      this.update(onTick);
    }, 1000);
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  update(callback) {
    const data = window.loveStorage ? window.loveStorage.get() : {};
    const startDateStr = data.startDate || '2023-01-01';
    const startTimeStr = data.startTime || '00:00';
    
    const startDateTime = new Date(`${startDateStr}T${startTimeStr}:00`);
    const now = new Date();
    
    // Difference in milliseconds
    const diffMs = now.getTime() - startDateTime.getTime();
    const isFuture = diffMs < 0;
    const absDiffMs = Math.abs(diffMs);

    // Total Days
    const totalDays = Math.floor(absDiffMs / (1000 * 60 * 60 * 24));
    
    // Remaining time breakdown (Hours, Minutes, Seconds)
    const hours = Math.floor((absDiffMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((absDiffMs % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((absDiffMs % (1000 * 60)) / 1000);

    // Human breakdown (Years, Months, Days)
    const breakdown = this.getYearMonthDayDiff(startDateTime, now);

    const result = {
      isFuture,
      totalDays: totalDays + (isFuture ? 0 : 1), // Day 1 is the start day
      years: breakdown.years,
      months: breakdown.months,
      days: breakdown.days,
      hours: String(hours).padStart(2, '0'),
      minutes: String(minutes).padStart(2, '0'),
      seconds: String(seconds).padStart(2, '0'),
      formattedStartDate: this.formatDateVN(startDateTime)
    };

    if (callback) {
      callback(result);
    }
    return result;
  }

  getYearMonthDayDiff(dt1, dt2) {
    let from = new Date(dt1);
    let to = new Date(dt2);
    if (from > to) {
      const temp = from;
      from = to;
      to = temp;
    }

    let years = to.getFullYear() - from.getFullYear();
    let months = to.getMonth() - from.getMonth();
    let days = to.getDate() - from.getDate();

    if (days < 0) {
      months--;
      const prevMonth = new Date(to.getFullYear(), to.getMonth(), 0);
      days += prevMonth.getDate();
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    return { years, months, days };
  }

  formatDateVN(date) {
    const d = new Date(date);
    const day = String(d.getDate()).padStart(2, '0');
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const year = d.getFullYear();
    return `${day}/${month}/${year}`;
  }

  // Calculate Zodiac from birthday (YYYY-MM-DD)
  getZodiac(birthdayStr) {
    if (!birthdayStr) return '';
    const d = new Date(birthdayStr);
    const day = d.getDate();
    const month = d.getMonth() + 1;

    if ((month == 1 && day <= 19) || (month == 12 && day >= 22)) return 'Ma Kết ♑';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Bảo Bình ♒';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Song Ngư ♓';
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Bạch Dương ♈';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Kim Ngưu ♉';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return 'Song Tử ♊';
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return 'Cự Giải ♋';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Sư Tử ♌';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Xử Nữ ♍';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return 'Thiên Bình ♎';
    if ((month == 10 && day >= 24) || (month == 11 && day <= 21)) return 'Bọ Cạp ♏';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Nhân Mã ♐';
    return '';
  }

  // Generate complete list of milestones & calculate countdowns
  getMilestones() {
    const data = window.loveStorage.get();
    const startDate = new Date(`${data.startDate}T00:00:00`);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const list = [];

    // 1. Fixed day milestones: 100, 200, 300, 500, 1000, 1500, 2000, 3000
    const dayMilestones = [
      { days: 100, label: 'Kỷ niệm 100 ngày yêu', icon: '💖' },
      { days: 200, label: 'Kỷ niệm 200 ngày yêu', icon: '🌸' },
      { days: 300, label: 'Kỷ niệm 300 ngày yêu', icon: '✨' },
      { days: 365, label: 'Kỷ niệm 1 năm tròn', icon: '🎂' },
      { days: 500, label: 'Kỷ niệm 500 ngày yêu', icon: '🎁' },
      { days: 730, label: 'Kỷ niệm 2 năm yêu nhau', icon: '💍' },
      { days: 1000, label: 'Kỷ niệm 1000 ngày yêu', icon: '👑' },
      { days: 1095, label: 'Kỷ niệm 3 năm bên nhau', icon: '🎉' },
      { days: 1825, label: 'Kỷ niệm 5 năm gắn bó', icon: '🏰' }
    ];

    dayMilestones.forEach(m => {
      const targetDate = new Date(startDate.getTime() + (m.days - 1) * 24 * 60 * 60 * 1000);
      const diffDays = Math.ceil((targetDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
      
      list.push({
        title: m.label,
        icon: m.icon,
        dateStr: this.formatDateVN(targetDate),
        targetTimestamp: targetDate.getTime(),
        daysLeft: diffDays,
        isReached: diffDays <= 0,
        type: 'day'
      });
    });

    // 2. Annual special days (Valentine, Anniversaries, Birthdays)
    const annualEvents = [
      { name: 'Lễ tình nhân Valentine', month: 2, day: 14, icon: '🍫' },
      { name: 'Quốc tế Phụ nữ', month: 3, day: 8, icon: '💐' },
      { name: 'Phụ nữ Việt Nam', month: 10, day: 20, icon: '🌹' },
      { name: 'Giáng sinh an lành', month: 12, day: 25, icon: '🎄' }
    ];

    // Add birthdays if available
    if (data.user.birthday) {
      const uBday = new Date(data.user.birthday);
      annualEvents.push({
        name: `Sinh nhật ${data.user.name || 'Bạn'}`,
        month: uBday.getMonth() + 1,
        day: uBday.getDate(),
        icon: '🎂'
      });
    }
    if (data.partner.birthday) {
      const pBday = new Date(data.partner.birthday);
      annualEvents.push({
        name: `Sinh nhật ${data.partner.name || 'Người yêu'}`,
        month: pBday.getMonth() + 1,
        day: pBday.getDate(),
        icon: '🎁'
      });
    }

    // Add each annual event for current/next year
    annualEvents.forEach(evt => {
      let targetYear = now.getFullYear();
      let targetDate = new Date(targetYear, evt.month - 1, evt.day);
      if (targetDate < today) {
        targetDate = new Date(targetYear + 1, evt.month - 1, evt.day);
      }
      const diffDays = Math.ceil((targetDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
      list.push({
        title: evt.name,
        icon: evt.icon,
        dateStr: this.formatDateVN(targetDate),
        targetTimestamp: targetDate.getTime(),
        daysLeft: diffDays,
        isReached: diffDays === 0,
        type: 'holiday'
      });
    });

    // 3. Custom Milestones
    if (data.customMilestones && Array.isArray(data.customMilestones)) {
      data.customMilestones.forEach(cm => {
        const cDate = new Date(`${cm.date}T00:00:00`);
        const diffDays = Math.ceil((cDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
        list.push({
          id: cm.id,
          title: cm.title,
          icon: cm.icon || '📌',
          dateStr: this.formatDateVN(cDate),
          targetTimestamp: cDate.getTime(),
          daysLeft: diffDays,
          isReached: diffDays <= 0,
          type: 'custom'
        });
      });
    }

    // Sort: Upcoming ones first (ascending daysLeft > 0), then reached ones (descending)
    list.sort((a, b) => {
      if (a.daysLeft > 0 && b.daysLeft > 0) return a.daysLeft - b.daysLeft;
      if (a.daysLeft <= 0 && b.daysLeft <= 0) return b.daysLeft - a.daysLeft;
      return a.daysLeft > 0 ? -1 : 1;
    });

    return list;
  }
}

window.loveCounter = new LoveCounterEngine();
