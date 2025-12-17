/*
 * 🐾 Pet Tracker ESP32 + GPS
 * 
 * Hardware:
 * - ESP32 DevKit V1
 * - Neo-6M GPS Module
 * 
 * Koneksi:
 * GPS VCC  -> 3.3V
 * GPS GND  -> GND
 * GPS TX   -> GPIO 16 (RX2)
 * GPS RX   -> GPIO 17 (TX2)
 * 
 * Library yang dibutuhkan:
 * - TinyGPS++ (install via Arduino Library Manager)
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <TinyGPS++.h>

// ==================== KONFIGURASI ====================

// WiFi credentials - GANTI DENGAN WIFI ANDA
const char* ssid = "NAMA_WIFI_ANDA";
const char* password = "PASSWORD_WIFI_ANDA";

// Server URL - GANTI DENGAN URL RAILWAY ANDA
const char* serverUrl = "https://YOUR-APP.railway.app/api/location";

// Device ID
const char* deviceId = "pet-tracker-001";

// Interval pengiriman data (dalam milidetik)
const unsigned long SEND_INTERVAL = 10000; // 10 detik

// ==================== VARIABEL ====================

TinyGPSPlus gps;
HardwareSerial GPSSerial(2); // UART2

unsigned long lastSendTime = 0;
float currentLat = 0;
float currentLng = 0;
float batteryLevel = 100.0;

// ==================== SETUP ====================

void setup() {
  Serial.begin(115200);
  GPSSerial.begin(9600, SERIAL_8N1, 16, 17); // RX=16, TX=17
  
  Serial.println("\n🐾 Pet Tracker Starting...");
  
  // Konek ke WiFi
  connectWiFi();
  
  Serial.println("📡 Waiting for GPS signal...");
}

// ==================== LOOP ====================

void loop() {
  // Baca data GPS
  while (GPSSerial.available() > 0) {
    if (gps.encode(GPSSerial.read())) {
      if (gps.location.isValid()) {
        currentLat = gps.location.lat();
        currentLng = gps.location.lng();
      }
    }
  }
  
  // Kirim data setiap interval
  if (millis() - lastSendTime >= SEND_INTERVAL) {
    lastSendTime = millis();
    
    if (currentLat != 0 && currentLng != 0) {
      sendLocation(currentLat, currentLng);
    } else {
      Serial.println("⏳ GPS belum mendapatkan sinyal...");
      
      // Untuk testing tanpa GPS, kirim lokasi dummy
      // Uncomment baris berikut untuk testing:
      // sendLocation(-6.2088, 106.8456);
    }
  }
  
  // Simulasi battery drain
  if (batteryLevel > 0) {
    batteryLevel -= 0.001;
  }
}

// ==================== FUNGSI WiFi ====================

void connectWiFi() {
  Serial.print("📶 Connecting to WiFi");
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n❌ WiFi Connection Failed!");
  }
}

// ==================== FUNGSI KIRIM DATA ====================

void sendLocation(float lat, float lng) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("❌ WiFi disconnected, reconnecting...");
    connectWiFi();
    return;
  }
  
  HTTPClient http;
  http.begin(serverUrl);
  http.addHeader("Content-Type", "application/json");
  
  // Buat JSON payload
  String jsonPayload = "{";
  jsonPayload += "\"device_id\":\"" + String(deviceId) + "\",";
  jsonPayload += "\"lat\":" + String(lat, 6) + ",";
  jsonPayload += "\"lng\":" + String(lng, 6) + ",";
  jsonPayload += "\"battery\":" + String(batteryLevel, 1);
  jsonPayload += "}";
  
  Serial.println("📤 Sending: " + jsonPayload);
  
  int httpCode = http.POST(jsonPayload);
  
  if (httpCode > 0) {
    String response = http.getString();
    Serial.println("✅ Response: " + response);
  } else {
    Serial.println("❌ Error: " + http.errorToString(httpCode));
  }
  
  http.end();
}
