# Pet Tracker Hardware Setup (ThingSpeak)

## Komponen yang Dibutuhkan

| Komponen | Jumlah |
|----------|--------|
| ESP32 DevKit V1 | 1 |
| Neo-6M GPS Module | 1 |
| Kabel Jumper | 4 |

## Diagram Koneksi

```
GPS Module          ESP32
---------          -----
VCC     ────────►  3.3V
GND     ────────►  GND
TX      ────────►  GPIO 16 (RX2)
RX      ────────►  GPIO 17 (TX2)
```

## Setup ThingSpeak

### 1. Buat Akun ThingSpeak
1. Buka https://thingspeak.com
2. Sign up / Login

### 2. Buat Channel Baru
1. Klik **Channels** → **New Channel**
2. Isi field:
   - Name: `Pet Tracker GPS`
   - Field 1: `latitude`
   - Field 2: `longitude`
   - Field 3: `battery`
   - Field 4: `speed`
3. Klik **Save Channel**

### 3. Dapatkan API Keys
1. Buka channel yang baru dibuat
2. Klik tab **API Keys**
3. Catat:
   - **Write API Key** (untuk ESP32)
   - **Read API Key** (untuk Flutter)
   - **Channel ID** (ada di URL)

## Install Library Arduino

1. Buka Arduino IDE
2. **Sketch → Include Library → Manage Libraries**
3. Cari dan install: `TinyGPS++` by Mikal Hart

## Konfigurasi Kode ESP32

Edit `pet_tracker.ino`:

```cpp
// WiFi - GANTI DENGAN WIFI ANDA
const char* ssid = "NAMA_WIFI_ANDA";
const char* password = "PASSWORD_WIFI_ANDA";

// ThingSpeak - GANTI DENGAN API KEY ANDA
const char* writeAPIKey = "YOUR_WRITE_API_KEY";
```

## Konfigurasi Flutter App

Edit `lib/services/location_service.dart`:

```dart
static const String channelId = 'YOUR_CHANNEL_ID';
static const String readApiKey = 'YOUR_READ_API_KEY';
```

## Upload ke ESP32

1. Sambungkan ESP32 ke komputer
2. Arduino IDE → Tools → Board → **ESP32 Dev Module**
3. Pilih Port yang sesuai
4. Klik **Upload**
5. Buka **Serial Monitor** (115200 baud)

## Testing

1. Bawa GPS ke outdoor untuk sinyal
2. Cek Serial Monitor - data akan terkirim setiap 20 detik
3. Buka ThingSpeak → Channel → pilih channel → lihat data masuk
4. Jalankan Flutter app untuk melihat lokasi

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| GPS tidak ada sinyal | Bawa ke outdoor, tunggu 1-3 menit |
| ThingSpeak response "0" | Rate limit, tunggu 15 detik |
| WiFi tidak konek | Cek SSID dan password |
