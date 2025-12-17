const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// ==================== LOCATION API ====================

// POST - Terima data lokasi dari ESP32
app.post('/api/location', (req, res) => {
  try {
    const { lat, lng, battery, device_id } = req.body;
    
    if (!lat || !lng) {
      return res.status(400).json({ error: 'lat dan lng diperlukan' });
    }

    const location = db.addLocation({
      lat,
      lng,
      battery,
      device_id
    });

    console.log(`📍 Lokasi diterima: ${lat}, ${lng}`);
    
    res.json({ 
      success: true, 
      id: location.id,
      message: 'Lokasi tersimpan'
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// GET - Ambil lokasi terbaru
app.get('/api/location/latest', (req, res) => {
  try {
    const location = db.getLatestLocation();
    
    if (!location) {
      return res.json({ 
        latitude: -6.2088,
        longitude: 106.8456,
        battery: 100,
        timestamp: new Date().toISOString(),
        device_id: 'demo',
        message: 'Belum ada data lokasi'
      });
    }
    
    res.json(location);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET - Ambil riwayat lokasi
app.get('/api/location/history', (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const locations = db.getLocationHistory(limit);
    res.json(locations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== GEOFENCE API ====================

// GET - Ambil semua geofence
app.get('/api/geofence', (req, res) => {
  try {
    const geofences = db.getGeofences();
    res.json(geofences);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST - Tambah geofence baru
app.post('/api/geofence', (req, res) => {
  try {
    const { name, latitude, longitude, radius } = req.body;
    
    const geofence = db.addGeofence({
      name,
      latitude,
      longitude,
      radius: radius || 100
    });
    
    res.json({ 
      success: true, 
      id: geofence.id 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ==================== HEALTH CHECK ====================

app.get('/', (req, res) => {
  res.json({ 
    status: 'OK',
    message: '🐾 Pet Tracker API is running!',
    endpoints: {
      'POST /api/location': 'Kirim lokasi GPS',
      'GET /api/location/latest': 'Ambil lokasi terbaru',
      'GET /api/location/history': 'Ambil riwayat lokasi',
      'GET /api/geofence': 'Ambil daftar geofence',
      'POST /api/geofence': 'Tambah geofence baru'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Pet Tracker Server running on port ${PORT}`);
  console.log(`📡 Ready to receive GPS data from ESP32`);
});
