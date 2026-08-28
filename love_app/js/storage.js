/**
 * LOVE COUPLE APP - LOCAL STORAGE & DATA STATE MANAGEMENT
 */

const STORAGE_KEY = 'LOVE_APP_DATA_V1';

// Default initial data
const DEFAULT_LOVE_DATA = {
  // Couple Profile
  user: {
    name: 'Anh Yêu',
    nickname: 'Bae 👦',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80',
    birthday: '2002-05-15',
    zodiac: 'Kim Ngưu ♉'
  },
  partner: {
    name: 'Em Yêu',
    nickname: 'Công chúa 👧',
    avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&auto=format&fit=crop&q=80',
    birthday: '2003-08-20',
    zodiac: 'Sư Tử ♌'
  },
  
  // Relationship Info
  startDate: new Date(Date.now() - 520 * 24 * 60 * 60 * 1000).toISOString().split('T')[0], // 520 days ago default
  startTime: '08:00',
  bio: 'Mỗi ngày bên em là một ngày ngập tràn hạnh phúc và yêu thương! ❤️✨',
  totalHeartsSent: 1314,
  
  // Customization
  theme: 'pink', // pink, starry, peach, sunset, lavender, wine
  particleEffect: 'hearts', // hearts, petals, stars, snow, none
  customBg: '',
  bgmEnabled: true,
  bgmVolume: 0.5,
  
  // Security
  securityPin: '', // 4 digits PIN for secret letters
  
  // Custom Milestones
  customMilestones: [
    { id: 'ms-1', title: 'Lần đầu hẹn hò ăn ốc', date: '2023-04-10', icon: '🍲' },
    { id: 'ms-2', title: 'Chuyến du lịch Đà Lạt đầu tiên', date: '2023-11-20', icon: '🏕️' }
  ],
  
  // Love Diary Memories
  memories: [
    {
      id: 'mem-1',
      title: 'Ngày đầu tiên chúng mình gặp nhau ✨',
      date: '2023-03-21',
      mood: '🥰 Hạnh phúc ngập tràn',
      image: 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=600&auto=format&fit=crop&q=80',
      content: 'Một buổi chiều mưa bất chợt ở quán cà phê, ánh mắt chạm nhau làm tim anh lỡ một nhịp...'
    },
    {
      id: 'mem-2',
      title: 'Chuyến đi ngắm hoàng hôn biển Phú Quốc 🌅',
      date: '2024-01-15',
      mood: '🏖️ Bình yên',
      image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&auto=format&fit=crop&q=80',
      content: 'Cùng nhau nắm tay dạo bước trên cát mịn, nghe tiếng sóng vỗ và hứa sẽ bên nhau thật lâu.'
    }
  ],
  
  // Secret Letters
  secretLetters: [
    {
      id: 'letter-1',
      title: 'Gửi người anh yêu nhất trần đời 💌',
      date: '2024-02-14',
      content: 'Cảm ơn em đã xuất hiện và làm cho thế giới của anh trở nên rực rỡ sắc màu. Dù mai sau có thế nào, anh vẫn luôn ở đây chở che cho em!'
    }
  ],
  
  // Bucket List (100 Things to do together)
  bucketList: [
    { id: 'b-1', text: 'Cùng nhau ngắm bình minh trên biển', completed: true },
    { id: 'b-2', text: 'Nấu một bữa tối lãng mạn dưới ánh nến', completed: true },
    { id: 'b-3', text: 'Đi du lịch nước ngoài cùng nhau', completed: false },
    { id: 'b-4', text: 'Mặc áo đôi đi xem concert thần tượng', completed: false },
    { id: 'b-5', text: 'Cùng nhau nuôi một bé mèo/cún đáng yêu', completed: false },
    { id: 'b-6', text: 'Học một điệu nhảy đôi thật tình tứ', completed: false },
    { id: 'b-7', text: 'Cùng thức thâu đêm ngắm sao băng', completed: true },
    { id: 'b-8', text: 'Chụp một bộ ảnh cưới thật thơ mộng', completed: false }
  ],
  
  // 100 Reasons Why I Love You
  loveReasons: [
    'Nụ cười toả nắng của em làm tan biến mọi mệt mỏi trong anh.',
    'Cách em chăm sóc và lắng nghe anh mỗi khi anh có chuyện buồn.',
    'Đôi mắt long lanh biết nói mỗi khi nhìn anh.',
    'Những cái ôm bất ngờ từ phía sau thật ấm áp.',
    'Bởi vì khi ở bên em, anh được là chính bản thân mình trọn vẹn nhất.'
  ],
  
  // Locations
  myLocation: { lat: 21.0285, lng: 105.8542, updatedAt: null }, // Default Hanoi
  partnerLocation: { lat: 21.0368, lng: 105.8346, updatedAt: null },
  shareLocationEnabled: true,
  
  // Pairing Room
  roomCode: ''
};

class LoveStorage {
  constructor() {
    this.data = this.load();
  }

  load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        return { ...DEFAULT_LOVE_DATA, ...parsed };
      }
    } catch (e) {
      console.error('Failed to load love data from localStorage', e);
    }
    return JSON.parse(JSON.stringify(DEFAULT_LOVE_DATA));
  }

  save() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.data));
      window.dispatchEvent(new CustomEvent('loveDataChanged', { detail: this.data }));
      return true;
    } catch (e) {
      console.error('Failed to save love data to localStorage', e);
      return false;
    }
  }

  get() {
    return this.data;
  }

  update(partial) {
    this.data = { ...this.data, ...partial };
    this.save();
    return this.data;
  }

  exportJSON() {
    const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(this.data, null, 2));
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute("href", dataStr);
    downloadAnchor.setAttribute("download", `LoveApp_Backup_${new Date().toISOString().split('T')[0]}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
  }

  importJSON(jsonString) {
    try {
      const parsed = JSON.parse(jsonString);
      if (parsed && typeof parsed === 'object') {
        this.data = { ...DEFAULT_LOVE_DATA, ...parsed };
        this.save();
        return true;
      }
    } catch (e) {
      console.error('Invalid backup JSON', e);
    }
    return false;
  }

  resetDefault() {
    this.data = JSON.parse(JSON.stringify(DEFAULT_LOVE_DATA));
    this.save();
  }
}

window.loveStorage = new LoveStorage();
