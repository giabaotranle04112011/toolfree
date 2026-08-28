/**
 * LOVE COUPLE APP - WEBRTC P2P REALTIME PAIRING CONNECTION
 * Enables real-time sync, live heart bursts, virtual kiss/hug, battery sync & GPS location sharing.
 */

class LoveConnectionEngine {
  constructor() {
    this.peer = null;
    this.conn = null;
    this.myPeerId = '';
    this.partnerPeerId = '';
    this.isConnected = false;
    this.batteryLevel = null;
    this.isCharging = false;
    
    this.callbacks = {
      onStatusChange: null,
      onPartnerBattery: null,
      onHeartBurst: null,
      onVirtualKiss: null,
      onVirtualHug: null,
      onPoke: null,
      onQuickMessage: null,
      onLocationReceived: null,
      onDataSynced: null
    };

    this.initBattery();
  }

  // Generate random 4-digit room code: LOVE-XXXX
  generateCode() {
    const randomNum = Math.floor(1000 + Math.random() * 9000);
    return `LOVE-${randomNum}`;
  }

  init(customId = null) {
    if (this.peer) {
      try { this.peer.destroy(); } catch (e) {}
    }

    const savedCode = customId || window.loveStorage.get().roomCode || this.generateCode();
    this.myPeerId = savedCode.trim().toUpperCase();

    // Format PeerJS ID to be url-safe
    const peerJsId = `loveapp_${this.myPeerId.replace(/[^A-Za-z0-9_-]/g, '_')}`;

    try {
      this.peer = new Peer(peerJsId, {
        debug: 1,
        config: {
          iceServers: [
            { urls: 'stun:stun.l.google.com:19302' },
            { urls: 'stun:global.stun.twilio.com:3478' }
          ]
        }
      });

      this.peer.on('open', (id) => {
        console.log('PeerJS ready with ID:', id);
        window.loveStorage.update({ roomCode: this.myPeerId });
        this.notifyStatus(false, 'Sẵn sàng kết nối');
      });

      // Handle incoming connection from partner
      this.peer.on('connection', (connection) => {
        console.log('Incoming connection from partner:', connection.peer);
        this.setupConnection(connection);
      });

      this.peer.on('error', (err) => {
        console.warn('PeerJS error:', err.type, err.message);
        if (err.type === 'unavailable-id') {
          // If ID taken, generate a new one
          const newCode = this.generateCode();
          this.init(newCode);
        } else {
          this.notifyStatus(false, 'Chờ kết nối...');
        }
      });

      this.peer.on('disconnected', () => {
        this.notifyStatus(false, 'Mất kết nối');
      });
    } catch (e) {
      console.error('Peer initialization failed', e);
    }
  }

  // Connect to partner using partner's code
  connectToPartner(partnerCode) {
    if (!partnerCode) return false;
    const cleanCode = partnerCode.trim().toUpperCase();
    const partnerPeerJsId = `loveapp_${cleanCode.replace(/[^A-Za-z0-9_-]/g, '_')}`;

    if (!this.peer || this.peer.destroyed) {
      this.init();
    }

    this.notifyStatus(false, 'Đang tìm kiếm đối phương...');
    const connection = this.peer.connect(partnerPeerJsId, {
      reliable: true
    });

    this.setupConnection(connection);
    return true;
  }

  setupConnection(connection) {
    this.conn = connection;

    this.conn.on('open', () => {
      console.log('Successfully paired with partner!');
      this.isConnected = true;
      this.partnerPeerId = connection.peer;
      this.notifyStatus(true, 'Đã kết nối trực tuyến ❤️');
      
      if (window.loveAudio) window.loveAudio.playSuccess();
      if (window.navigator.vibrate) window.navigator.vibrate([100, 50, 100]);

      // Send greeting & initial sync info
      this.send('greeting', {
        name: window.loveStorage.get().user.name,
        battery: this.batteryLevel,
        isCharging: this.isCharging
      });

      // Send current GPS location if sharing enabled
      if (window.loveMap && window.loveStorage.get().shareLocationEnabled) {
        window.loveMap.sendCurrentLocation();
      }
    });

    this.conn.on('data', (data) => {
      this.handleIncomingData(data);
    });

    this.conn.on('close', () => {
      this.isConnected = false;
      this.conn = null;
      this.notifyStatus(false, 'Đối phương đã ngắt kết nối');
    });

    this.conn.on('error', (err) => {
      console.warn('Connection error:', err);
      this.isConnected = false;
      this.notifyStatus(false, 'Lỗi kết nối');
    });
  }

  send(type, payload = {}) {
    if (this.conn && this.isConnected) {
      try {
        this.conn.send({
          type,
          payload,
          timestamp: Date.now()
        });
        return true;
      } catch (e) {
        console.error('Failed to send P2P message', e);
      }
    }
    return false;
  }

  handleIncomingData(data) {
    if (!data || !data.type) return;
    const { type, payload } = data;

    switch (type) {
      case 'greeting':
        if (payload.battery !== undefined && this.callbacks.onPartnerBattery) {
          this.callbacks.onPartnerBattery(payload.battery, payload.isCharging);
        }
        break;

      case 'heart-burst':
        if (this.callbacks.onHeartBurst) this.callbacks.onHeartBurst(payload);
        break;

      case 'virtual-kiss':
        if (this.callbacks.onVirtualKiss) this.callbacks.onVirtualKiss(payload);
        break;

      case 'virtual-hug':
        if (this.callbacks.onVirtualHug) this.callbacks.onVirtualHug(payload);
        break;

      case 'poke':
        if (this.callbacks.onPoke) this.callbacks.onPoke(payload);
        break;

      case 'quick-message':
        if (this.callbacks.onQuickMessage) this.callbacks.onQuickMessage(payload);
        break;

      case 'battery-update':
        if (this.callbacks.onPartnerBattery) {
          this.callbacks.onPartnerBattery(payload.level, payload.charging);
        }
        break;

      case 'location-update':
        if (this.callbacks.onLocationReceived) {
          this.callbacks.onLocationReceived(payload);
        }
        break;

      case 'sync-data':
        if (this.callbacks.onDataSynced) {
          this.callbacks.onDataSynced(payload);
        }
        break;
    }
  }

  notifyStatus(connected, text) {
    if (this.callbacks.onStatusChange) {
      this.callbacks.onStatusChange(connected, text);
    }
  }

  /* Battery status monitoring */
  async initBattery() {
    try {
      if ('getBattery' in navigator) {
        const battery = await navigator.getBattery();
        this.updateBattery(battery);
        
        battery.addEventListener('levelchange', () => this.updateBattery(battery));
        battery.addEventListener('chargingchange', () => this.updateBattery(battery));
      }
    } catch (e) {
      console.log('Battery status not supported or restricted');
    }
  }

  updateBattery(battery) {
    this.batteryLevel = Math.round(battery.level * 100);
    this.isCharging = battery.charging;
    
    // Broadcast to partner if connected
    if (this.isConnected) {
      this.send('battery-update', {
        level: this.batteryLevel,
        charging: this.isCharging
      });
    }
  }

  /* Trigger Actions to Partner */
  sendHeartBurst(count = 1) {
    this.send('heart-burst', { count });
  }

  sendKiss() {
    this.send('virtual-kiss', { sender: window.loveStorage.get().user.name });
  }

  sendHug() {
    this.send('virtual-hug', { sender: window.loveStorage.get().user.name });
  }

  sendPoke() {
    this.send('poke', { sender: window.loveStorage.get().user.name });
  }

  sendQuickMsg(text) {
    this.send('quick-message', {
      sender: window.loveStorage.get().user.name,
      text: text
    });
  }

  syncAllData(data) {
    this.send('sync-data', { data });
  }
}

window.loveConnection = new LoveConnectionEngine();
