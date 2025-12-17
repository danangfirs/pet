import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LocationData {
  final double latitude;
  final double longitude;
  final double battery;
  final String timestamp;
  final String deviceId;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.battery,
    required this.timestamp,
    required this.deviceId,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      battery: (json['battery'] ?? 100).toDouble(),
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      deviceId: json['device_id'] ?? 'unknown',
    );
  }
}

class LocationService extends ChangeNotifier {
  // Untuk testing lokal, gunakan localhost
  // Untuk production, ganti dengan URL Railway
  static const String baseUrl = 'http://localhost:3000';
  
  LocationData? _currentLocation;
  List<LocationData> _locationHistory = [];
  Timer? _pollingTimer;
  bool _isLoading = false;
  String? _error;

  LocationData? get currentLocation => _currentLocation;
  List<LocationData> get locationHistory => _locationHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mulai polling lokasi setiap 5 detik
  void startTracking() {
    fetchLatestLocation();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchLatestLocation();
    });
  }

  // Stop polling
  void stopTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Ambil lokasi terbaru dari server
  Future<void> fetchLatestLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/api/location/latest'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentLocation = LocationData.fromJson(data);
        _error = null;
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Koneksi gagal: $e';
      // Untuk testing, gunakan lokasi dummy jika gagal
      _currentLocation = LocationData(
        latitude: -6.2088,
        longitude: 106.8456,
        battery: 85.0,
        timestamp: DateTime.now().toIso8601String(),
        deviceId: 'demo',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ambil riwayat lokasi
  Future<void> fetchLocationHistory({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/location/history?limit=$limit'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _locationHistory = data.map((e) => LocationData.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
