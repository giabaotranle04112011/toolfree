/**
 * LOVE COUPLE APP - COUPLE GPS MAP & DISTANCE TRACKER
 * Visualizes locations with romantic couple avatars and computes real-time distance in KM.
 */

class LoveMapTracker {
  constructor() {
    this.map = null;
    this.myMarker = null;
    this.partnerMarker = null;
    this.connectingLine = null;
    this.watchId = null;
    
    this.myCoords = { lat: 21.0285, lng: 105.8542 }; // Default Hanoi
    this.partnerCoords = { lat: 21.0368, lng: 105.8346 }; // Default ~3km away
  }

  init(mapElementId = 'couple-map') {
    const el = document.getElementById(mapElementId);
    if (!el || this.map) return;

    const data = window.loveStorage.get();
    if (data.myLocation && data.myLocation.lat) {
      this.myCoords = data.myLocation;
    }
    if (data.partnerLocation && data.partnerLocation.lat) {
      this.partnerCoords = data.partnerLocation;
    }

    try {
      // Initialize Leaflet Map centered between both points
      const centerLat = (this.myCoords.lat + this.partnerCoords.lat) / 2;
      const centerLng = (this.myCoords.lng + this.partnerCoords.lng) / 2;

      this.map = L.map(mapElementId, {
        zoomControl: true,
        attributionControl: false
      }).setView([centerLat, centerLng], 13);

      // Add romantic Dark/CartoDB map tiles
      L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
        maxZoom: 19,
        subdomains: 'abcd'
      }).addTo(this.map);

      this.updateMarkers();
      this.updateConnectingLine();
      this.updateDistanceDisplay();

      // Listen for partner location updates from connection module
      if (window.loveConnection) {
        window.loveConnection.callbacks.onLocationReceived = (payload) => {
          this.setPartnerLocation(payload.lat, payload.lng);
        };
      }

      // Auto start GPS watching if enabled
      if (data.shareLocationEnabled) {
        this.startWatchingGPS();
      }
    } catch (e) {
      console.error('Failed to initialize Leaflet Map', e);
    }
  }

  createCustomIcon(avatarUrl, name, isPartner = false) {
    const html = `
      <div class="couple-map-avatar-marker">
        <img class="map-avatar-bubble ${isPartner ? 'partner' : ''}" src="${avatarUrl}" alt="${name}" onerror="this.src='https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'"/>
        <div class="map-marker-name">${name}</div>
      </div>
    `;

    return L.divIcon({
      className: 'custom-leaflet-marker',
      html: html,
      iconSize: [50, 65],
      iconAnchor: [25, 55],
      popupAnchor: [0, -50]
    });
  }

  updateMarkers() {
    if (!this.map) return;
    const data = window.loveStorage.get();

    // 1. My Marker
    const myIcon = this.createCustomIcon(
      data.user.avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      data.user.name || 'Bạn',
      false
    );

    if (!this.myMarker) {
      this.myMarker = L.marker([this.myCoords.lat, this.myCoords.lng], { icon: myIcon }).addTo(this.map);
      this.myMarker.bindPopup(`<b>${data.user.name || 'Bạn'}</b><br>Vị trí hiện tại`);
    } else {
      this.myMarker.setLatLng([this.myCoords.lat, this.myCoords.lng]);
      this.myMarker.setIcon(myIcon);
    }

    // 2. Partner Marker
    const partnerIcon = this.createCustomIcon(
      data.partner.avatar || 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
      data.partner.name || 'Người yêu',
      true
    );

    if (!this.partnerMarker) {
      this.partnerMarker = L.marker([this.partnerCoords.lat, this.partnerCoords.lng], { icon: partnerIcon }).addTo(this.map);
      this.partnerMarker.bindPopup(`<b>${data.partner.name || 'Người yêu'}</b><br>Vị trí của đối phương`);
    } else {
      this.partnerMarker.setLatLng([this.partnerCoords.lat, this.partnerCoords.lng]);
      this.partnerMarker.setIcon(partnerIcon);
    }
  }

  updateConnectingLine() {
    if (!this.map) return;

    const latlngs = [
      [this.myCoords.lat, this.myCoords.lng],
      [this.partnerCoords.lat, this.partnerCoords.lng]
    ];

    if (this.connectingLine) {
      this.connectingLine.setLatLngs(latlngs);
    } else {
      this.connectingLine = L.polyline(latlngs, {
        color: '#ff4b72',
        weight: 4,
        opacity: 0.8,
        dashArray: '8, 8',
        lineCap: 'round'
      }).addTo(this.map);
    }

    // Fit map bounds to view both
    try {
      const bounds = L.latLngBounds(latlngs);
      this.map.fitBounds(bounds, { padding: [40, 40], maxZoom: 16 });
    } catch (e) {}
  }

  // Haversine formula to compute distance in KM
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the Earth in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const d = R * c;
    return d; // in kilometers
  }

  updateDistanceDisplay() {
    const distKm = this.calculateDistance(
      this.myCoords.lat, this.myCoords.lng,
      this.partnerCoords.lat, this.partnerCoords.lng
    );

    let displayStr = '';
    let estimateStr = '';

    if (distKm < 0.05) {
      displayStr = 'Đang ở bên nhau ❤️';
      estimateStr = 'Chạm là thấy em';
    } else if (distKm < 1) {
      const meters = Math.round(distKm * 1000);
      displayStr = `${meters} mét`;
      estimateStr = `Đi bộ khoảng ${Math.ceil(meters / 80)} phút`;
    } else {
      displayStr = `${distKm.toFixed(1)} km`;
      const driveMin = Math.ceil((distKm / 35) * 60);
      estimateStr = `Đi xe khoảng ~${driveMin} phút`;
    }

    // Update UI elements
    const distEl = document.getElementById('map-distance-val');
    const estEl = document.getElementById('map-distance-estimate');
    const homeDistWidget = document.getElementById('home-distance-val');

    if (distEl) distEl.textContent = displayStr;
    if (estEl) estEl.textContent = estimateStr;
    if (homeDistWidget) homeDistWidget.textContent = displayStr;
  }

  startWatchingGPS() {
    if (!('geolocation' in navigator)) {
      console.warn('Geolocation not supported');
      return;
    }

    if (this.watchId) {
      navigator.geolocation.clearWatch(this.watchId);
    }

    this.watchId = navigator.geolocation.watchPosition(
      (pos) => {
        const { latitude, longitude } = pos.coords;
        this.setMyLocation(latitude, longitude);
      },
      (err) => {
        console.warn('GPS location error:', err.message);
      },
      {
        enableHighAccuracy: true,
        timeout: 15000,
        maximumAge: 10000
      }
    );
  }

  stopWatchingGPS() {
    if (this.watchId) {
      navigator.geolocation.clearWatch(this.watchId);
      this.watchId = null;
    }
  }

  setMyLocation(lat, lng) {
    this.myCoords = { lat, lng };
    window.loveStorage.update({
      myLocation: { lat, lng, updatedAt: Date.now() }
    });

    this.updateMarkers();
    this.updateConnectingLine();
    this.updateDistanceDisplay();
    this.sendCurrentLocation();
  }

  setPartnerLocation(lat, lng) {
    this.partnerCoords = { lat, lng };
    window.loveStorage.update({
      partnerLocation: { lat, lng, updatedAt: Date.now() }
    });

    this.updateMarkers();
    this.updateConnectingLine();
    this.updateDistanceDisplay();
  }

  sendCurrentLocation() {
    if (window.loveConnection && window.loveConnection.isConnected) {
      window.loveConnection.send('location-update', {
        lat: this.myCoords.lat,
        lng: this.myCoords.lng
      });
    }
  }

  // Fallback / manual location picker for simulation
  requestGPSNow() {
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          this.setMyLocation(pos.coords.latitude, pos.coords.longitude);
          if (window.loveApp) window.loveApp.showToast('📍 Đã cập nhật tọa độ GPS chính xác!');
        },
        (err) => {
          if (window.loveApp) window.loveApp.showToast('⚠️ Không thể lấy GPS. Vui lòng cho phép quyền vị trí!');
        }
      );
    }
  }
}

window.loveMap = new LoveMapTracker();
