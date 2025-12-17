# 🐾 Pet Tracker Hardware Setup

## Komponen yang Dibutuhkan

| Komponen | Jumlah | Keterangan |
|----------|--------|------------|
| ESP32 DevKit V1 | 1 | Mikrokontroler utama |
| Neo-6M GPS Module | 1 | Modul GPS |
| Kabel Jumper | 4 | Untuk koneksi |
| Breadboard | 1 | Opsional |

## Diagram Koneksi

```
GPS Module          ESP32
---------          -----
VCC     ────────►  3.3V
GND     ────────►  GND
TX      ────────►  GPIO 16 (RX2)
RX      ────────►  GPIO 17 (TX2)
```

## Langkah Setup

### 1. Install Arduino IDE
Download dari: https://www.arduino.cc/en/software

### 2. Tambah ESP32 Board
1. Buka Arduino IDE
2. File → Preferences
3. Additional Boards Manager URLs, tambahkan:
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Tools → Board → Boards Manager
5. Cari "esp32" dan install

### 3. Install Library TinyGPS++
1. Sketch → Include Library → Manage Libraries
2. Cari "TinyGPS++" oleh Mikal Hart
3. Klik Install

### 4. Upload Kode
1. Buka file `pet_tracker.ino`
2. Edit konfigurasi WiFi:
   ```cpp
   const char* ssid = "NAMA_WIFI_ANDA";
   const char* password = "PASSWORD_WIFI_ANDA";
   ```
3. Edit URL server (setelah deploy ke Railway):
   ```cpp
   const char* serverUrl = "https://YOUR-APP.railway.app/api/location";
   ```
4. Pilih Board: ESP32 Dev Module
5. Pilih Port yang sesuai
6. Klik Upload

### 5. Testing
1. Buka Serial Monitor (115200 baud)
2. Bawa GPS ke luar ruangan untuk sinyal lebih baik
3. Tunggu hingga GPS mendapat fix (biasanya 1-3 menit)
4. Lihat data lokasi terkirim ke server

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| GPS tidak dapat sinyal | Bawa ke outdoor, tunggu 1-3 menit |
| WiFi tidak konek | Cek SSID dan password |
| Data tidak terkirim | Cek URL server sudah benar |
| Upload gagal | Tekan tombol BOOT saat upload |
