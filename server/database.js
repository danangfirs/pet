const fs = require('fs');
const path = require('path');

const DATA_FILE = path.join(__dirname, 'data.json');

// Initialize data file if not exists
function initData() {
  if (!fs.existsSync(DATA_FILE)) {
    fs.writeFileSync(DATA_FILE, JSON.stringify({
      locations: [],
      geofences: []
    }, null, 2));
  }
}

// Read data from file
function readData() {
  initData();
  const data = fs.readFileSync(DATA_FILE, 'utf8');
  return JSON.parse(data);
}

// Write data to file
function writeData(data) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
}

// Add location
function addLocation(location) {
  const data = readData();
  const newLocation = {
    id: Date.now(),
    device_id: location.device_id || 'pet-tracker-001',
    latitude: location.lat,
    longitude: location.lng,
    battery: location.battery || 100,
    timestamp: new Date().toISOString()
  };
  data.locations.unshift(newLocation);
  // Keep only last 1000 locations
  if (data.locations.length > 1000) {
    data.locations = data.locations.slice(0, 1000);
  }
  writeData(data);
  return newLocation;
}

// Get latest location
function getLatestLocation() {
  const data = readData();
  return data.locations[0] || null;
}

// Get location history
function getLocationHistory(limit = 50) {
  const data = readData();
  return data.locations.slice(0, limit);
}

// Get all geofences
function getGeofences() {
  const data = readData();
  return data.geofences;
}

// Add geofence
function addGeofence(geofence) {
  const data = readData();
  const newGeofence = {
    id: Date.now(),
    ...geofence,
    created_at: new Date().toISOString()
  };
  data.geofences.push(newGeofence);
  writeData(data);
  return newGeofence;
}

module.exports = {
  addLocation,
  getLatestLocation,
  getLocationHistory,
  getGeofences,
  addGeofence
};
