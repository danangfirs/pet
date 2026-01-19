/*
 * 🐾 Pet Tracker ESP32 + GPS + ThingSpeak
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

// ThingSpeak Configuration - GANTI DENGAN API KEY ANDA
const char* thingspeakServer = "api.thingspeak.com";
const char* writeAPIKey = "YOUR_WRITE_API_KEY";  // Dari ThingSpeak Channel

// Field mapping:
// Field 1 = Latitude
// Field 2 = Longitude
// Field 3 = Battery
// Field 4 = Speed (optional)

// Interval pengiriman data (ThingSpeak free: minimal 15 detik)
const unsigned long SEND_INTERVAL = 20000; // 20 detik

// ==================== VARIABEL ====================

TinyGPSPlus gps;
HardwareSerial GPSSerial(2); // UART2

unsigned long lastSendTime = 0;
float currentLat = 0;
float currentLng = 0;
float currentSpeed = 0;
float batteryLevel = 100.0;

// ==================== SETUP ====================

void setup() {
  Serial.begin(115200);
  GPSSerial.begin(9600, SERIAL_8N1, 16, 17); // RX=16, TX=17
  
  Serial.println("\n========================================");
  Serial.println("   Pet Tracker + ThingSpeak Starting...");
  Serial.println("========================================");
  
  // Konek ke WiFi
  connectWiFi();
  
  Serial.println("Waiting for GPS signal...");
  Serial.println("Tip: Bawa ke outdoor untuk sinyal lebih baik");
}

// ==================== LOOP ====================

void loop() {
  // Baca data GPS
  while (GPSSerial.available() > 0) {
    if (gps.encode(GPSSerial.read())) {
      if (gps.location.isValid()) {
        currentLat = gps.location.lat();
        currentLng = gps.location.lng();
        currentSpeed = gps.speed.kmph();
      }
    }
  }
  
  // Kirim data setiap interval
  if (millis() - lastSendTime >= SEND_INTERVAL) {
    lastSendTime = millis();
    
    if (currentLat != 0 && currentLng != 0) {
      sendToThingSpeak(currentLat, currentLng, batteryLevel, currentSpeed);
    } else {
      Serial.println("GPS belum mendapatkan sinyal...");
      
      // Untuk TESTING tanpa GPS hardware, uncomment baris berikut:
      // sendToThingSpeak(-6.2088, 106.8456, batteryLevel, 0);
    }
  }
  
  // Simulasi battery drain
  if (batteryLevel > 0) {
    batteryLevel -= 0.01;
  }
}

// ==================== FUNGSI WiFi ====================

void connectWiFi() {
  Serial.print("Connecting to WiFi");
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[OK] WiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[ERROR] WiFi Connection Failed!");
    Serial.println("Check SSID and Password");
  }
}

// ==================== FUNGSI THINGSPEAK ====================

void sendToThingSpeak(float lat, float lng, float battery, float speed) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[ERROR] WiFi disconnected, reconnecting...");
    connectWiFi();
    return;
  }
  
  HTTPClient http;
  
  // Build ThingSpeak URL
  String url = "http://api.thingspeak.com/update?api_key=";
  url += writeAPIKey;
  url += "&field1=" + String(lat, 6);
  url += "&field2=" + String(lng, 6);
  url += "&field3=" + String(battery, 1);
  url += "&field4=" + String(speed, 1);
  
  Serial.println("\n--- Sending to ThingSpeak ---");
  Serial.println("LAT: " + String(lat, 6));
  Serial.println("LNG: " + String(lng, 6));
  Serial.println("Battery: " + String(battery, 1) + "%");
  Serial.println("Speed: " + String(speed, 1) + " km/h");
  
  http.begin(url);
  int httpCode = http.GET();
  
  if (httpCode > 0) {
    String response = http.getString();
    if (response == "0") {
      Serial.println("[WARNING] ThingSpeak rate limit (wait 15 sec)");
    } else {
      Serial.println("[OK] Entry ID: " + response);
    }
  } else {
    Serial.println("[ERROR] HTTP Error: " + http.errorToString(httpCode));
  }
  
  http.end();
}
