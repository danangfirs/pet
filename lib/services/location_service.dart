import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LocationData {
  final double latitude;
  final double longitude;
  final double battery;
  final double speed;
  final String timestamp;
  final int entryId;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.battery,
    required this.speed,
    required this.timestamp,
    required this.entryId,
  });

  factory LocationData.fromThingSpeak(Map<String, dynamic> json) {
    return LocationData(
      latitude: double.tryParse(json['field1'] ?? '0') ?? 0,
      longitude: double.tryParse(json['field2'] ?? '0') ?? 0,
      battery: double.tryParse(json['field3'] ?? '100') ?? 100,
      speed: double.tryParse(json['field4'] ?? '0') ?? 0,
      timestamp: json['created_at'] ?? DateTime.now().toIso8601String(),
      entryId: json['entry_id'] ?? 0,
    );
  }
}

class LocationService extends ChangeNotifier {
  // ========== THINGSPEAK CONFIGURATION ==========
  // Channel dari teman (IoT/Hardware)
  static const String channelId = '3213021';
  static const String readApiKey = 'LDV5Z77D7JG1AJ08';
  
  // ThingSpeak API URLs
  static const String baseUrl = 'https://api.thingspeak.com';
  // ==============================================
  
  LocationData? _currentLocation;
  List<LocationData> _locationHistory = [];
  Timer? _pollingTimer;
  bool _isLoading = false;
  String? _error;

  LocationData? get currentLocation => _currentLocation;
  List<LocationData> get locationHistory => _locationHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mulai polling lokasi setiap 10 detik
  void startTracking() {
    fetchLatestLocation();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchLatestLocation();
    });
  }

  // Stop polling
  void stopTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Ambil lokasi terbaru dari ThingSpeak
  Future<void> fetchLatestLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final url = '$baseUrl/channels/$channelId/feeds/last.json?api_key=$readApiKey';
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data != null && data['field1'] != null) {
          _currentLocation = LocationData.fromThingSpeak(data);
          _error = null;
        } else {
          _error = 'No data available';
          // Demo data jika belum ada data
          _currentLocation = LocationData(
            latitude: -6.2088,
            longitude: 106.8456,
            battery: 85.0,
            speed: 0,
            timestamp: DateTime.now().toIso8601String(),
            entryId: 0,
          );
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection failed: $e';
      // Demo data saat offline
      _currentLocation = LocationData(
        latitude: -6.2088,
        longitude: 106.8456,
        battery: 85.0,
        speed: 0,
        timestamp: DateTime.now().toIso8601String(),
        entryId: 0,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ambil riwayat lokasi dari ThingSpeak
  Future<void> fetchLocationHistory({int results = 50}) async {
    try {
      final url = '$baseUrl/channels/$channelId/feeds.json?api_key=$readApiKey&results=$results';
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> feeds = data['feeds'] ?? [];
        
        _locationHistory = feeds
            .where((feed) => feed['field1'] != null && feed['field2'] != null)
            .map((feed) => LocationData.fromThingSpeak(feed))
            .toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
  }

  // Get Google Maps URL for current location
  String? getGoogleMapsUrl() {
    if (_currentLocation == null) return null;
    return 'https://www.google.com/maps?q=${_currentLocation!.latitude},${_currentLocation!.longitude}';
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
